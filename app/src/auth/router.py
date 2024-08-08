import aioredis
from fastapi import Depends, Header, status, APIRouter
from typing import Annotated
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import timedelta
import sys, os
from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, Released, Groups, ReleasedGroup
from auth.schemas import CreateUser, Message, Username, FindPassword, UpdatePassword
from auth.utils import authenticate_user, decode_token, validate_token_payload
from auth.service import create_access_token, create_user_in_db, create_study_info, get_user_to_username, create_released
from auth.dependencies import db_dependency
from auth.exceptions import login_exception, get_user_exception, token_exception1, token_exception2, username_exception, username2_exception, password_verify_exception, get_password_exception
from auth.constants import REFRESH_TOKEN_EXPIRE_DAYS, ACCESS_TOKEN_EXPIRE_MINUTES
import logging
from app.src.logging_setup import LoggerSetup

# Get logger for module
LOGGER = logging.getLogger(__name__)
logger_setup = LoggerSetup()

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    responses={401: {"user": "Not authorized"}}
)

oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")

# 비동기 -> 동기
def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    payload = decode_token(token)
    token_exception1(payload)
    username, user_id, user_role = validate_token_payload(payload)
    return {'username' : username, 'id' : user_id, 'user_role': user_role}

# 유저네임 중복 확인
@router.post("/username_duplication", status_code=status.HTTP_200_OK)
async def username_duplication(db: db_dependency, create_user: Username):
    user = await get_user_to_username(create_user.username, db)
    if user:
        return {'detail': 0}
    return {'detail': 1 }

