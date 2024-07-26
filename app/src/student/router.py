import aioredis
from sqlalchemy import select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users, StudyInfo
from student.dependencies import user_dependency, db_dependency
from student.exceptions import get_user_exception, get_user_exception2, auth_exception, http_exception, select_exception1, select_exception2, select_exception3
from student.schemas import PinNumber
from app.src.super.exceptions import find_student_exception, find_group_exception
from app.src.super.service import update_std_group
router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)


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

# 학생과 학부모 연결, 학생 -> 학부모(student_teachers) / 학부모 -> 학생(teachers_students) ?
@router.get("/connecting", status_code = status.HTTP_200_OK)
async def connect_teacher(teacher_id: int, user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))

    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    student = result.scalars().first()
    
    get_user_exception2(student)
    select_exception1(teacher_id, user.get("id"))
    
    result2 = await db.execute(select(Users).filter(Users.id == teacher_id))
    teacher = result2.scalars().first()

    select_exception2(teacher)
    select_exception3(teacher, student.student_teachers)

    student.student_teachers.append(teacher)
    await db.commit()
    return {"detail": "Connected successfully", "teacher_id": teacher.id, "teacher_username": teacher.username}


# 학생(self)과 연결된 학부모의 아이디 반환
@router.get("/connect_parent", status_code = status.HTTP_200_OK)
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

    return {'name': user_model.name, 'age': user_model.age, 'team_id': user_model.team_id, 'released_season': user_model.released_season}

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
    
    return 
