import sys, os
from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from user.dependencies import db_dependency

async def get_user_to_email(username: str, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.username == username))
    return result.scalars().first()