from fastapi import APIRouter, HTTPException
from sqlalchemy.orm import joinedload
from sqlalchemy import select
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import CustomProblem, ProblemSet, AddGroup
from super.exceptions import *
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.schemas import CustomProblem, ProblemSet, AddGroup
from app.src.models import Users, StudyInfo, Groups, Problems, CustomProblemSet
from starlette import status


router = APIRouter(
    prefix="/super",
    tags=["super"],
    responses={404: {"description": "Not found"}}
)

# 선생님이 커스텀 문제 생성
@router.post("/create/custom_problems")
async def create_problem(problemset: ProblemSet):
    
    super_authenticate_exception()
    problem_exists_exception(problemset)

    await update_cproblem(problemset)

    return {'detail': '성공적으로 생성되었습니다!'}

# 만들어진 커스텀 문제 세트의 목록 조회
@router.get("/custom_problem_set/info", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency,):
    
    super_authenticate_exception(user)
    
    custom_problem_set_list = await get_cproblem_list()
    
    result = {'custom_problem_set':[{'name': name} for name in custom_problem_set_list]}
    
    return result


# 만들어진 커스텀 문제 세트 조회
@router.get("/custom_problem_info/{set_name}", status_code = status.HTTP_200_OK)
async def read_group_info(set_name: str,
                    user: user_dependency):
    
    user_authenticate_exception(user)

    custom_problems = await get_cproblems(set_name)
    
    return custom_problems


@router.delete("/custom_problem_set_delete/{set_name}", status_code=status.HTTP_200_OK)
async def delete_user(set_name: str, user: user_dependency):

    user_authenticate_exception(user)

    await delete_cproblem(set_name)

    return {"detail": '성공적으로 삭제되었습니다.'}

# 해당 선생님이 관리하는 반 조회
@router.get("/group", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency):
    
    super_authenticate_exception(user)
    
    group_list = await get_group_list(user.get("id"))
    
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in group_list] }
    
    return result

# 해당 선생님이 관리하는 반 추가
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def create_solve_problem(addgroup: AddGroup, 
                            user: user_dependency):
    
    super_authenticate_exception(user)
    await existing_name_exception(addgroup)

    await update_new_group(addgroup, user)

    return {'detail':'Success'}

# 특정 반에 속한 학생들의 정보 조회
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_info(group_id: int,
                    user: user_dependency):
    
    super_authenticate_exception(user)
    
    user_group = await get_std_info(group_id)
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in user_group] }
    
    return result


@router.put("/group/{group_id}/update/{user_id}", status_code = status.HTTP_200_OK)
async def user_solve_problem(group_id: int,
                            user_id: int,
                            user: user_dependency):
    super_authenticate_exception(user)
    
    await update_std_group(group_id, user_id)

    return {'detail' : 'Success'}

# 해당 학생의 소속된 '반' 없앰
@router.put("/group/remove/{user_id}", status_code = status.HTTP_200_OK)
async def update_user_team(user_id: int,
                            user: user_dependency):
    super_authenticate_exception(user)
   
    await update_std_group(None, user_id)

    return {'detail' : 'Success'}


# 선생님의 정보 반환, self
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_info(user: user_dependency):
    
    user_authenticate_exception(user)

    user_model_json = await get_super_info(user)

    return user_model_json




# # 선생님이 학생 개인의 정보를 살펴볼 때
# @router.get("/searchStudyinfo/{user_id}", status_code = status.HTTP_200_OK)
# async def read_select_user_studyInfo(user: user_dependency, db: db_dependency, user_id : int):
    
#     super_authenticate_exception(user)

#     user_model = db.query(Users.id, Users.username, Users.age).filter(Users.id == user_id).first()
    
#     if user_model is None:
#         raise http_exception()

#     study_info = db.query(StudyInfo).options(
#         joinedload(StudyInfo.correct_problems),
#         joinedload(StudyInfo.incorrect_problems)
#     ).filter(StudyInfo.id == user_id).first()

#     # 초기화
#     correct_problems_type1_count = 0
#     correct_problems_type2_count = 0
#     correct_problems_type3_count = 0
#     incorrect_problems_type1_count = 0
#     incorrect_problems_type2_count = 0
#     incorrect_problems_type3_count = 0

#     # 조금 수정을 원해, 매번 확인한다? 조금 그렇긴 해
#     for problem in study_info.correct_problems:
#         if problem.type == '부정문':
#             correct_problems_type1_count += 1
#         elif problem.type == '의문문':
#             correct_problems_type2_count += 1
#         elif problem.type == '단어와품사':
#             correct_problems_type3_count += 1

#     for problem in study_info.incorrect_problems:
#         if problem.type == '부정문':
#             incorrect_problems_type1_count += 1
#         elif problem.type == '의문문':
#             incorrect_problems_type2_count += 1
#         elif problem.type == '단어와품사':
#             incorrect_problems_type3_count += 1

#     return {
#         'user_id': user_model[0],
#         'name': user_model[1],
#         'age': user_model[2],
#         'type1_True_cnt' : correct_problems_type1_count,
#         'type2_True_cnt' : correct_problems_type2_count,
#         'type3_True_cnt' : correct_problems_type3_count,
#         'type1_False_cnt' : incorrect_problems_type1_count,
#         'type2_False_cnt' : incorrect_problems_type2_count,
#         'type3_False_cnt' : incorrect_problems_type3_count }
