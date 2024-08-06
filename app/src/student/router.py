import json
import aioredis
from sqlalchemy import delete, select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users, StudyInfo, Released
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

    return {'name': user_model.name, 'team_id': user_model.team_id}

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
    
    return {'detail':'미완'}
