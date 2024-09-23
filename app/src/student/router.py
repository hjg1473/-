import aioredis
from sqlalchemy import delete, select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Released, Groups, incorrect_problem_table, correct_problem_table, WrongType, ReleasedGroup
from student.dependencies import user_dependency, db_dependency
from student.exceptions import *
from student.schemas import PinNumber, SeasonList
from student.service import *
from app.src.super.exceptions import find_student_exception, find_group_exception
from app.src.super.service import update_student_group, fetch_group_id

router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)

# 학생 보유한 시즌 정보 반환
@router.get("/season_info", status_code=status.HTTP_200_OK)
async def user_season_info(user: user_dependency, db:db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))
    released_model = await fetch_user_released(user.get('id'), db)
    seasons = [item.released_season for item in released_model]
    return {"seasons" : seasons}

# 시즌 업데이트
@router.put("/update_season", status_code=status.HTTP_200_OK)
async def update_user_season(season: SeasonList, user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))

    released_model = await fetch_user_released(user.get('id'), db)
    # List {id, season, level, step, owner_id} 
    seasons = [item.released_season for item in released_model]
    # 가진 것 [1, 3] - [1, 2] = ? or [1, 2, 3] - [4, 5]
    difference = list(set(seasons) - set(season.season)) # 유저가 가진 시즌 - 새로 입력한 시즌
    for sz in difference:
        await db.execute(delete(Released).filter(Released.owner_id == user.get('id')).filter(Released.released_season == sz))
    await db.commit()
    # [4, 5] - [1, 2, 3]
    difference = list(set(season.season) - set(seasons)) # 새로 입력한 시즌 - 유저가 가진 시즌
    for sz in difference:
        released = Released(
            owner_id=user.get('id'), released_season=sz,
            released_level=0, released_step=0
        )
        db.add(released)
    await db.commit()
    return {'detail': '수정되었습니다.'}

@router.post("/pin/enter", status_code = status.HTTP_200_OK)
async def user_solve_problem(pin_number: PinNumber, user: user_dependency, db: db_dependency):
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_id = await redis_client.get(pin_number.pin_number)
    if stored_id is None:
        return {'detail': '유효하지 않은 핀코드입니다.'}
    string_id = stored_id.decode('utf-8')
    # ,가 있으면 group
    if "," in string_id:
        group_id_str, user_id_str = string_id.split(",")
        # 각 값을 정수로 변환
        group_id = int(group_id_str)
        redis_client.close()
        await redis_client.wait_closed()

        await find_student_exception(user.get("id"), db)
        await find_group_exception(group_id, db)
        await update_student_group(group_id, user.get("id"), db)

        group = await get_group_to_groupid(group_id, db)
        result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id))
        released_group = [
                {"season": rg.released_season, "level": rg.released_level, "step": rg.released_step, "type": rg.released_type}
                for rg in result.scalars().all()
            ]
        
        return {
            "team_id":group_id, "group_name": group.name, 
            "group_detail":group.detail, "released_group":released_group
        }
    else:
        result = await db.execute(select(Users).options(joinedload(Users.teachers_students)).filter(Users.id == user.get('id')))
        student = result.scalars().first()
        result2 = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == string_id))
        parent = result2.scalars().first()

        redis_client.close()
        await redis_client.wait_closed()

        self_select_exception(string_id, user.get('id'))
        find_teacher_exception(string_id)
        duplicate_connection_exception(user.get('id'), parent.student_teachers)

        if parent not in student.teachers_students:
            student.teachers_students.append(parent)
        if student not in parent.student_teachers:
            parent.student_teachers.append(student)
            
        await db.commit()
        return {"name": parent.name}

# 학생(self)과 연결된 학부모의 아이디 반환
@router.get("/parent/info", status_code = status.HTTP_200_OK)
async def read_connect_parent(user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))
    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).options(joinedload(Users.teachers_students)).filter(Users.id == user.get('id')))
    parent = result.scalars().first()
    name = ""
    for parent in parent.teachers_students:
        name = parent.name
    return {'name': name}

