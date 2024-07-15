import asyncio
import sys, os

from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from auth.constants import SECRET_KEY, ALGORITHM
from auth.exceptions import get_user_exception
from passlib.context import CryptContext
from jose import jwt, JWTError

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return bcrypt_context.hash(password)

def verify_password_sync(plain_password, hashed_password):
    return bcrypt_context.verify(plain_password, hashed_password)

# 동기함수를 run_in_executor 를 통해 비동기 함수로 
async def verify_password(plain_password, hashed_password): 
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, verify_password_sync, plain_password, hashed_password)

async def authenticate_user(username: str, password: str, db):
    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalars().first()
    if not user:
        return False
    password_vaild = await verify_password(password, user.hashed_password)
    if not password_vaild:
        return False
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
