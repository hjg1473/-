from fastapi import Depends, HTTPException, Header, status, APIRouter
from typing import Annotated
from database import engine
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import datetime, timedelta
from jose import jwt, JWTError
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
import app.src.models
from app.src.models import Users
from auth.schemas import CreateUser, Token
from auth.utils import get_password_hash, authenticate_user
from auth.service import create_access_token, redis_client
from auth.dependencies import db_dependency
from auth.exceptions import token_exception, get_user_exception, refresh_token_exception, get_valid_user_exception
from auth.constants import SECRET_KEY, ALGORITHM, REFRESH_TOKEN_EXPIRE_DAYS, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    responses={401: {"user": "Not authorized"}}
)

oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")


# JWT 엑세스 토큰 디코딩
async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # token+key+algorithms 넘겨줌.
        username: str = payload.get('sub') # 생성한 값을 가져옴
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None: # 둘 중에 하나라도 값이 없으면
            raise get_valid_user_exception()
        return {'username' : username, 'id' : user_id, 'user_role': user_role}
    except JWTError:
        raise get_valid_user_exception()

# 회원가입
@router.post("/register", status_code=status.HTTP_200_OK)
async def create_new_user(db: db_dependency, create_user: CreateUser):
    
    user_username = db.query(Users).filter(Users.username == create_user.username).first()
    if user_username:
        raise HTTPException(status_code=409, detail='중복된 아이디입니다.')
    
    create_user_model = app.src.models.Users()
    create_user_model.username = create_user.username
    create_user_model.name = create_user.name 
    create_user_model.age = create_user.age
    create_user_model.role = create_user.role
    create_user_model.email = create_user.email

    hash_password = get_password_hash(create_user.password)
    create_user_model.hashed_password = hash_password

    db.add(create_user_model)# DB에 저장
    db.commit() # 커밋
    db.refresh(create_user_model)
    study_info = app.src.models.StudyInfo()
    study_info.owner_id = create_user_model.id
    study_info.type1Level = 0
    study_info.type2Level = 0
    study_info.type3Level = 0
    db.add(study_info)
    db.commit()

    return {'detail': '성공적으로 회원가입되었습니다.'}

# 첫 로그인 (엑세스 토큰 + 리프레시 토큰 한번에 요청)
@router.post("/token", response_model=Token)
async def first_login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
                                 db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)    
    if not user:
        raise token_exception()
    
    # if existing_token and await get_valid_user(existing_token): 
    #     raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="이미 로그인한 유저가 있습니다.")

    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_access_token(user.username, '', '', timedelta(minutes=REFRESH_TOKEN_EXPIRE_DAYS))
    redis_client.set(f"{user.username}_refresh", refresh_token)
    redis_client.set(f"{user.username}_access", access_token)

    return {'access_token' : access_token, 'token_type' : 'bearer', 'role': user.role, 'refresh_token' : refresh_token}

# '엑세스 토큰' 유효성 검사.
@router.post("/access", status_code=status.HTTP_200_OK)
async def login_for_access_token(access_token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(access_token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise get_user_exception()
        return {'detail' : 'Token Vaild', 'role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token Invaild")
    

# 기존 리프레시 토큰을 가지고 토큰 재발급.
@router.post("/refresh", response_model=Token)
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM]) 
        username: str = payload.get('sub') 

        if username is None:
            raise get_user_exception()
        
        stored_refresh_token = redis_client.get(f"{username}_refresh")
        if stored_refresh_token is None or stored_refresh_token.decode('utf-8') != refresh_token: 
            raise refresh_token_exception()

        user_id = db.query(Users.id).filter(Users.username == username).first()[0]
        user_role = db.query(Users.role).filter(Users.username == username).first()[0]

        if user_id is None or user_role is None: 
            raise get_user_exception()
        
        access_token = create_access_token(username, user_id, user_role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        refresh_token = create_access_token(username, '', '', timedelta(minutes=REFRESH_TOKEN_EXPIRE_DAYS))

        redis_client.set(f"{username}_refresh", refresh_token)
        redis_client.set(f"{username}_access", access_token)
        
        return {'access_token' : access_token, 'token_type' : 'bearer', 'role' : '', 'refresh_token': refresh_token}
    except JWTError:
        raise refresh_token_exception()

@router.post("/logout")
async def logout(refresh_token: str = Header(default=None)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM]) 
        username: str = payload.get('sub')

        if username is None: 
            raise get_user_exception()
        
        redis_client.delete(f"{username}_access") 
        redis_client.delete(f"{username}_refresh")
        
        return {'detail' : '성공적으로 로그아웃 되었습니다!'}
    except JWTError:
        raise refresh_token_exception()
