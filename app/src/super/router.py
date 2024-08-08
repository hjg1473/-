import re
from fastapi import APIRouter, HTTPException
import sys, os
from pydantic import BaseModel
from sqlalchemy import delete, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.constants import STUDY_PASS_STANDARD
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import ProblemSet, AddGroup, GroupStep, GroupAvgTime, GroupLevelStep, GroupName, UserStep, UserStep2, GroupId, GroupSeasonLevel
from super.utils import *
from app.src.models import StudyInfo, Problems, Groups, WrongType, Released, Users, Words
from app.src.auth.utils import create_pin_number
import aioredis
from super.exceptions import *
from starlette import status

router = APIRouter(
    prefix="/super",
    tags=["super"],
    responses={404: {"description": "Not found"}}
)

# 그룹 연결 핀번호 요청
@router.post("/get_pin", status_code=status.HTTP_200_OK)
async def request_pin(group: GroupId, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group.group_id, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    pin = create_pin_number()
    await redis_client.setex(f"{pin}", 180, group.group_id)

    redis_client.close()
    await redis_client.wait_closed()

    return {'group_pinNumber': pin}

# 해당 선생님이 관리하는 반 조회
@router.get("/group", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    
    group_list = await get_group_list(user.get("id"), db)
    
    result = {'groups': [{'id': u.id, 'name': u.name, 'detail': u.detail, 'count': await get_std_group_count(u.id, db)} for u in group_list]}
    
    return result

# 해당 선생님이 관리하는 반 추가
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def create_group(addgroup: AddGroup, 
                            user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await existing_name_exception(addgroup.name, user.get('id'), db)

    newGroup = await update_new_group(addgroup, user.get('id'), db)
    # defalut released group: season1, level0, step0
    await create_group_released(newGroup.id, 1, db)

    return {'detail':'Success'}

# 특정 반에 속한 학생들의 정보 조회
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_student_info(group_id: int,
                    user: user_dependency,
                    db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    user_group = await get_std_info(group_id, db)
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in user_group] }
    
    return result

# 특정 그룹 업데이트
@router.put("/group_update", status_code = status.HTTP_200_OK)
async def group_update(group: GroupName,
                            user: user_dependency,
                            db: db_dependency):
    super_authenticate_exception(user)
    await existing_name_exception(group.group_name, user.get('id'), db)
    await super_group_exception(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)
    await update_group_name(group.group_id, group.group_name, group.group_detail, db)

    return {'detail' : 'Success'}

# 해당 그룹을 없앰
@router.delete("/group/remove_group/{group_id}", status_code = status.HTTP_200_OK)
async def delete_group(group_id: int, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    if await get_std_group_count(group_id, db) != 0:
        raise group_remove_exception()
    await db.execute(delete(Groups).filter(Groups.id == group_id))
    await db.commit()

    return {'detail': '성공적으로 삭제되었습니다.'}

# 해당 학생의 소속된 '반' 없앰
@router.put("/group/remove_student/{user_id}", status_code = status.HTTP_200_OK)
async def update_user_team(user_id: int,
                            user: user_dependency,
                            db: db_dependency):
    super_authenticate_exception(user)
    await find_student_exception(user_id, db)

    std_team_id = await get_std_team_id(user_id, db)
    group_list = await get_group_list(user.get("id"), db)
    std_access_exception(group_list, std_team_id)

    await update_std_group(None, user_id, db)

    return {'detail' : 'Success'}

# 반 정보 개괄 확인하기; 현재 학습 진행 정도, 학습 완료율, 명단(은 잠시 뺌)
@router.get("/group/{group_id}/info", status_code=status.HTTP_200_OK)
async def read_group_info(group_id:int, user:user_dependency, db:db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)

    group_model = await get_group_to_groupid(group_id, db)

    released_level = group_model.releasedLevel
    released_step = group_model.releasedStep

    result = {
        "released_level":released_level,
        "released_step":released_step
    }

    return result

# 선생님이 관리하는 반의 step 및 level 해금
@router.put("/group/{group_id}/problems/unlock", status_code= status.HTTP_200_OK)
async def unlock_step_level(group_id: int, type: str, season:int, level:int, step:int, user:user_dependency, db:db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    
    result3 = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id, ReleasedGroup.released_season == season))
    target_season = result3.scalars().first()
    if target_season is None:
        target_season = await create_group_released(group_id, season, db)

    result = await db.execute(select(Problems).filter(Problems.season == season, Problems.level == level, Problems.step == step, Problems.type == type))
    target_problems = result.scalars().all()
    problem_found_exception(target_problems)

    # check whether level and step are valid.
    current_level = target_season.released_level
    current_type = target_season.released_type
    current_step = target_season.released_step
    # 현재 2-3 인데 1-4 를 해금하려고 하면 안됨.
    if (level < current_level):
        raise released_step_exception()
    # 현재 2-3 인데 2-3을 해금하려면 안됨. 2-4 부터.
    elif (level == current_level) and (step <= current_step) and (type == current_type):
        raise released_step_exception()
    if (type == 'normal' and current_type == 'ai'):
        raise released_step_exception()

    await update_group_level_and_step(group_id, level, type, step, db)

    return {'detail' : 'Success'}


# 선생님의 정보 반환, self
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_super_info(user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)

    user_model_json = await get_super_info(user, db)

    return user_model_json

# 특정 유저의 시즌-레벨 별 약한 부분 TOP 3 조회 
@router.post("/user_monitoring_incorrect", status_code = status.HTTP_200_OK)
async def read_user_weak_parts_top3(userStep: UserStep, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await find_student_exception(userStep.user_id, db)
    # 선생님이 관리하는 학생이 아니면 예외 처리
    std_team_id = await get_std_team_id(userStep.user_id, db)
    group_list = await get_group_list(user.get("id"), db)
    std_access_exception(group_list, std_team_id)

    # 학생이 해금한 시즌 정보
    result2 = await db.execute(select(Released).filter(Released.owner_id == userStep.user_id))
    released_model = result2.scalars().all()
    seasons = [item.released_season for item in released_model]

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    study_info = result.scalars().first()
    temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season.in_(seasons)))
    wrongType_model = temp_result.scalars().all()
    # return wrongType_model
    divided_data_list = []

    for wrongTypes in wrongType_model:
        total_wrongType = (
            wrongTypes.wrong_punctuation
            + wrongTypes.wrong_order
            + wrongTypes.wrong_letter
            + wrongTypes.wrong_block
            + wrongTypes.wrong_word
        )
        
        wrong_data = {k: v for k, v in vars(wrongTypes).items() if k.startswith("wrong")}
        
        top3_wrong = dict(sorted(wrong_data.items(), key=lambda item: item[1], reverse=True)[:3])
        
        divided_data = {k: f"{v / total_wrongType:.2f}" for k, v in top3_wrong.items()}
        divided_data["season"] = wrongTypes.season
        divided_data["level"] = wrongTypes.level
        divided_data_list.append(divided_data)

    recent_problem_model = await get_latest_log(userStep.user_id)
    if recent_problem_model is None:
        return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_detail':'최근 푼 문제 없음' }
    from app.src.problem.service import calculate_wrongs
    problem_parse = split_sentence(recent_problem_model.problem)
    response_parse = split_sentence(recent_problem_model.answer)
    # return {'problem_parse':problem_parse,'response_parse':response_parse}
    letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong = await calculate_wrongs(problem_parse, response_parse, db)
    values = {
        'letter_wrong': letter_wrong,
        'punc_wrong': punc_wrong,
        'block_wrong': block_wrong,
        'word_wrong': word_wrong,
        'order_wrong': order_wrong
    }
    max_variable = max(values, key=values.get)

    return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 'recent_detail':max_variable }

