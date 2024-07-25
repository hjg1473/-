from fastapi import APIRouter
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import ProblemSet, AddGroup
from super.exceptions import *
from starlette import status

router = APIRouter(
    prefix="/super",
    tags=["super"],
    responses={404: {"description": "Not found"}}
)

# 해당 선생님이 관리하는 반 조회
@router.get("/group", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    
    group_list = await get_group_list(user.get("id"), db)
    
    result = {'groups': [{'id': u.id, 'name': u.name, 'count': await get_std_group_count(u.id, db)} for u in group_list]}
    
    return result

# 해당 선생님이 관리하는 반 추가
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def create_solve_problem(addgroup: AddGroup, 
                            user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)
    # await existing_name_exception(addgroup.name, user.get('id'), db)

    await update_new_group(addgroup, user.get('id'), db)

    return {'detail':'Success'}

# 특정 반에 속한 학생들의 정보 조회
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_info(group_id: int,
                    user: user_dependency,
                    db: db_dependency):
    
    super_authenticate_exception(user)
    
    user_group = await get_std_info(group_id, db)
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in user_group] }
    
    return result

# 선생님이 관리하는 반에 학생 추가
@router.put("/group/{group_id}/update/{user_id}", status_code = status.HTTP_200_OK)
async def user_solve_problem(group_id: int,
                            user_id: int,
                            user: user_dependency,
                            db: db_dependency):
    super_authenticate_exception(user)
    await find_student_exception(user_id, db)
    await find_group_exception(group_id, db)
    await update_std_group(group_id, user_id, db)

    return {'detail' : 'Success'}

# 해당 학생의 소속된 '반' 없앰
@router.put("/group/remove/{user_id}", status_code = status.HTTP_200_OK)
async def update_user_team(user_id: int,
                            user: user_dependency,
                            db: db_dependency):
    super_authenticate_exception(user)
   
    await update_std_group(None, user_id, db)

    return {'detail' : 'Success'}

# 선생님이 관리하는 반의 step 및 level 해금
@router.put("/group/{group_id}/problems/add/{level}/{step}", status_code= status.HTTP_200_OK)
async def unlock_step_level(group_id: int, level:str, step:str, user:user_dependency, db:db_dependency):
    super_authenticate_exception(user)

    # check that level and step are valid.
    target_problems = await db.execute(select(Problems).filter(Problems.level == level, Problems.step == step)).scalars().all()

    if target_problems == None:
        raise http_exception()

    target_level_num = int(list(level)[-1])    # suppose level format == level1, level2, ...
    target_step_num = int(list(step)[-1])      # suppose step format == step1, step2, ...

    group_model = get_group_to_groupid(group_id, db)

    current_level = group_model.releasedLevel
    current_step = group_model.releasedStep
    
    current_level = int(list(current_level)[-1])
    current_step = int(list(current_step)[-1])

    if (target_level_num <= current_level) or (target_step_num <= current_step):
        raise http_exception()

    await update_group_level_and_step(group_id, level, step, db)

    return {'detail' : 'Success'}


# 반 정보 개괄 확인하기; 현재 학습 진행 정도, 학습 완료율, 명단
# @router.get("/group/{group_id}/info", status_code=status.HTTP_200_OK)
# async def read_group_info(group_id:int, user:user_dependency, db:db_dependency):
#     super_authenticate_exception(user)

#     find_group_exception(group_id, db)

#     group_model = await get_group_to_groupid(group_id)

#     released_level = group_model.releasedLevel
#     released_step = group_model.releasedStep

#     student_list = await get_std_info(group_id, db)

#     result = {
#         "released_level":released_level,
#         "released_step":released_step,
#         "students":student_list
#     }

#     return result

# 반 문제 해금 정보 확인하기
# @router.get("/group/{group_id}/problems/info", status_code=status.HTTP_200_OK)
# async def read_group_studylevel(group_id:int, user:user_dependency, db:db_dependency):
#     super_authenticate_exception(user)

#     find_group_exception(group_id, db)

#     group_model = await get_group_to_groupid(group_id, db)

#     rLevel = group_model.releasedLevel
#     rStep = group_model.releasedStep

#     # suppose level format == "level(x)", step format == "step(y)"
#     # parse the last character and cast to integer
    


# 선생님의 정보 반환, self
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_info(user: user_dependency, db: db_dependency):
    
    super_authenticate_exception(user)

    user_model_json = await get_super_info(user, db)

    return user_model_json


# 선생님이 커스텀 문제 생성
# @router.post("/create/custom_problems")
# async def create_problem(user: user_dependency, db:db_dependency, problemset: ProblemSet):
    
#     super_authenticate_exception(user)

#     problem_exists_exception(problemset, db)

#     await update_cproblem(problemset, db)

#     return {'detail': '성공적으로 생성되었습니다!'}

# # 만들어진 커스텀 문제 세트의 목록 조회
# @router.get("/custom_problem_set/info", status_code = status.HTTP_200_OK)
# async def read_group_info(user: user_dependency, db: db_dependency):
    
#     super_authenticate_exception(user)
    
#     custom_problem_set_list = await get_cproblem_list(db)
    
#     result = {'custom_problem_set':[{'name': name} for name in custom_problem_set_list]}
    
#     return result


# # 만들어진 커스텀 문제 세트 조회
# @router.get("/custom_problem_info/{set_name}", status_code = status.HTTP_200_OK)
# async def read_group_info(set_name: str, user: user_dependency, db: db_dependency):

#     super_authenticate_exception(user)

#     custom_problems = await get_cproblems(set_name, db)

#     return custom_problems

# @router.delete("/custom_problem_set_delete/{set_name}", status_code=status.HTTP_200_OK)
# async def delete_user(set_name: str, user: user_dependency, db: db_dependency):

#     super_authenticate_exception(user)
    
#     await delete_cproblem(set_name, db)

#     return {"detail": '성공적으로 삭제되었습니다.'}

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
