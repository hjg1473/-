from sqlalchemy import select
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users

# Helper function to fetch user data
async def get_user_by_id(user_id, db):
    result = await db.execute(select(Users).filter(Users.id == user_id))
    return result.scalars().first()