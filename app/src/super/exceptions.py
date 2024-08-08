from fastapi import HTTPException
from super.service import get_group_name
from super.dependencies import db_dependency, user_dependency
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from auth.exceptions import get_user_exception


def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def group_remove_exception():
    return HTTPException(status_code=400, detail="그룹에 학생이 존재합니다.")

# 필요없는 코드인가
def user_authenticate_exception(user: user_dependency):
    if user is None:
        raise get_user_exception()
    

# def custom_problem_exception(custom_problem_set):
#     if custom_problem_set is None:
#         raise HTTPException(status_code=404, detail="존재하지 않는 세트입니다.")

def super_authenticate_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")
    if user.get('user_role') != 'parent' and user.get('user_role') != 'teacher':
        raise HTTPException(status_code=401, detail='관리자 계정이 아닙니다')
    
def super_released_exception(target_released):
    if target_released is None:
        raise HTTPException(status_code=404, detail="관리자가 해당 시즌을 보유하고 있지 않습니다.")

def problem_found_exception(target_problems):
    if target_problems is None:
        raise HTTPException(status_code=404, detail="해당 스텝의 문제를 찾을 수 없습니다.")
    
def released_step_exception():
    return HTTPException(status_code=404, detail="해당 스텝을 해금할 수 없습니다.")
    
def group_count_exception(count):
    if count == 0:
        raise HTTPException(status_code=404, detail="학습 시간을 찾을 수 없습니다.")
# async def problem_exists_exception(problemset, db):
#     custom_problem_set = await get_problemset(problemset, db)
#     if custom_problem_set:
#         raise HTTPException(status_code=404, detail='같은 이름의 문제 세트가 존재합니다.')


async def existing_name_exception(addgroup, admin_id, db: db_dependency):
    group_name = await get_group_name(addgroup, admin_id, db)
    if group_name is not None:
        raise HTTPException(status_code=404, detail='같은 이름의 반이 존재합니다.')
    
async def find_student_exception(user_id, db):
    from super.service import get_user_to_userid
    user = await get_user_to_userid(user_id, db)
    if not user:
        raise HTTPException(status_code=404, detail="해당 학생을 찾을 수 없습니다.")

async def find_group_exception(group_id, db):
    from super.service import get_group_to_groupid
    group = await get_group_to_groupid(group_id, db)
    if group is None:
        raise HTTPException(status_code=404, detail="해당 반을 찾을 수 없습니다.")
    
def get_studyInfo_exception(correct_count, incorrect_count):
    if correct_count + incorrect_count == 0:
        raise HTTPException(status_code=404, detail="학습 정보가 기록되지 않았습니다.")
    
async def super_group_exception(user_id, group_id, db):
    from super.service import get_group_list
    group = await get_group_list(user_id, db)
    isGroup = False
    for g in group:
        if g.id == group_id:
            isGroup = True
    if not isGroup:
        raise HTTPException(status_code=403, detail="해당 반은 접근할 수 없습니다.")
    
def std_access_exception(group_list, std_team_id):
    isGroup = False
    for u in group_list:
        if u.id == std_team_id:
            isGroup = True
    if not isGroup:
        raise HTTPException(status_code=403, detail="해당 학생에 접근할 수 없습니다.")