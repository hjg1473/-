from datetime import datetime, timedelta
from jose import jwt
from sqlalchemy import select
from auth.constants import ALGORITHM, SECRET_KEY
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo
from auth.schemas import CreateUser
from auth.utils import get_password_hash
from auth.dependencies import db_dependency

# 토큰 생성 (비동기로 작업할 필요x)
def create_access_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : user_id, 'role': role} 
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# 리프레시 토큰 생성
def create_refresh_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : '', 'role': ''}
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)


async def create_user_in_db(db: db_dependency, create_user: CreateUser) -> Users:
    hashed_password = get_password_hash(create_user.password)
    new_user = Users(
        username=create_user.username,
        name=create_user.name,
        age=create_user.age,
        role=create_user.role,
        email=create_user.email,
        hashed_password=hashed_password
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user
    
async def create_study_info(db: db_dependency, user_id: int):
    study_info = StudyInfo(
        owner_id=user_id,
        type1Level=0,
        type2Level=0,
        type3Level=0
    )
    db.add(study_info)
    await db.commit()

async def get_user_to_username(create_user: str, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.username == create_user))
    return result.scalars().first()