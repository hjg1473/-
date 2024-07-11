from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status

import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from auth.router import get_current_user
from Refactor.app.src.models import Users
from user.dependencies import user_dependency, db_dependency, get_db
from user.schemas import UserQuitVerification, UserVerification, User_info
from user.utils import bcrypt_context, successful_response
from user.exceptions import http_exception

router = APIRouter(
    prefix='/users', 
    tags=['users']
)

@router.put("/password", status_code=status.HTTP_200_OK)
async def change_password(user: user_dependency, db: db_dependency,
                          user_verification: UserVerification):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    
    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
    # 비밀번호 인증.
        raise HTTPException(status_code=401, detail='기존 비밀번호가 틀렸습니다.')
    
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    # 해시값을 새로운 해시값으로 교체.
    db.add(user_model)
    db.commit()

    return {'detail': '비밀번호가 변경되었습니다.'}

@router.put("/update", status_code=status.HTTP_200_OK)
async def update_user_info(user_info: User_info,
                      user: dict = Depends(get_current_user),
                      db: Session = Depends(get_db)):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')

    user_model = db.query(Users).filter(Users.id == user.get('id')).first()

    if user_model is None:
        raise http_exception()

    user_model.name = user_info.name
    user_model.username = user_info.username
    user_model.phone_number = user_info.phone_number
    user_model.email = user_info.email

    db.add(user_model)
    db.commit()

    return successful_response(200)


@router.delete("/quit/", status_code=status.HTTP_200_OK)
async def delete_user(user: user_dependency, db: db_dependency, user_verification: UserQuitVerification):

    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    
    # 비밀번호 인증.
    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
        raise HTTPException(status_code=401, detail='비밀번호가 틀렸습니다.')
    
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    if user_model is None:
        raise HTTPException(status_code=404, detail='Not found.')
    
    db.query(Users).filter(Users.id == user.get('id')).delete()
    db.commit()

    return {'detail': '성공적으로 탈퇴되었습니다.'}