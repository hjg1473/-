from typing import Annotated, List
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
    prefix="/super",
    tags=["super"],
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

@router.get("/info", status_code = status.HTTP_200_OK)
async def read_info(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()

    user_model = db.query(Users.id, Users.username, Users.email, Users.phone_number).filter(Users.id == user.get('id')).first()
    user_model_json = { "id": user_model[0], "username": user_model[1], "email": user_model[2], "phone_number": user_model[3] }
    return user_model_json
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면, 해당 학습 정보 반환.
    # 사용자의 id, username, email, phone_number 반환

@router.get("/group/{class_number}", status_code = status.HTTP_200_OK)
async def read_group_info(class_number: int,
                    user: user_dependency,
                    db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    if user is None or user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')

    user_group = db.query(Users)\
        .filter(Users.group == class_number)\
        .all()
    
    result = [{'id': u.id, 'name': u.name,'age': u.age} for u in user_group]
    
    return result

# class dashboardOutput(BaseModel):
#     id: int
#     username: str
#     age: int
#     studyinfo: List[str] = []

# # 각 학급에 있는 학생들 조회
# @router.get("/dashboard/{class_number}")
# async def read_dashboard(class_number: int,
#                     user: user_dependency,
#                     db: db_dependency):
    
#     if user is None or user.get('user_role') != 'super': # super 인 경우만 
#         raise HTTPException(status_code=401, detail='Authentication Failed')
    
#     # 반 별로 학생들의 id, username, age 추출 (여러 명)
#     user_group = db.query(Users)\
#         .filter(Users.group == class_number)\
#         .all()
    
#     # output 리스트
#     userlist = []
#     # 각 학생들의 학습 정보를 반복해서 추출함.
#     for usergroup in user_group:
#         study_info = db.query(StudyInfo).options(
#         joinedload(StudyInfo.correct_problems),
#         joinedload(StudyInfo.incorrect_problems)
#     ).filter(StudyInfo.id == usergroup.id).all()

#     # 변환된 study_info를 저장할 리스트
#         transformed_study_info = []

#         for study in study_info:
#         # 각 correct_problems에서 type과 id만 추출
#             correct_problems_info = [{"type": problem.type, "id": problem.id} for problem in study.correct_problems]
#         # 각 incorrect_problems에서 type과 id만 추출
#             incorrect_problems_info = [{"type": problem.type, "id": problem.id} for problem in study.incorrect_problems]
        
#         # 변환된 정보를 새로운 study_info로 만듦
#             transformed_study_info.append({
#             "correct_problems": correct_problems_info,
#             "incorrect_problems": incorrect_problems_info
#             })

#             userlist.append({
#             "id": usergroup.id,
#             "username": usergroup.username,
#             "age": usergroup.age,
#             "studyinfo": transformed_study_info
#             })

#     return userlist


# 선생님이 학생 개인의 정보를 살펴볼 때
@router.get("/searchStudyinfo/{user_id}", status_code = status.HTTP_200_OK)
async def read_user_studyInfo_all(user: user_dependency, db: db_dependency, user_id : int):
    if user is None:
        raise get_user_exception()
    
    if user is None or user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')


    user_model = db.query(Users.id, Users.username, Users.age, Users.group).filter(Users.id == user_id).first()
    
    if user_model is None:
        raise http_exception()

    study_info = db.query(StudyInfo).options(
        joinedload(StudyInfo.correct_problems),
        joinedload(StudyInfo.incorrect_problems)
    ).filter(StudyInfo.id == user_id).first()

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

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
