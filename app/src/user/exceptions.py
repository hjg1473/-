from fastapi import HTTPException
from user.utils import bcrypt_context

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }

def http_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Not Found")

async def email_exception(email: str, db):
    from user.service import get_user_to_email
    user = await get_user_to_email(email, db)
    if user:
        raise HTTPException(status_code=409, detail="중복된 이메일입니다.")

def password_exception(password, hashed_password):
    if not bcrypt_context.verify(password, hashed_password):
        raise HTTPException(status_code=409, detail="비밀번호가 틀렸습니다.")

def user_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail='Authentication Failed')