from typing import Annotated
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users
import models
from database import SessionLocal
from routers.auth import get_current_user
from passlib.context import CryptContext

router = APIRouter(
    prefix='/users', 
    tags=['users']
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]
bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

class UserVerification(BaseModel):
    password: str
    new_password: str = Field(min_length=6)

class UserQuitVerification(BaseModel):
    password: str

class User_info(BaseModel):
    name: str
    username: str
    phone_number: str
    email: str

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

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }


def http_exception():
    return HTTPException(status_code=404, detail="Not Found")

