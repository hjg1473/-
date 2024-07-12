from fastapi import HTTPException
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.auth.exceptions import get_user_exception


def auth_failed():
    return HTTPException(status_code=401, detail='Authentication Failed')

def not_found_default():
    return HTTPException(status_code=404, detail="Not found")

def not_found_teacher():
    return HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')

def not_found_self():
    return HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')