# 학생 정보 반환
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_info(user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    result2 = await db.execute(select(Groups).where(Groups.id == user_model.team_id))
    group_model = result2.scalars().first()
    return {'name': user_model.name, 'team_id': user_model.team_id, 'group_name': group_model.name}

# utils
def calculate_rates(c_table_id, ic_table_id, c_table_count, ic_table_count, rm, correct_problems, incorrect_problems):
    from app.src.super.utils import calculate_corrects
    # Initialize counters
    normal_corrects, ai_corrects = [0, 0, 0], [0, 0, 0]
    normal_incorrects, ai_incorrects = [0, 0, 0], [0, 0, 0]

    # Calculate corrects and incorrects
    calculate_corrects(c_table_id, ai_corrects, normal_corrects, c_table_count, rm, correct_problems)
    calculate_corrects(ic_table_id, ai_incorrects, normal_incorrects, ic_table_count, rm, incorrect_problems)

    # Calculate totals
    normal_all = [normal_corrects[i] + normal_incorrects[i] for i in range(3)]
    ai_all = [ai_corrects[i] + ai_incorrects[i] for i in range(3)]

    # Calculate rates
    normal_rate = [(normal_corrects[i] / float(normal_all[i]) * 100 if normal_all[i] != 0 else 0) for i in range(3)]
    ai_rate = [(ai_corrects[i] / float(ai_all[i]) * 100 if ai_all[i] != 0 else 0) for i in range(3)]

    return normal_rate, ai_rate


# 학생의 self 학습 정보 반환.
@router.get("/monitoring_correct_rate/", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(season: int, user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))
    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")).filter(Released.released_season == season))
    released_model = result.scalars().all()
    result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result2.scalars().first()
    if study_info is None:
        raise not_found_exception()
    
    from app.src.super.service import fetch_data
    ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_data(study_info.id , db)

    information = []
    for rm in released_model:
        normal_rate, ai_rate = calculate_rates(
            c_table_id, ic_table_id, c_table_count, ic_table_count,
            rm, study_info.correct_problems, study_info.incorrect_problems
        )

        information.append({"season":rm.released_season,
                                        "correct_rate_normal":normal_rate,
                                       "correct_rate_ai":ai_rate,
                                       "released_level":rm.released_level,
                                       "released_step":rm.released_step
                                       })

    return {'seasons':information}

# 유저 모니터링 정보 2
@router.get("/monitoring_incorrect/", status_code = status.HTTP_200_OK)
async def read_self_monitoring(season: int, user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))

    study_info = await fetch_user_studyInfo(user.get('id'), db)
    temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season == season))
    wrongType_model = temp_result.scalars().all()

    from app.src.super.utils import get_latest_log, find_weakest_type, calculate_wrongType_percentage
    divided_data_list = calculate_wrongType_percentage(wrongType_model)

    recent_problem_model = await get_latest_log(user.get('id'))
    if recent_problem_model is None:
        return {'weak_parts':divided_data_list, 'weakest': await find_weakest_type(user.get('id'), db),'recent_detail':'최근 푼 문제 없음' }
    elif recent_problem_model.problem == "" or recent_problem_model.answer == "":
        return {'weak_parts':divided_data_list, 'weakest': await find_weakest_type(user.get('id'), db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer }

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
    if max_variable == 0:
        return {'weak_parts':divided_data_list, 'weakest': await find_weakest_type(user.get('user_role'), db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 'recent_detail':'정보 없음' }

    return {'weak_parts':divided_data_list, 'weakest': await find_weakest_type(user.get('user_role'), db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 'recent_detail':max_variable }

# 유저 모니터링 정보 3
@router.get("/monitoring_etc", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency, db: db_dependency):
    user_credentials_exception(user)
    student_role_exception(user.get('user_role'))
    studyinfo_model = await fetch_user_studyInfo(user.get('id'), db)
    return  {"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}