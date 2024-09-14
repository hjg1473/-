from fastapi import HTTPException
from user.utils import bcrypt_context

def http_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Not Found")

def password_exception(password, hashed_password):
    if not bcrypt_context.verify(password, hashed_password):
        raise HTTPException(status_code=409, detail="비밀번호가 틀렸습니다.")

def user_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail='Authentication Failed')
    
def group_exception(group):
    if group:
        raise HTTPException(status_code=409, detail='반을 먼저 삭제해주세요!')