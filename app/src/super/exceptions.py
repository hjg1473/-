from fastapi import HTTPException
<<<<<<< HEAD
from service import get_problemset, get_group_name
from dependencies import user_dependency
=======
from super.service import get_problemset
from super.dependencies import db_dependency, user_dependency
>>>>>>> ed8b104e7030b3dcf0a560d466645ff37fe8011e
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from auth.exceptions import get_user_exception


def http_exception():
    return HTTPException(status_code=404, detail="Not found")

# 필요없는 코드인가
def user_authenticate_exception(user: user_dependency):
    if user is None:
        raise get_user_exception()
    

def super_authenticate_exception(user):
    if user is None:
        raise get_user_exception()
    if user.get('user_role') != 'super':
        raise HTTPException(status_code=401, detail='학부모 계정이 아닙니다')
    

async def problem_exists_exception(problemset):
    custom_problem_set = await get_problemset(problemset)
    if custom_problem_set:
        raise HTTPException(status_code=404, detail='같은 이름의 문제 세트가 존재합니다.')


async def existing_name_exception(addgroup):
    group_name = await get_group_name(addgroup)
    if group_name is not None:
        raise HTTPException(status_code=404, detail='같은 이름의 방이 존재합니다.')
    

