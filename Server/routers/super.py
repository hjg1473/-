from typing import Annotated, List
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo, Groups
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


# 해당 선생님이 관리하는 반 조회
@router.get("/group", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency,
                    db: db_dependency):
    
    if user is None:
        raise get_user_exception()

    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')

    user_group = db.query(Groups)\
        .filter(Groups.admin_id == user.get("id"))\
        .all()
    
    if not user_group: # if user_group is None -> return []
        raise HTTPException(status_code=401, detail='Not found.')
    
    result = [{'id': u.id, 'name': u.name} for u in user_group]
    
    return result

class AddGroup(BaseModel):
    name: str

# 해당 선생님이 관리하는 반 추가
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def user_solve_problem(addgroup: AddGroup, 
                            user: user_dependency, db: db_dependency):
    
    if user is None:
        raise get_user_exception()

    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    # 기존에 중복된 반 이름이 존재한다? # A선생님 1반, B선생님 1반 은 상관 없음.
    group_name = db.query(Groups)\
        .filter(Groups.name == addgroup.name)\
        .filter(Groups.admin_id == user.get("id"))\
        .first()
    
    if group_name is not None:
        raise HTTPException(status_code=404, detail='같은 이름의 방이 존재합니다.')
    
    group_model = models.Groups()
    group_model.name = addgroup.name
    group_model.admin_id = user.get("id")

    
    db.add(group_model)
    db.commit()

    return {'detail':'Success'}

# 특정 반에 속한 학생들의 정보 조회
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_info(group_id: int,
                    user: user_dependency,
                    db: db_dependency):
    if user is None:
        raise get_user_exception()

    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    # 팀 아이디가 그룹 아이디랑 같다
    user_group = db.query(Users)\
        .filter(Users.team_id == group_id)\
        .all()
    
    if not user_group: # if user_group is None -> return []
        raise HTTPException(status_code=401, detail='Not found.')
    
    result = [{'id': u.id, 'name': u.name} for u in user_group]
    
    return result

# 선생님이 관리하는 반에 학생 추가 : 학생의 외래키 업데이트. 어떤 반에?, 누구를?
@router.put("/group/{group_id}/update/{user_id}", status_code = status.HTTP_200_OK)
async def user_solve_problem(group_id: int,
                            user_id: int,
                            user: user_dependency, db: db_dependency):
    
    if user is None:
        raise get_user_exception()
    
    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    # 쿼리 변수로 해당 학생 db 검색
    student_model = db.query(models.Users)\
        .filter(models.Users.id == user_id)\
        .first()
    
    # 학생이 없으면 예외 처리
    if student_model is None:
        raise HTTPException(status_code=404, detail='해당 학생을 찾을 수 없습니다.')
    
    # 입력한 group_id 에 해당하는 반을 검색
    group_model = db.query(models.Groups)\
        .filter(models.Groups.id == group_id)\
        .first()    
    
    # 반이 없으면 예외 처리
    if group_model is None:
        raise HTTPException(status_code=404, detail='해당 반을 찾을 수 없습니다.')
    
    if student_model.team_id is not None:
        raise HTTPException(status_code=404, detail='해당 학생은 이미 소속된 반이 존재합니다.')

    # 학생 team_id 에 해당 group_id 를 할당
    student_model.team_id = group_id

    db.add(student_model)
    db.commit()

    return {'detail' : 'Success'}

# 해당 학생의 소속된 '반' 없앰
@router.put("/group/remove/{user_id}", status_code = status.HTTP_200_OK)
async def user_solve_problem(user_id: int,
                            user: user_dependency, db: db_dependency):
    
    if user is None:
        raise get_user_exception()
    
    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    # 쿼리 변수로 해당 학생 db 검색
    student_model = db.query(models.Users)\
        .filter(models.Users.id == user_id)\
        .first()
    
    # 학생이 없으면 예외 처리
    if student_model is None:
        raise HTTPException(status_code=404, detail='해당 학생을 찾을 수 없습니다.')
    
    # 학생 team_id 에 해당 Null값을 할당
    student_model.team_id = None

    db.add(student_model)
    db.commit()

    return {'detail' : 'Success'}

# 선생님의 정보 반환, self
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_info(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()

    user_model = db.query(Users.id, Users.username, Users.email, Users.phone_number).filter(Users.id == user.get('id')).first()
    user_model_json = { "id": user_model[0], "username": user_model[1], "email": user_model[2], "phone_number": user_model[3] }
    return user_model_json
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면, 해당 학습 정보 반환.
    # 사용자의 id, username, email, phone_number 반환

# '각 반'을 기준으로 필터링한 결과 반환 (선생님 id 로 필터링 추가 필요)
@router.get("/group/{class_number}", status_code = status.HTTP_200_OK)
async def read_group_info(class_number: int,
                    user: user_dependency,
                    db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')

    user_group = db.query(Users)\
        .filter(Users.group == class_number)\
        .all()
    
    if not user_group: # if user_group is None -> return []
        raise HTTPException(status_code=401, detail='Not found.')
    
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
    
    if user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')


    user_model = db.query(Users.id, Users.username, Users.age, Users.group).filter(Users.id == user_id).first()
    
    if user_model is None:
        raise http_exception()

    study_info = db.query(StudyInfo).options(
        joinedload(StudyInfo.correct_problems),
        joinedload(StudyInfo.incorrect_problems)
    ).filter(StudyInfo.id == user_id).first()

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
