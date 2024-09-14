from datetime import datetime, timedelta
from jose import jwt
from sqlalchemy import select
from auth.constants import ALGORITHM, SECRET_KEY
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Released, Groups, ReleasedGroup
from auth.schemas import CreateUser
from auth.utils import get_password_hash
from auth.dependencies import db_dependency

# Create Token (No async)
def create_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : user_id, 'role': role} 
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# Create user
async def create_user_in_db(db: db_dependency, create_user: CreateUser) -> Users:
    hashed_password = get_password_hash(create_user.password)
    new_user = Users(
        username=create_user.username,
        name=create_user.name,
        role=create_user.role,
        question=create_user.question,
        questionType=create_user.questionType,
        hashed_password=hashed_password
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

# Create StudyInfo
async def create_study_info(db: db_dependency, user_id: int):
    study_info = StudyInfo(
        owner_id=user_id,
        totalStudyTime=0,
        streamStudyDay=0
    )
    db.add(study_info)
    await db.commit()

# Create Released
async def create_released(db, user_id: int, seasons: list):
    for season in seasons:
        released = Released(
            owner_id=user_id,
            released_season=season,
            released_level=0,
            released_step=0
        )
        db.add(released)
    await db.commit()

# Get Username in db
async def get_user_to_username(username: str, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.username == username))
    return result.scalars().first()

# Helper function to fetch user data
async def fetch_user_data(db, user_id):
    result = await db.execute(select(Users).filter(Users.id == user_id))
    return result.scalars().first()

# Helper function to fetch released data
async def fetch_released_data(db, owner_id):
    result = await db.execute(select(Released).filter(Released.owner_id == owner_id))
    released_model = result.scalars().all()
    return [{'season': r.released_season, 'level': r.released_level, 'step': r.released_step} for r in released_model]

# Helper function to fetch group and released group data
async def fetch_group_and_released_group_data(db, team_id):
    group_result = await db.execute(select(Groups).where(Groups.id == team_id))
    group_model = group_result.scalars().first()
    
    if group_model is None:
        return None, None
    
    released_group_result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == team_id))
    released_group_model = released_group_result.scalars().all()
    released_group = [{'season': rg.released_season, 'level': rg.released_level, 'step': rg.released_step, 'type': rg.released_type} for rg in released_group_model]
    
    return group_model.name, released_group