from sqlalchemy import delete, select
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users
from user.dependencies import user_dependency, db_dependency
from user.schemas import UserQuitVerification, UserVerification, User_info
from user.utils import bcrypt_context
from user.exceptions import successful_response, http_exception, email_exception, password_exception, auth_user_exception

router = APIRouter(
    prefix='/users', 
    tags=['users']
)

@router.put("/password", status_code=status.HTTP_200_OK)
async def change_password(user: user_dependency, db: db_dependency,
                          user_verification: UserVerification):
    auth_user_exception(user)
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
        raise password_exception()
    
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    db.add(user_model)
    await db.commit()

    return {'detail': '비밀번호가 변경되었습니다.'}

@router.put("/update", status_code=status.HTTP_200_OK)
async def update_user_info(user_info: User_info, user: user_dependency, db: db_dependency):
    auth_user_exception(user)

    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    if user_model is None:
        raise http_exception()
    
    email = await db.execute(select(Users).filter(Users.email == user_info.email))
    user_email = email.scalars().first()
    email_exception(user_email)

    user_model.name=user_info.name
    user_model.email=user_info.email
    user_model.phone_number=user_info.phone_number

    db.add(user_model)
    await db.commit()
    return successful_response(200)

@router.delete("/quit/", status_code=status.HTTP_200_OK)
async def delete_user(user: user_dependency, db: db_dependency, user_verification: UserQuitVerification):

    auth_user_exception(user)

    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    if user_model is None:
        raise http_exception()
    # 비밀번호 인증.
    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
        raise password_exception()
    
    # db.query(Users).filter(Users.id == user.get('id')).delete()
    result = await db.execute(delete(Users).filter(Users.id == user.get('id')))
    await db.commit()

    return {'detail': '성공적으로 탈퇴되었습니다.'}