from fastapi import HTTPException
from super.service import get_problemset, get_group_name
from super.dependencies import db_dependency, user_dependency
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from auth.exceptions import get_user_exception


def http_exception():
    return HTTPException(status_code=404, detail="Not found")

# 필요없는 코드인가
def user_authenticate_exception(user: user_dependency):
    if user is None:
        raise get_user_exception()
    

def custom_problem_exception(custom_problem_set):
    if custom_problem_set is None:
        raise HTTPException(status_code=404, detail="존재하지 않는 세트입니다.")

def super_authenticate_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")
    if user.get('user_role') != 'super':
        raise HTTPException(status_code=401, detail='학부모 계정이 아닙니다')
    

async def problem_exists_exception(problemset, db):
    custom_problem_set = await get_problemset(problemset, db)
    if custom_problem_set:
        raise HTTPException(status_code=404, detail='같은 이름의 문제 세트가 존재합니다.')


async def existing_name_exception(addgroup, admin_id, db=db_dependency):
    group_name = await get_group_name(addgroup, admin_id, db)
    if group_name is not None:
        raise HTTPException(status_code=404, detail='같은 이름의 방이 존재합니다.')
    