# 사용자의 프로필 반환
@router.post("/user_monitoring_etc", status_code = status.HTTP_200_OK)
async def read_user_id(userStep: UserStep, user: user_dependency, db: db_dependency):

    super_authenticate_exception(user)
    await find_student_exception(userStep.user_id, db)
    # 선생님이 관리하는 학생이 아니면 예외 처리
    std_team_id = await get_std_team_id(userStep.user_id, db)
    group_list = await get_group_list(user.get("id"), db)
    std_access_exception(group_list, std_team_id)


    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    studyinfo_model = result.scalars().first()

    return  {"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}


# # 특정 유저의 전 시즌-레벨 통합 가장 약한 부분 내용 조회
# @router.post("/user_weakest", status_code = status.HTTP_200_OK)
# async def read_user_weakest(userStep: UserStep, user: user_dependency, db: db_dependency):
    
#     super_authenticate_exception(user)
#     await find_student_exception(userStep.user_id, db)
#     # 선생님이 관리하는 학생이 아니면 예외 처리
#     std_team_id = await get_std_team_id(userStep.user_id, db)
#     group_list = await get_group_list(user.get("id"), db)
#     std_access_exception(group_list, std_team_id)

#     return await user_weakest_info(userStep.user_id, db)

# # 특정 유저의 특정 시즌-레벨의 오답률 정보 조회
# @router.post("/user_answer_rate_info", status_code = status.HTTP_200_OK)
# async def read_user_answerRate(userStep: UserStep2, user: user_dependency, db: db_dependency):
    
#     super_authenticate_exception(user)
#     await find_student_exception(userStep.user_id, db)

#     std_team_id = await get_std_team_id(userStep.user_id, db)
#     group_list = await get_group_list(user.get("id"), db)
#     std_access_exception(group_list, std_team_id)
#     correct_count = await user_step_problem_count(userStep.user_id, userStep.season, userStep.level, "correct_problems", db)
#     incorrect_count = await user_step_problem_count(userStep.user_id, userStep.season, userStep.level, "incorrect_problems", db)
#     user_level_step_incorrect_answer_rate = 0
#     get_studyInfo_exception(correct_count, incorrect_count)
#     user_level_step_incorrect_answer_rate = f"{incorrect_count / (correct_count + incorrect_count):.2f}"
#     return {'correct_count': correct_count, 'incorrect_count': incorrect_count, 'user_level_step_incorrect_answer_rate': user_level_step_incorrect_answer_rate}

# # 특정 유저의 최근의 틀린 문제 조회
# @router.post("/user_recently_problem/", status_code = status.HTTP_200_OK)
# async def read_user_recently_problem(user_id: int, user: user_dependency, db: db_dependency):
    
#     super_authenticate_exception(user)
#     await find_student_exception(user_id, db)

#     std_team_id = await get_std_team_id(user_id, db)
#     group_list = await get_group_list(user.get("id"), db)
#     std_access_exception(group_list, std_team_id)

#     recent_problem_model = await get_latest_log(user_id)
#     from app.src.problem.service import calculate_wrongs
#     problem_parse = split_sentence(recent_problem_model.problem)
#     response_parse = split_sentence(recent_problem_model.answer)
#     # return {'problem_parse':problem_parse,'response_parse':response_parse}
#     letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong = await calculate_wrongs(problem_parse, response_parse, db)
#     values = {
#         'letter_wrong': letter_wrong,
#         'punc_wrong': punc_wrong,
#         'block_wrong': block_wrong,
#         'word_wrong': word_wrong,
#         'order_wrong': order_wrong
#     }
#     max_variable = max(values, key=values.get)
    
#     return {'problem':recent_problem_model.problem, 'answer':recent_problem_model.answer, 'detail':max_variable}

# 특정 그룹의 전 시즌-레벨 통합 가장 약한 부분 내용 조회 :: 계산 최대 다수의 weakest 
@router.post("/group_weakest", status_code = status.HTTP_200_OK)
async def read_group_weakest(group: GroupId, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)

    result2 = await db.execute(select(Groups).filter(Groups.id == group.group_id))
    groups = result2.scalars().all()
    # return groups # 그룹 정보
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students_in_group = result3.scalars().all()
        students.extend(students_in_group)

    # 학생들의 id 값만 추출
    student_ids = [student.id for student in students]
    # return student_ids
    values = {'wrong_punctuation': 0, 'wrong_order': 0, 'wrong_letter': 0, 'wrong_block': 0, 'wrong_word': 0}
    
    for student in student_ids:
        value = await user_weakest_info(student, db)
        if value["weakest"] in values:
            values[value["weakest"]] += 1
    largest_variable = max(values, key=values.get)
    return {"weakest":f"{largest_variable}"}

# 특정 반의 특정 시즌-레벨의 오답률 정보 조회
@router.post("/group_answer_rate_info", status_code = status.HTTP_200_OK)
async def read_group_answerRate(user: user_dependency, db: db_dependency, groupStep: GroupSeasonLevel):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), groupStep.group_id, db)
    await find_group_exception(groupStep.group_id, db)
    correct_count = await group_step_problem_count(groupStep.group_id, groupStep.season, groupStep.level, "correct_problems", db)
    incorrect_count = await group_step_problem_count(groupStep.group_id, groupStep.season, groupStep.level, "incorrect_problems", db)
    group_step_incorrect_answer_rate = 0
    get_studyInfo_exception(correct_count, incorrect_count)
    group_step_incorrect_answer_rate = f"{incorrect_count / (correct_count + incorrect_count):.2f}"
    return {'correct_count': correct_count, 'incorrect_count': incorrect_count, 'group_step_incorrect_answer_rate': group_step_incorrect_answer_rate}

