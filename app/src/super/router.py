from fastapi import APIRouter, HTTPException
import sys, os
from sqlalchemy import delete, select
from sqlalchemy.orm import joinedload
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import AddGroup, GroupName, UserStep, UserStep2, GroupId
from super.utils import *
from app.src.models import StudyInfo, Groups, WrongType, Released, Users, ReleasedGroup
from app.src.auth.utils import create_pin_number
import aioredis
from super.exceptions import *
from starlette import status

router = APIRouter(
    prefix="/super",
    tags=["super"],
    responses={404: {"description": "Not found"}}
)

# Request pin number (for parent connection)
@router.get("/parent/get_pin", status_code=status.HTTP_200_OK)
async def request_pin(user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # Create pin number.
    pin = create_pin_number()
    await redis_client.setex(f"{pin}", 180, user.get('id')) # 180 seconds
    redis_client.close()
    await redis_client.wait_closed()
    return {'parent_pinNumber': pin}

# Request pin number (for group connection)
@router.post("/get_pin", status_code=status.HTTP_200_OK)
async def request_pin(group: GroupId, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group.group_id, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # Create pin number
    pin = create_pin_number()
    # Combine GroupID and UserID with ','. 
    await redis_client.setex(f"{pin}", 180, str(group.group_id) + "," + str(user.get('id'))) # 180 seconds
    redis_client.close()
    await redis_client.wait_closed()
    return {'group_pinNumber': pin}

# Get children managed by the parent.
@router.get("/parent/get_child", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    students = result.scalars().first()
    return {"children": [{"id": students.id, "name": students.name} for students in students.student_teachers]}


# Get group managed by the teacher.
@router.get("/group", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    group_list = await get_group_list(user.get("id"), db)
    result = {'groups': [{'id': u.id, 'name': u.name, 'detail': u.detail, 'count': await get_std_group_count(u.id, db)} for u in group_list]}
    return result

# Create group managed by the teacher.
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def create_group(addgroup: AddGroup, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    # Group name exist?
    await existing_name_exception(addgroup.name, user.get('id'), db)
    newGroup = await update_new_group(addgroup, user.get('id'), db)
    # defalut released group: season1, level0, step0
    await create_group_released(newGroup.id, 1, db)
    return {'detail':'Success'}

# Search for students in group.
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_student_info(group_id: int, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    user_group = await get_std_info(group_id, db)
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in user_group] }
    return result

# Update group id, name, detail ...
@router.put("/group_update", status_code = status.HTTP_200_OK)
async def group_update(group: GroupName, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await existing_name_exception(group.group_name, user.get('id'), db)
    await super_group_exception(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)
    await update_group_name(group.group_id, group.group_name, group.group_detail, db)
    return {'detail' : 'Success'}

# Delete group
@router.delete("/group/remove_group/{group_id}", status_code = status.HTTP_200_OK)
async def delete_group(group_id: int, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    # To delete a group, it must have 0 members.
    if await get_std_group_count(group_id, db) != 0:
        raise group_remove_exception()
    await db.execute(delete(Groups).filter(Groups.id == group_id))
    await db.commit()
    return {'detail': '성공적으로 삭제되었습니다.'}

# teacher removes the student from the class.
@router.put("/group/remove_student/{user_id}", status_code = status.HTTP_200_OK)
async def update_user_team(user_id: int, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await find_student_exception(user_id, db)
    std_team_id = await get_std_team_id(user_id, db)
    group_list = await get_group_list(user.get("id"), db)
    std_access_exception(group_list, std_team_id)
    await update_std_group(None, user_id, db)
    return {'detail' : 'Success'}

# Check group info
@router.get("/group/{group_id}/info", status_code=status.HTTP_200_OK)
async def read_group_info(group_id:int, user:user_dependency, db:db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    # group_model = await get_group_to_groupid(group_id, db)
    result3 = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id))
    target_season = result3.scalars().all()
    return target_season

# Unlock group level, step.
@router.put("/group/{group_id}/problems/unlock", status_code= status.HTTP_200_OK)
async def unlock_step_level(group_id: int, type:str, season:int, level:int, step:int, user:user_dependency, db:db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group_id, db)
    result3 = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id, ReleasedGroup.released_season == season))
    target_season = result3.scalars().all()
    # Check Group's season.
    if not target_season:
        target_season = await create_group_released(group_id, season, db)

    # Repeat
    for target in target_season:
        if target.released_type == type:
            current_type = type
            current_level = target.released_level
            current_step = target.released_step
            # If the level you are trying to unlock is lower than your current level, an error will occur.
            if (level < current_level):
                raise released_step_exception()
            # If the step you are trying to unlock is lower than your current step, an error will occur.
            elif (level == current_level) and (step <= current_step):
                raise released_step_exception()   

    await update_group_level_and_step(group_id, season, level, current_type, step, db)

    return {'detail' : 'success'}

# User info
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_super_info(user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    user_model_json = await get_super_info(user, db)
    return user_model_json


# Read user monitoring info. (weakest, studytime, day ...)
@router.post("/user_monitoring_summary", status_code = status.HTTP_200_OK)
async def read_user_monitoring_summary(userStep: UserStep2, user: user_dependency, db: db_dependency):

    # Check if user has access
    await process_user_access(user, userStep.user_id, db)
        
    # BEGIN_CHECKING_WEAKEST_PART

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    study_info = result.scalars().first()
    temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season == userStep.season))
    wrongType_model = temp_result.scalars().all()
    divided_data_list = weak_parts_top3(wrongType_model)
    weakest = await user_weakest_info(userStep.user_id, db)
    extracted_data = [
        {
            weakest: item.get(weakest, None),
            "season": item["season"],
            "level": item["level"]
        }
        for item in divided_data_list
    ]

    # END_CHECKING_WEAKEST_PART

    # Read user Studyinfo.
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    studyinfo_model = result.scalars().first()

    return  {"weakest_part":extracted_data,"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}

# Read user monitoring info. (problem correct rate)
@router.post("/user_monitoring_study/rate", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(userStep: UserStep2, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    result = await db.execute(select(Released).filter(Released.owner_id == userStep.user_id).filter(Released.released_season == userStep.season))
    released_model = result.scalars().all()

    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == userStep.user_id))
    study_info = result.scalars().first()
    if study_info is None:
        raise http_exception()
    
    # Get studyinfo data. ( incorrect / correct problem id, count )
    ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_data(study_info.id , db)
    
    information = []
    for rm in released_model:

        # Initialization
        normal_corrects = [0, 0, 0]
        ai_corrects = [0, 0, 0]
        calculate_corrects(c_table_id, ai_corrects, normal_corrects, c_table_count, rm, study_info.correct_problems)
        
        # Initialization
        normal_incorrects = [0, 0, 0]
        ai_incorrects = [0, 0, 0]
        calculate_corrects(ic_table_id, ai_incorrects, normal_incorrects, ic_table_count, rm, study_info.incorrect_problems)
        
        # Total number of questions (correct + incorrect)
        normal_all = [normal_corrects[0] + normal_incorrects[0], normal_corrects[1] + normal_incorrects[1], normal_corrects[2] + normal_incorrects[2]]
        ai_all = [ai_corrects[0] + ai_incorrects[0], ai_corrects[1] + ai_incorrects[1], ai_corrects[2] + ai_incorrects[2]]

        normal_rate = [0, 0, 0]
        ai_rate = [0, 0, 0]
        # Calculating the correct answer rate (for general and AI problems respectively)
        for i in range(3):
            if normal_all[i] != 0:
                normal_rate[i] = (normal_corrects[i]/float(normal_all[i]) * 100)
            if ai_all[i] != 0:
                ai_rate[i] = (ai_corrects[i]/float(ai_all[i]) * 100)
        information.append({"season":rm.released_season,
                                       "correct_rate_normal":normal_rate,
                                       "correct_rate_ai":ai_rate,
                                       "released_level":rm.released_level,
                                       "released_step":rm.released_step
                                       })

    return {'detail': information}

# Read user monitoring info. (recent problem info, weak parts ... )
@router.post("/user_monitoring_incorrect", status_code = status.HTTP_200_OK)
async def read_user_weak_parts_top3(userStep: UserStep2, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    study_info = result.scalars().first()
    temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season == userStep.season))
    wrongType_model = temp_result.scalars().all()
    # Calculate the top 3 weak points
    divided_data_list = weak_parts_top3(wrongType_model)
    # Get recently solved problems
    recent_problem_model = await get_latest_log(userStep.user_id)
    
    # If there are no recently solved problems, return the default value.
    if recent_problem_model is None:
        return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_detail':'최근 푼 문제 없음' }
    elif recent_problem_model.problem == "" or recent_problem_model.answer == "":
        return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer }
    # elif recent_problem_model.answer == "":
    #     return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer }


    from app.src.problem.service import calculate_wrongs
    from app.src.problem.utils import parse_sentence
    problem_parse = parse_sentence(recent_problem_model.problem) 
    response_parse = parse_sentence(recent_problem_model.answer)
    letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong = await calculate_wrongs(problem_parse, response_parse, db)
    values = {
        'letter_wrong': letter_wrong,
        'punc_wrong': punc_wrong,
        'block_wrong': block_wrong,
        'word_wrong': word_wrong,
        'order_wrong': order_wrong
    }
    max_variable = max(values, key=values.get)
    # If there are no maxValue, return the default value.
    if max_variable == 0:
        return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 'recent_detail':'정보 없음' }

    return {'weak_parts':divided_data_list, 'weakest': await user_weakest_info(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 'recent_detail':max_variable }

# Read user monitoring info. ( StudyTime )
@router.post("/user_monitoring_etc", status_code = status.HTTP_200_OK)
async def read_user_id(userStep: UserStep, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == userStep.user_id))
    studyinfo_model = result.scalars().first()
    return  {"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}

# Group monitoring info ( weakest, studytime, day, recent problem info, weak parts ... )
@router.post("/group_monitoring", status_code = status.HTTP_200_OK)
async def read_group_monitoring(group: GroupId, user: user_dependency, db: db_dependency):
    super_authenticate_exception(user)
    await super_group_exception(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)

    result = await db.execute(select(Groups).filter(Groups.id == group.group_id))
    groups = result.scalars().all()

    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students_in_group = result3.scalars().all()
        students.extend(students_in_group)
    # 학생들의 id 값만 추출
    student_ids = [student.id for student in students]

    # Initialize
    divided_data_list = []
    season = []
    wrong_letter = []
    wrong_block = []
    wrong_word = []
    level = []
    wrong_punctuation = []
    wrong_order = []
    cnt = 0

    for user_id in student_ids:
        result2 = await db.execute(select(Released).filter(Released.owner_id == user_id))
        released_model = result2.scalars().all()
        seasons = [item.released_season for item in released_model]

        result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
        study_info = result.scalars().first()
        temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season.in_(seasons)))
        wrongType_model = temp_result.scalars().all()
        # Store data for each wrong problem type
        for wrongTypes in wrongType_model:
            season.append(wrongTypes.season)
            level.append(wrongTypes.level)
            wrong_punctuation.append(wrongTypes.wrong_punctuation)
            wrong_letter.append(wrongTypes.wrong_letter)
            wrong_block.append(wrongTypes.wrong_block)
            wrong_word.append(wrongTypes.wrong_word)
            wrong_order.append(wrongTypes.wrong_order)
            cnt += 1
    info = {"season":season, "level":level, "wrong_punctuation":wrong_punctuation, "wrong_letter":wrong_letter, "wrong_block":wrong_block, "wrong_word":wrong_word, "wrong_order":wrong_order}

    
    # Convert incorrect problem type information into a data frame
    import pandas as pd
    df = pd.DataFrame(info)

    # Sum up the types of incorrect questions by season and level
    combined_indices = df.groupby(['season', 'level']).sum().reset_index()
    combined_indices_dict = combined_indices.to_dict(orient="records")

    # BEGIN : Same Process with read_user_weak_parts_top3

    divided_data_list = []
    for wrongTypes in combined_indices_dict:
        total_wrongType = (
            wrongTypes["wrong_punctuation"]
            + wrongTypes["wrong_order"]
            + wrongTypes["wrong_letter"]
            + wrongTypes["wrong_block"]
            + wrongTypes["wrong_word"]
        )
        
        # Select the top 3 incorrect problem types
        wrong_data = {k: v for k, v in wrongTypes.items() if k.startswith("wrong")}
        
        top3_wrong = dict(sorted(wrong_data.items(), key=lambda item: item[1], reverse=True)[:3])
        if total_wrongType != 0:
            divided_data = {k: f"{v / total_wrongType:.2f}" for k, v in top3_wrong.items()}
        divided_data["season"] = wrongTypes["season"]
        divided_data["level"] = wrongTypes["level"]
        divided_data_list.append(divided_data)

    # Calculate the weakest type in the group
    values = {'wrong_punctuation': 0, 'wrong_order': 0, 'wrong_letter': 0, 'wrong_block': 0, 'wrong_word': 0}
    for student in student_ids:
        value = await user_weakest_info(student, db)
        if value in values:
            values[value] += 1
    largest_variable = max(values, key=values.get)

    # END : Same Process with read_user_weak_parts_top3

    result2 = await db.execute(select(Groups).filter(Groups.id == group.group_id))
    groups_create = result2.scalars().first()
    result2 = await db.execute(select(Groups).filter(Groups.id == group.group_id))
    groups = result2.scalars().all()

    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students_in_group = result3.scalars().all()
        students.extend(students_in_group)
        
    student_ids = [student.id for student in students]

    # BEGIN : Same Process with read_user_studyinfo

    normal_corrects = [0, 0, 0]
    normal_incorrects = [0, 0, 0]
    result_normal = [0,0,0]
    ai_corrects = [0, 0, 0]
    ai_incorrects = [0, 0, 0]
    result_ai = [0,0,0]
    for user_id in student_ids:
        result = await db.execute(select(Released).filter(Released.owner_id == user_id))
        released_model = result.scalars().all()

        result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user_id))
        study_info = result2.scalars().first()
        if study_info is None:
            raise http_exception()

        ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_data(study_info.id , db)

        information = []
        
        for rm in released_model:
            calculate_corrects(c_table_id, ai_corrects, normal_corrects, c_table_count, rm, study_info.correct_problems)
            calculate_corrects(ic_table_id, ai_incorrects, normal_incorrects, ic_table_count, rm, study_info.incorrect_problems)

            normal_all = [normal_corrects[0] + normal_incorrects[0], normal_corrects[1] + normal_incorrects[1], normal_corrects[2] + normal_incorrects[2]]
            result_normal = [a + b for a, b in zip(result_normal, normal_all)]
            ai_all = [ai_corrects[0] + ai_incorrects[0], ai_corrects[1] + ai_incorrects[1], ai_corrects[2] + ai_incorrects[2]]
            result_ai = [a + b for a, b in zip(result_ai, ai_all)]
        normal_rate = [0, 0, 0]
        ai_rate = [0, 0, 0]
        for i in range(3):
            if normal_all[i] != 0:
                normal_rate[i] = (normal_corrects[i]/float(result_normal[i]) * 100)
            if ai_all[i] != 0:
                ai_rate[i] = (ai_corrects[i]/float(result_ai[i]) * 100)
        information.append({"season":rm.released_season,
                                        "correct_rate_normal":normal_rate,
                                        "correct_rate_ai":ai_rate,
                                        "released_level":rm.released_level,
                                        "released_step":rm.released_step
                                        })

    # END : Same Process with read_user_studyinfo

    return {'detail':information,"incorrect_reason": divided_data_list, "weakest":f"{largest_variable}", "created":groups_create.created, 'peoples': await get_std_group_count(group.group_id, db) }
