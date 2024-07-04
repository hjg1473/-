from typing import Annotated
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from routers.auth import get_current_user, get_user_exception

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]


# 학생과 선생님 연결 요청, 학생 -> 선생님(student_teachers) / 선생님 -> 학생(teachers_students) ?
@router.get("/connecting", status_code = status.HTTP_200_OK)
async def connect_teacher(
    teacher_id: int,
    user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)):

    if user is None:
        raise get_user_exception()

    # 학생 정보 가져오기
    student = db.query(Users).filter(Users.id == user.get("id")).first()
    
    if not student:
        raise get_user_exception()

    if teacher_id == user.get("id"):
        raise HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')
    
    # 쿼리 파라미터로 받은 teacher_id 또는 teacher_username을 사용해 선생님 검색
    teacher = db.query(Users).filter(Users.id == teacher_id).first()

    if not teacher:
        raise HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')

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
async def read_user_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    # 쿼리 검색
    teacher = db.query(Users).options( 
        joinedload(Users.student_teachers)
    ).filter(Users.id == user.get("id")).first()

    # if not teacher.student_teachers: # 없으면 not found.
    #     raise http_exception()
    
    # {"teachers": [{"id": teacher.id} for teacher in teacher.student_teachers]}

    return {"teachers": [{"id": teacher.id} for teacher in teacher.student_teachers]}

@router.get("/", status_code = status.HTTP_200_OK)
async def read_user_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    return db.query(Users).all()

@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    return db.query(Users).filter(Users.id == user.get('id')).first()
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면,
    # 사용자의 모든 정보 반환.

    # Join 해서 학습 정보를 반환해야됨. + 노출되는 정보 필터링

# 사용자의 id 반환, self
@router.get("/id", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    return  {"id": user.get('id')}
    # 사용자의 id 반환.

# 학생의 self 학습 정보 반환.
@router.get("/studyinfo", status_code = status.HTTP_200_OK)
async def read_studyinfo_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()

    user_model = db.query(Users.id, Users.username, Users.age, Users.group).filter(Users.id == user.get('id')).first()

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
    
    # 조금 수정을 원해
    if study_info:
        correct_problems_type1_count = sum(1 for problem in study_info.correct_problems if problem.type == '부정문')
        correct_problems_type2_count = sum(1 for problem in study_info.correct_problems if problem.type == '의문문')
        correct_problems_type3_count = sum(1 for problem in study_info.correct_problems if problem.type == '단어와품사')
        incorrect_problems_type1_count = sum(1 for problem in study_info.correct_problems if problem.type == '부정문')
        incorrect_problems_type2_count = sum(1 for problem in study_info.correct_problems if problem.type == '의문문')
        incorrect_problems_type3_count = sum(1 for problem in study_info.correct_problems if problem.type == '단어와품사')

    return {
        'user_id': user_model[0],
        'name': user_model[1],
        'age': user_model[2],
        'class': user_model[3],
        'type1_True_cnt' : correct_problems_type1_count,
        'type2_True_cnt' : correct_problems_type2_count,
        'type3_True_cnt' : correct_problems_type3_count,
        'type1_False_cnt' : incorrect_problems_type1_count,
        'type2_False_cnt' : incorrect_problems_type2_count,
        'type3_False_cnt' : incorrect_problems_type3_count }

@router.get("/{user_id}", status_code = status.HTTP_200_OK)
async def read_user_studyInfo_all(user: user_dependency, db: db_dependency, user_id : int):
    if user is None:
        raise get_user_exception()
    
    studyinfo_model = db.query(StudyInfo)\
        .filter(StudyInfo.owner_id == user_id)\
        .first()
    if studyinfo_model is not None:
        return studyinfo_model
    raise http_exception()
    # 학습 정보의 owner_id 와 요청한 '유저'의 id가 같으면, 해당 학습 정보 반환.
    # 아직 문제 id만 갖는 상태(Join 안됨)
    # 자신의 학습 기록을 요청하는 API

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
