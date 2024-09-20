import aioredis
import sys, os
import logging
from fastapi import Depends, Header, status, APIRouter
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from typing import Annotated
from datetime import timedelta

# Adding system path for file imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.logging_setup import LoggerSetup
from auth.schemas import CreateUser, Message, Username, FindPassword, UpdatePassword
from auth.utils import authenticate_user, decode_token, validate_token_payload
from auth.service import *
from auth.dependencies import db_dependency
from auth.exceptions import *
from auth.constants import REFRESH_TOKEN_EXPIRE_DAYS, ACCESS_TOKEN_EXPIRE_MINUTES


# Setting up logging
LOGGER = logging.getLogger(__name__)
logger_setup = LoggerSetup()

# Defining the FastAPI router (auth-related routes)
router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    responses={401: {"user": "Not authorized"}}
)

# OAuth2-based token authentication scheme setup
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")

# Function to get the current user by validating the token
def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    payload = decode_token(token)
    token_valid_exception(payload)
    username, user_id, user_role = validate_token_payload(payload)
    return {'username' : username, 'id' : user_id, 'user_role': user_role}

# Check Username Duplication 
@router.post("/username_duplication", status_code=status.HTTP_200_OK)
async def username_duplication(db: db_dependency, create_user: Username):
    
    # Fetch user with the provided username from the database
    user = await find_user_by_username(create_user.username, db)
    if user:
        return {'detail': 0} # Duplicate 
    return {'detail': 1 } # Not duplicate