# 특정 반의 처음부터 해금된 레벨까지의 시즌-레벨 오답률 정보 전달
@router.post("/group_answer_rate_info", status_code = status.HTTP_200_OK)
async def read_group_answerRate(user: user_dependency, db: db_dependency, groupStep: GroupSeasonLevel):

    group_model = await get_group_to_groupid(groupStep.group_id, db)
    current_level = group_model.releasedLevel # int 
    for i in range(1, current_level):
        await read_group_answerRate(user, db, groupStep)
    return

# 특정 반의 평균 학습 시간 조회
@router.post("/group_student_avg_time", status_code = status.HTTP_200_OK)
async def read_group_avgTime(groupAvgTime: GroupAvgTime, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), groupAvgTime.group_id, db)
    await find_group_exception(groupAvgTime.group_id, db)
    return await group_avg_time(groupAvgTime.group_id, db)

# 특정 반의 특정 레벨-스텝의 학습 현황 조회
@router.post("/group_study_info", status_code = status.HTTP_200_OK)
async def read_group_studyInfo(groupStep: GroupLevelStep, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), groupStep.group_id, db)
    await find_group_exception(groupStep.group_id, db)
    return await group_student_problem(groupStep.group_id, groupStep.step, groupStep.level, db)


# 특정 반의 학습 진도 조회
@router.post("/group_study_status", status_code = status.HTTP_200_OK)
async def read_group_study_status(group: GroupId, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)
    
    group_model = await get_group_to_groupid(group.group_id, db)

    released_level = group_model.releasedLevel
    released_step = group_model.releasedStep
    if released_level is None or released_step is None:
        released_level = 1
        released_step = 1
    # return {"released_level": released_level, "released_step": released_step}
    # 문제 스텝 조회
    result = await db.execute(select(Problems))
    problem_model = result.scalars().all()

    problems = set()
    result = []

    for problem in problem_model:
        if problem.level:
            problems.add(problem.level)

    problems = list(problems)
    for level in problems:
        problem_step = set()  
        for problem in problem_model:
            if problem.level == level: 
                if problem.step:
                    problem_step.add(problem.step) 
        result.append({'level_name': level, 'steps': list(problem_step)})

    start_level_name = released_level
    start_step = released_step
    while start_level_name >= 1:
        while start_step >= 1:
            if await group_student_progress(group.group_id, start_level_name, start_step, db) > STUDY_PASS_STANDARD:
                return {'detail' : 'LEVEL' + f"{start_level_name}" + '- STEP' + f"{start_step}" + ' 학습 완료'}
            start_step -= 1
        if start_step == 0:
            start_level_name -= 1
            start_step = get_max_step_in_level(result, start_level_name)# 바뀐 start_level_name 의 step 에서 최대값을 가져옴.
    return {'detail': 'LEVEL 1 - STEP -1 학습 중'}


# 특정 반의 특정 레벨 스텝의 평균 학습 문장 조회
@router.post("/group_student_avg_sentence", status_code = status.HTTP_200_OK)
async def read_group_avgSentence(groupStep: GroupLevelStep, user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), groupStep.group_id, db)
    await find_group_exception(groupStep.group_id, db)
    return await group_avg_student_problem(groupStep.group_id, groupStep.step, groupStep.level, db)
