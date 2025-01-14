from sqlalchemy import delete, select
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from user.dependencies import user_dependency, db_dependency
from user.schemas import UserQuitVerification, UserVerification, User_info
from user.service import get_user_by_id
from user.utils import *
from user.exceptions import http_exception, password_exception, user_exception, group_exception

router = APIRouter(
    prefix='/users', 
    tags=['users']
)


@router.put("/password", status_code=status.HTTP_200_OK)
async def change_password(user: user_dependency, db: db_dependency, user_verification: UserVerification):
    # User is None.
    user_exception(user)
    user_model = await get_user_by_id(user.get("id"), db)
    # Password InCorrect
    password_exception(user_verification.password, user_model.hashed_password)
    
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    db.add(user_model)
    await db.commit()
    return 

@router.put("/update", status_code=status.HTTP_200_OK)
async def update_user_info(user: user_dependency, db: db_dependency, user_info: User_info):
    user_exception(user)
    user_model = await get_user_by_id(user.get("id"), db)
    http_exception(user_model)
    user_model.name=user_info.name

    db.add(user_model)
    await db.commit()
    return 

@router.delete("/quit/", status_code=status.HTTP_200_OK)
async def delete_user(user: user_dependency, db: db_dependency, user_verification: UserQuitVerification):
    user_exception(user)
    user_model = await get_user_by_id(user.get("id"), db)
    http_exception(user_model)

    from app.src.super.service import get_group_list
    # Group deletion must come first.
    if user_model.role == 'teacher':
        group_list = await get_group_list(user.get("id"), db)
        group_exception(group_list)
        
    password_exception(user_verification.password, user_model.hashed_password)
    await db.execute(delete(Users).filter(Users.id == user.get('id')))
    await db.commit()
    return 