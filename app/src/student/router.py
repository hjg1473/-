from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends
from starlette import status
from database import engine
from sqlalchemy.orm import Session
from fastapi.templating import Jinja2Templates

import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.auth.router import get_current_user
from app.src.models import Users, StudyInfo
import app.src.models as models
from student.dependencies import user_dependency, db_dependency, get_db
from exceptions import auth_user_exception, auth_student_exception, teacher_exception

router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)


# 학생과 선생님 연결 요청, 학생 -> 선생님(student_teachers) / 선생님 -> 학생(teachers_students) ?
@router.get("/connecting", status_code = status.HTTP_200_OK)
async def connect_teacher(teacher_id: int,
            user: dict = Depends(get_current_user),
            db: Session = Depends(get_db)):

    auth_user_exception(user)

    # 학생 정보 가져오기
    student = db.query(Users).filter(Users.id == user.get("id")).first()
    auth_student_exception(student)

    # 쿼리 파라미터로 받은 teacher_id 또는 teacher_username을 사용해 선생님 검색
    teacher = db.query(Users).filter(Users.id == teacher_id).first()
    teacher_exception(teacher, user)

    # 학생과 선생님이 이미 연결되어 있는지 확인
    if teacher in student.student_teachers:
        return {"message": "Already connected"}

    # 새로운 연결 생성
    student.student_teachers.append(teacher)
    # db.add(student) # ORM 방식은 append 할 때 자동으로 해줌
    db.commit()
    return {"message": "Connected successfully", "teacher_id": teacher.id, "teacher_username": teacher.username}


# 학생(self)과 연결된 선생님 아이디 반환
@router.get("/connect_teacher", status_code = status.HTTP_200_OK)
async def read_connect_teacher(user: user_dependency, db: db_dependency):

    auth_user_exception(user)
    # 쿼리 검색
    teacher = db.query(Users).options( 
        joinedload(Users.student_teachers)
    ).filter(Users.id == user.get("id")).first()

    # if not teacher.student_teachers: # 없으면 not found.
    #     raise http_exception()
    
    # {"teachers": [{"id": teacher.id} for teacher in teacher.student_teachers]}

    return {"teachers": [{"id": teacher.id} for teacher in teacher.student_teachers]}


# 학생 정보 반환
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_info(user: user_dependency, db: db_dependency):

    auth_student_exception(user)
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    return {'name': user_model.name, 'age': user_model.age, 'team_id': user_model.team_id}
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면,
    # 사용자의 모든 정보 반환.

    # Join 해서 학습 정보를 반환해야됨. + 노출되는 정보 필터링


# 사용자의 id 반환, self
@router.get("/id", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency, db: db_dependency):

    auth_student_exception(user)
    return  {"id": user.get('id')}
    # 사용자의 id 반환.


# 학생의 self 학습 정보 반환.
@router.get("/studyinfo", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(user: user_dependency, db: db_dependency):

    auth_student_exception(user)
    user_model = db.query(Users.id, Users.username, Users.age).filter(Users.id == user.get('id')).first()

    study_info = db.query(StudyInfo).options(
        joinedload(StudyInfo.correct_problems),
        joinedload(StudyInfo.incorrect_problems)
    ).filter(StudyInfo.id == user.get("id")).first()

    # 초기화
    correct_problems_type1_count = 0
    correct_problems_type2_count = 0
    correct_problems_type3_count = 0
    incorrect_problems_type1_count = 0
    incorrect_problems_type2_count = 0
    incorrect_problems_type3_count = 0
    
    # 조금 수정을 원해, 매번 확인한다? 조금 그렇긴 해
    for problem in study_info.correct_problems:
        if problem.type == '부정문':
            correct_problems_type1_count += 1
        elif problem.type == '의문문':
            correct_problems_type2_count += 1
        elif problem.type == '단어와품사':
            correct_problems_type3_count += 1

    for problem in study_info.incorrect_problems:
        if problem.type == '부정문':
            incorrect_problems_type1_count += 1
        elif problem.type == '의문문':
            incorrect_problems_type2_count += 1
        elif problem.type == '단어와품사':
            incorrect_problems_type3_count += 1

    return {
        'user_id': user_model[0],
        'name': user_model[1],
        'age': user_model[2],
        'type1_True_cnt' : correct_problems_type1_count,
        'type2_True_cnt' : correct_problems_type2_count,
        'type3_True_cnt' : correct_problems_type3_count,
        'type1_False_cnt' : incorrect_problems_type1_count,
        'type2_False_cnt' : incorrect_problems_type2_count,
        'type3_False_cnt' : incorrect_problems_type3_count }
