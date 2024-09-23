import sys, os
from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Released, StudyInfo

async def fetch_user_released(user_id, db):
    result = await db.execute(select(Released).filter(Released.owner_id == user_id))
    return result.scalars().all() 

async def fetch_user_studyInfo(user_id, db):
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()