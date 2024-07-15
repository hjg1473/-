from sqlalchemy import select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users, StudyInfo
from student.dependencies import user_dependency, db_dependency
from student.exceptions import get_user_exception, get_user_exception2, auth_exception, http_exception, select_exception1, select_exception2, select_exception3

router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)

# 학생과 선생님 연결, 학생 -> 선생님(student_teachers) / 선생님 -> 학생(teachers_students) ?
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


# 학생(self)과 연결된 선생님 아이디 반환
@router.get("/connect_teacher", status_code = status.HTTP_200_OK)
async def read_connect_teacher(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    
    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    teacher = result.scalars().first()

    return {"teachers": [{"id": teacher.id} for teacher in teacher.student_teachers]}


# 학생 정보 반환
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_info(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    return {'name': user_model.name, 'age': user_model.age, 'team_id': user_model.team_id}

# 사용자의 id 반환, self
@router.get("/id", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))
    
    return  {"id": user.get('id')}

# 학생의 self 학습 정보 반환.
@router.get("/studyinfo", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(user: user_dependency, db: db_dependency):

    get_user_exception(user)
    auth_exception(user.get('user_role'))

    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    result2 = await db.execute(select(StudyInfo).options(
        joinedload(StudyInfo.correct_problems),
        joinedload(StudyInfo.incorrect_problems)
        ).filter(StudyInfo.id == user.get("id")))
    study_info = result2.scalars().first()
    
    correct_problems_type1_count = 0
    correct_problems_type2_count = 0
    correct_problems_type3_count = 0
    incorrect_problems_type1_count = 0
    incorrect_problems_type2_count = 0
    incorrect_problems_type3_count = 0
    
    for problem in study_info.correct_problems:
        if problem.type == '부정문':
            correct_problems_type1_count += 1
        elif problem.type == '의문문':
            correct_problems_type2_count += 1
        elif problem.type == '어순과격':
            correct_problems_type3_count += 1

    for problem in study_info.incorrect_problems:
        if problem.type == '부정문':
            incorrect_problems_type1_count += 1
        elif problem.type == '의문문':
            incorrect_problems_type2_count += 1
        elif problem.type == '어순과격':
            incorrect_problems_type3_count += 1

    return {
        'user_id': user_model.id,
        'name': user_model.username,
        'age': user_model.name,
        'type1_True_cnt' : correct_problems_type1_count,
        'type2_True_cnt' : correct_problems_type2_count,
        'type3_True_cnt' : correct_problems_type3_count,
        'type1_False_cnt' : incorrect_problems_type1_count,
        'type2_False_cnt' : incorrect_problems_type2_count,
        'type3_False_cnt' : incorrect_problems_type3_count }