# 회원가입
@router.post("/register", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def create_new_user(db: db_dependency, create_user: CreateUser):
    await username_exception(create_user.username, db)
    user = await create_user_in_db(db, create_user)
    if user.role == 'student':
        await create_study_info(db, user.id)
        # await create_released(db, user.id, create_user.seasons)

    logger = logger_setup.get_logger(user.id)
    logger.info("--- Register ---")
    return {'detail': '성공적으로 회원가입되었습니다.'}

# 아이디로 비밀번호 찾기1
@router.post("/find", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password1(db: db_dependency, user: Username):
    await username2_exception(user.username, db)
    return {'detail': 'Success'}

# 아이디로 비밀번호 찾기2
@router.post("/find_password", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password2(db: db_dependency, user: FindPassword):
    await username2_exception(user.username, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    user_model = await get_user_to_username(user.username, db)
    if user_model.questionType == user.questionType and user_model.question == user.question:
        await redis_client.setex(f"{user.username}_FindPassword", 180, "True")
        redis_client.close()
        await redis_client.wait_closed()
        return {'detail': 'Success'}
    else:
        return {'detail': 'Fail'}

# 아이디로 비밀번호 찾기3
@router.post("/update_password", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password3(db: db_dependency, user: UpdatePassword):
    await username2_exception(user.username, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    user_model = await get_user_to_username(user.username, db)
    password_verify_exception(user.newPassword, user.newPasswordVerify)
    isVerify = await redis_client.get(f"{user.username}_FindPassword")
    string_value = isVerify.decode('utf-8')
    if string_value == "True":
        from app.src.user.utils import bcrypt_context
        user_model.hashed_password = bcrypt_context.hash(user.newPassword)
        db.add(user_model)
        await db.commit()
        return {'detail': '비밀번호가 변경되었습니다.'}
    get_password_exception()
        
# 로그인 
@router.post("/token")
async def first_login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
    user = await authenticate_user(form_data.username, form_data.password, db)    
    login_exception(user)

    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # if existing_token and await get_valid_user(existing_token): 
    #     raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="이미 로그인한 유저가 있습니다.")

    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_access_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))
    await redis_client.set(f"{user.username}_refresh", refresh_token)
    await redis_client.set(f"{user.username}_access", access_token)

    redis_client.close()
    await redis_client.wait_closed()

    if user.role == 'teacher' or user.role == 'parent':
        return {'access_token' : access_token, 'token_type' : 'bearer', 'username': user.username, 'role': user.role, 'refresh_token' : refresh_token, 'name': user.name, "username_correct": True, "password_correct": True}

    result = await db.execute(select(Released).filter(Released.owner_id == user.id))
    released_model = result.scalars().all()
    released = []
    for r in released_model:
        released.append({'season':r.released_season, 'level':r.released_level, 'step':r.released_step})
    result2 = await db.execute(select(Groups).where(Groups.id == user.team_id))
    group_model = result2.scalars().first()
    if group_model is None:
        return {'access_token' : access_token, 'token_type' : 'bearer', 'username': user.username, 'role': user.role, 'refresh_token' : refresh_token, 'team_id': user.team_id, 'name': user.name, "username_correct": True, "password_correct": True, "released": released, 'group_name': None, 'released_group': None}
    
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == user.team_id))
    released_group_model = result.scalars().all()
    released_group = []
    for rg in released_group_model:
        released_group.append({"season":rg.released_season, "level":rg.released_level, "step":rg.released_step, "type":rg.released_type})
    return {'access_token' : access_token, 'token_type' : 'bearer', 'username': user.username, 'role': user.role, 'refresh_token' : refresh_token, 'team_id': user.team_id, 'name': user.name, "username_correct": True, "password_correct": True, "released": released, 'group_name': group_model.name, 'released_group':released_group}

# Access Token 유효성 검사
@router.post("/access", status_code=status.HTTP_200_OK, responses={401: {"model": Message}})
async def login_for_access_token(access_token: Annotated[str, Depends(oauth2_bearer)], db: db_dependency):
    payload = decode_token(access_token)
    token_exception1(payload)
    username, user_id, user_role = validate_token_payload(payload)

    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_access_token = await redis_client.get(f"{username}_access")
    token_exception2(stored_access_token, access_token)

    result = await db.execute(select(Users).filter(Users.id == user_id))
    user = result.scalars().first()
    if user_role == 'super':
        return {'detail': 'Token Valid', 'role': user_role, 'username': username, 'name': user.name, "username_correct": True, "password_correct": True}

    result2 = await db.execute(select(Released).filter(Released.owner_id == user_id))
    released_model = result2.scalars().all()
    released = []
    for r in released_model:
        released.append({'season':r.released_season, 'level':r.released_level, 'step':r.released_step})
    result2 = await db.execute(select(Groups).where(Groups.id == user.team_id))
    group_model = result2.scalars().first()
    if group_model is None:
        return {'detail': 'Token Valid', 'role': user_role, 'team_id': user.team_id, 'username': username, 'name': user.name, "username_correct": True, "password_correct": True, "released": released, 'group_name': None, 'released_group':None}
<<<<<<< HEAD
        
=======
    
>>>>>>> 932576a81e014d822d295e7a8fd90761ed8d193e
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == user.team_id))
    released_group_model = result.scalars().all()
    released_group = []
    for rg in released_group_model:
        released_group.append({"season":rg.released_season, "level":rg.released_level, "step":rg.released_step, "type":rg.released_type})
    return {'detail': 'Token Valid', 'role': user_role, 'team_id': user.team_id, 'username': username, 'name': user.name, "username_correct": True, "password_correct": True, "released": released, 'group_name': group_model.name, 'released_group':released_group}

# Refresh Token 유효성 검사
@router.post("/refresh", responses={401: {"model": Message}})
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    token_exception1(payload)
    
    username = payload.get('sub')
    if username is None:
        raise get_user_exception()
    
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")
    token_exception2(stored_refresh_token, refresh_token)

    result = await db.execute(select(Users).filter(Users.username == username))
    user = result.scalars().first()
    get_user_exception(user)
    
    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    new_refresh_token = create_access_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))
    await redis_client.set(f"{user.username}_refresh", new_refresh_token)
    await redis_client.set(f"{user.username}_access", access_token)
    redis_client.close()
    await redis_client.wait_closed()
    return {'access_token': access_token, 'token_type': 'bearer', 'role': user.role, 'refresh_token': new_refresh_token}

# 로그아웃 (리프레시 토큰을 삭제는 했지만, 안에 담긴 정보 자체는 남아있음. )
@router.post("/logout", responses={401: {"model": Message}})
async def logout(refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    token_exception1(payload)
    
    username = payload.get('sub')
    get_user_exception(username)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")
    token_exception2(stored_refresh_token, refresh_token)
    
    await redis_client.delete(f"{username}_access")
    await redis_client.delete(f"{username}_refresh")
    redis_client.close()
    await redis_client.wait_closed()
    return {'detail': '성공적으로 로그아웃 되었습니다!'}