# Register
@router.post("/register", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def user_register(db: db_dependency, create_user: CreateUser):
    await username_duplicate_exception(create_user.username, db)
    user = await create_user_in_db(db, create_user)

    if user.role == 'student':
        await create_study_info(db, user.id)
    # Logging
    logger = logger_setup.get_logger(user.id)
    logger.info("--- Register ---")

    return {'detail': '성공적으로 회원가입되었습니다.'}

### BEGIN_FIND_ID/PW
# Step 1 : isValid Username?
@router.post("/find", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password1(db: db_dependency, user: Username):
    await username_find_exception(user.username, db)
    return {'detail': 'Success'}

# Step 2 : isCorrect User Question & Answer? 
@router.post("/find_password", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password2(db: db_dependency, user: FindPassword):
    await username_find_exception(user.username, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    user_model = await find_user_by_username(user.username, db)

    # Verify the security question and answer
    if user_model.questionType == user.questionType and user_model.question == user.question:
        await redis_client.setex(f"{user.username}_FindPassword", 180, "True") # 180 seconds
        redis_client.close()
        await redis_client.wait_closed()
        return {'detail': 'Success'}
    else:
        return {'detail': 'Fail'}

# Step 3 : Update Password
@router.post("/update_password", status_code=status.HTTP_200_OK, responses={409: {"model": Message}})
async def find_password3(db: db_dependency, user: UpdatePassword):
    await username_find_exception(user.username, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    user_model = await find_user_by_username(user.username, db)

    # Check to same NewPassword to NewPasswordVerify 
    password_verify_exception(user.newPassword, user.newPasswordVerify)
    isVerify = await redis_client.get(f"{user.username}_FindPassword")
    string_value = isVerify.decode('utf-8')

     # If verified, update the password in the database
    if string_value == "True":
        from app.src.user.utils import bcrypt_context
        user_model.hashed_password = bcrypt_context.hash(user.newPassword)
        db.add(user_model)
        await db.commit()
        return {'detail': '비밀번호가 변경되었습니다.'}
    
    # If Redis flag is not valid, raise exception (password recovery timeout)
    get_password_exception()
### END_FIND_ID/PW

# Login endpoint
@router.post("/token")
async def first_login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
    user = await authenticate_user(form_data.username, form_data.password, db)    
    login_exception(user)

    redis_client = await aioredis.create_redis_pool('redis://localhost')

    # Create access and refresh tokens
    access_token = create_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))

    await redis_client.set(f"{user.username}_refresh", refresh_token)
    await redis_client.set(f"{user.username}_access", access_token)

    redis_client.close()
    await redis_client.wait_closed()

    # Teacher or Parent login doesn't require released information
    if user.role in ['teacher', 'parent']:
        return {
            'access_token': access_token, 'token_type': 'bearer',
            'username': user.username, 'role': user.role,
            'refresh_token': refresh_token, 'name': user.name,
            "username_correct": True, "password_correct": True
        }

    # Student login requires released and group info
    released = await fetch_released_data(db, user.id)
    group_name, released_group = await fetch_group_and_released_group_data(db, user.team_id)

    return {
        'access_token': access_token, 'token_type': 'bearer',
        'username': user.username, 'role': user.role,
        'refresh_token': refresh_token, 'team_id': user.team_id,
        'name': user.name, "username_correct": True,
        "password_correct": True, "released": released,
        'group_name': group_name, 'released_group': released_group
    }

# Validate access token
@router.post("/access", status_code=status.HTTP_200_OK, responses={401: {"model": Message}})
async def login_for_access_token(access_token: Annotated[str, Depends(oauth2_bearer)], db: db_dependency):
    payload = decode_token(access_token)
    token_valid_exception(payload)
    
    username, user_id, user_role = validate_token_payload(payload)
    
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_access_token = await redis_client.get(f"{username}_access")
    token_match_exception(stored_access_token, access_token)

    redis_client.close()
    await redis_client.wait_closed()

    user = await fetch_user_data(db, user_id)
    
    # Return validation response for teacher or parent
    if user.role in ['teacher', 'parent']:
        return {
            'detail': 'Token Valid', 'role': user_role,
            'username': username, 'name': user.name,
            "username_correct": True, "password_correct": True
        }

    # Return validation response for student
    released = await fetch_released_data(db, user_id)
    group_name, released_group = await fetch_group_and_released_group_data(db, user.team_id)

    return {
        'detail': 'Token Valid', 'role': user_role, 
        'team_id': user.team_id, 'username': username,
        'name': user.name, "username_correct": True,
        "password_correct": True, "released": released,
        'group_name': group_name, 'released_group': released_group
    }

# Check the Refresh Token Vaild.
@router.post("/refresh", responses={401: {"model": Message}})
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    # Token Invalid
    token_valid_exception(payload)
    
    username = payload.get('sub')
    if username is None:
        raise get_user_exception()
    
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")

    # Does not match the stored token.
    token_match_exception(stored_refresh_token, refresh_token)

    user = await find_user_by_username(username, db)
    get_user_exception(user)

    # Create new tokens (access, refresh)
    new_access_token = create_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    new_refresh_token = create_token(user.username, '', '', timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))

    await redis_client.set(f"{user.username}_refresh", new_refresh_token)
    await redis_client.set(f"{user.username}_access", new_access_token)
    redis_client.close()
    await redis_client.wait_closed()

    return {
        'access_token': new_access_token, 'token_type': 'bearer',
        'refresh_token': new_refresh_token, 'role': user.role
    }

# Logout 
@router.post("/logout", responses={401: {"model": Message}})
async def logout(refresh_token: str = Header(default=None)):
    payload = decode_token(refresh_token)
    # Token Invalid
    token_valid_exception(payload)
    
    username = payload.get('sub')
    get_user_exception(username)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    stored_refresh_token = await redis_client.get(f"{username}_refresh")
    # Does not match the stored token.
    token_match_exception(stored_refresh_token, refresh_token)
    
    # Delete all tokens (access, refresh)
    await redis_client.delete(f"{username}_access")
    await redis_client.delete(f"{username}_refresh")
    redis_client.close()
    await redis_client.wait_closed()
    return {'detail': '성공적으로 로그아웃 되었습니다!'}