import aioredis
import sys, os
import random

from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from auth.constants import SECRET_KEY, ALGORITHM
from auth.schemas import CustomResponseException
from auth.exceptions import get_user_exception
from passlib.context import CryptContext
from jose import jwt, JWTError

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


async def create_pin_number():
    min_val = 0
    max_val = 999999
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    while True:
        pin = '{:06d}'.format(random.randint(min_val, max_val))
        if not await redis_client.exists(pin):
            return pin 

def get_password_hash(password):
    return bcrypt_context.hash(password)

def verify_password_sync(plain_password, hashed_password):
    return bcrypt_context.verify(plain_password, hashed_password)

async def authenticate_user(username: str, password: str, db):
    from auth.service import find_user_by_username
    user = await find_user_by_username(username ,db)

    if not user:
        raise CustomResponseException(code=200, content={"username_correct": False, "password_correct": False})
    
    password_vaild = verify_password_sync(password, user.hashed_password)
    if not password_vaild:
        raise CustomResponseException(code=200, content={"username_correct": True, "password_correct": False})
    
    return user

def decode_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        return None

def validate_token_payload(payload: dict):
    username = payload.get('sub')
    user_id = payload.get('id')
    user_role = payload.get('role')
    get_user_exception(username or user_id)
    return username, user_id, user_role
