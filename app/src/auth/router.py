from fastapi import Depends, Header, status, APIRouter
from typing import Annotated
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import timedelta
from jose import jwt, JWTError
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from auth.schemas import CreateUser, Token
from auth.utils import authenticate_user, decode_token, validate_token_payload
from auth.service import create_access_token, redis_client, create_user_in_db, create_study_info
from auth.dependencies import db_dependency
from auth.exceptions import token_exception, get_user_exception, access_token_exception, refresh_token_exception, get_valid_user_exception, user_exception
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
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise get_valid_user_exception()
        return {'username' : username, 'id' : user_id, 'user_role': user_role}
    except JWTError:
        raise get_valid_user_exception()

# 회원가입
@router.post("/register", status_code=status.HTTP_200_OK)
async def create_new_user(db: db_dependency, create_user: CreateUser):
    
    user_username = db.query(Users).filter(Users.username == create_user.username).first()
    if user_username:
        raise user_exception()
    
    user = create_user_in_db(db, create_user)
    create_study_info(db, user.id)

    return {'detail': '성공적으로 회원가입되었습니다.'}


# 로그인 (엑세스 토큰 + 리프레시 토큰 한번에 요청)
@router.post("/token", response_model=Token)
async def first_login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
    
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

@router.post("/access", status_code=status.HTTP_200_OK)
async def login_for_access_token(access_token: Annotated[str, Depends(oauth2_bearer)]):
    payload = decode_token(access_token)
    if payload is None:
        raise access_token_exception()
    user_role = validate_token_payload(payload)
    return {'detail': 'Token Valid', 'role': user_role}

@router.post("/refresh", response_model=Token)
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    if payload is None:
        raise refresh_token_exception()
    username = payload.get('sub')

    if username is None:
        raise get_user_exception()

    stored_refresh_token = redis_client.get(f"{username}_refresh")
    if stored_refresh_token is None or stored_refresh_token.decode('utf-8') != refresh_token:
        raise refresh_token_exception()

    user = db.query(Users).filter(Users.username == username).first()
    if user is None:
        raise get_user_exception()

    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    new_refresh_token = create_access_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))

    redis_client.set(f"{user.username}_refresh", new_refresh_token)
    redis_client.set(f"{user.username}_access", access_token)

    return {'access_token': access_token, 'token_type': 'bearer', 'role': user.role, 'refresh_token': new_refresh_token}

@router.post("/logout")
async def logout(refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    if payload is None:
        raise refresh_token_exception()
    username = payload.get('sub')

    if username is None:
        raise get_user_exception()

    redis_client.delete(f"{username}_access")
    redis_client.delete(f"{username}_refresh")

    return {'detail': '성공적으로 로그아웃 되었습니다!'}