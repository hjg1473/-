import json
import aioredis
from sqlalchemy import delete, select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users, StudyInfo, Released, incorrect_problem_table, correct_problem_table, Groups
from student.dependencies import user_dependency, db_dependency
from student.exceptions import get_user_exception, get_user_exception2, auth_exception, http_exception, select_exception1, select_exception2, select_exception3
from student.schemas import PinNumber, SoloGroup, SeasonList
from app.src.super.exceptions import find_student_exception, find_group_exception
from app.src.super.service import update_std_group
router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)


# 학생 보유한 시즌 정보 반환
@router.get("/season_info", status_code=status.HTTP_200_OK)
async def user_season_info(user: user_dependency, db:db_dependency):
    get_user_exception(user)
    auth_exception(user.get('user_role'))

    result2 = await db.execute(select(Released).filter(Released.owner_id == user.get('id')))
    released_model = result2.scalars().all()

    seasons = [item.released_season for item in released_model]

    return {"seasons" : seasons}

# 시즌 업데이트
@router.put("/update_season", status_code=status.HTTP_200_OK)
async def update_user_season(user: user_dependency, db: db_dependency, season: SeasonList):
    get_user_exception(user)

    result2 = await db.execute(select(Released).filter(Released.owner_id == user.get('id')))
    released_model = result2.scalars().all()
    # List {id, season, level, step, owner_id} 
    seasons = [item.released_season for item in released_model]
    
    # 가진 것 [1, 3] - [1, 2] = ? or [1, 2, 3] - [4, 5]
    difference = list(set(seasons) - set(season.season))# 유저가 가진 시즌 - 새로 입력한 시즌
    for sz in difference:
        await db.execute(delete(Released).filter(Released.owner_id == user.get('id')).filter(Released.released_season == sz))
    await db.commit()
    # [4, 5] - [1, 2, 3]
    difference = list(set(season.season) - set(seasons))# 새로 입력한 시즌 - 유저가 가진 시즌
    for sz in difference:
        released = Released(
            owner_id=user.get('id'),
            released_season=sz,
            released_level=1,
            released_step=1
        )
        db.add(released)
    await db.commit()
    return {'detail': '수정되었습니다.'}

@router.post("/group/enter", status_code = status.HTTP_200_OK)
async def user_solve_problem(pin_number: PinNumber,
                            user: user_dependency,
                            db: db_dependency):
    
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    print(type(pin_number.pin_number))
    stored_group_id = await redis_client.get(f"{pin_number.pin_number}")
    if stored_group_id is None:
        return {'detail': '유효하지 않은 핀코드입니다.'}
    string_group_id = stored_group_id.decode('utf-8')
    redis_client.close()
    await redis_client.wait_closed()

    await find_student_exception(user.get("id"), db)
    await find_group_exception(int(string_group_id), db)
    await update_std_group(int(string_group_id), user.get("id"), db)

    return {'detail' : '연결되었습니다.'}

# 학생과 학부모 연결, 학부모 -> 학생(teachers_students) # wireframe 나오면 고도화.
@router.get("/connect/parent", status_code = status.HTTP_200_OK)
async def connect_teacher(user_id: int, user: user_dependency, db: db_dependency):

    get_user_exception(user)

    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    parent = result.scalars().first()
    
    get_user_exception2(parent)
    select_exception1(user_id, user.get("id"))
    
    result2 = await db.execute(select(Users).filter(Users.id == user_id))
    student = result2.scalars().first()

    select_exception2(student)
    select_exception3(student, parent.student_teachers)

    parent.student_teachers.append(student)
    await db.commit()
    return {"detail": "Connected successfully", "student_id": student.id, "student_username": student.username}


# 학생(self)과 연결된 학부모의 아이디 반환
@router.get("/connect_parent_info", status_code = status.HTTP_200_OK)
async def read_connect_parent(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    
    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    parent = result.scalars().first()

    return {"parents": [{"name": parent.name} for parent in parent.student_teachers]}

# 학생 정보 반환
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_info(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    result2 = await db.execute(select(Groups).where(Groups.id == user_model.team_id))
    group_model = result2.scalars().first()

    return {'name': user_model.name, 'team_id': user_model.team_id, 'group_name': group_model.name}

# 사용자의 프로필 반환
@router.get("/profile_info", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
    studyinfo_model = result.scalars().first()

    return  {"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}

# 학생의 self 학습 정보 반환.
@router.get("/studyinfo", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    #로그를 보여주자. 학습 기록 처럼. ex) 7/18 - step1 완료, 7/19 - step2 완료 ... 등등
    
    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")))
    released_model = result.scalars().all()
    
    result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result2.scalars().first()
    if study_info is None:
        raise http_exception()
    
    # 틀린 문제 count 배열 받아오기
    result = await db.execute(select(incorrect_problem_table.c.count).filter(incorrect_problem_table.c.study_info_id == study_info.id))
    ic_table_count = result.scalars().all()

    # 틀린 문제 id 배열 받아오기
    result = await db.execute(select(incorrect_problem_table.c.problem_id).filter(incorrect_problem_table.c.study_info_id == study_info.id))
    ic_table_id = result.scalars().all()

    # 맞은 문제 count 배열 받아오기
    result = await db.execute(select(correct_problem_table.c.count).filter(correct_problem_table.c.study_info_id == study_info.id))
    c_table_count = result.scalars().all()

    # 맞은 문제 id 배열 받아오기
    result = await db.execute(select(correct_problem_table.c.problem_id).filter(correct_problem_table.c.study_info_id == study_info.id))
    c_table_id = result.scalars().all()

    information = {"seasons":[]}
    for rm in released_model:
        normal_corrects = [0, 0, 0]
        ai_corrects = [0, 0, 0]
        for item in study_info.correct_problems:
            count = c_table_count[c_table_id.index(item.id)]
            if item.type == "normal":
                normal_corrects[item.level - 1] += count
            else:
                ai_corrects[item.level - 1] += count
        
        normal_incorrects = [0, 0, 0]
        ai_incorrects = [0, 0, 0]
        for item in study_info.incorrect_problems:
            count = ic_table_count[ic_table_id.index(item.id)]
            if item.type == "normal":
                normal_incorrects[item.level - 1] += count
            else:
                ai_incorrects[item.level - 1] += count

        normal_all = [normal_corrects[0] + normal_incorrects[0], normal_corrects[1] + normal_incorrects[1], normal_corrects[2] + normal_incorrects[2]]
        ai_all = [ai_corrects[0] + ai_incorrects[0], ai_corrects[1] + ai_incorrects[1], ai_corrects[2] + ai_incorrects[2]]
        
        normal_rate = [0, 0, 0]
        ai_rate = [0, 0, 0]
        for i in range(3):
            if normal_all[i] != 0:
                normal_rate[i] = (normal_incorrects[i]/float(normal_all[i]) * 100)
            if ai_all[i] != 0:
                ai_rate[i] = (ai_incorrects[i]/float(ai_all[i]) * 100)
        

        information["seasons"].append({"season":rm.released_season,
                                       "incorrect_rate_normal":normal_rate,
                                       "incorrect_rate_ai":ai_rate,
                                       "released_level":rm.released_level,
                                       "released_step":rm.released_step
                                       })

    return {'detail':information}
