from fastapi import Depends, HTTPException, Header, status, APIRouter
from pydantic import BaseModel
from typing import Optional, Annotated
import models
from models import Users, StudyInfo
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from database import SessionLocal, engine
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import datetime, timedelta
from jose import jwt, JWTError
import redis # 인메모리 데이터베이스 (Remote Dictionary Server)

SECRET_KEY = "KlgH6AzYDeZeGwD288to79I3vTHT8wp7"# 비밀키(추후 설정)
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30 # 엑세스 토큰 (30분)
REFRESH_TOKEN_EXPIRE_DAYS = 7 # 리프레시 토큰 (7일)

# Redis 클라이언트 설정
redis_client = redis.Redis(host='localhost', port=6379, db=0)

class CreateUser(BaseModel):
    name: str# 실명
    username: str# 아이디
    password: str# 비밀번호
    age: int# 나이
    role: str# 역할 student or teachers
    email: Optional[str]# 이메일(선생님만)
    group: Optional[int]# 분반(학생만)

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

models.Base.metadata.create_all(bind=engine)

oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")


router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    responses={401: {"user": "Not authorized"}}
)

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    refresh_token: str

# 비밀번호(string) -> 해시값(FMEL$#@LMDSFS)
def get_password_hash(password):
    return bcrypt_context.hash(password)

# 비밀번호 확인
def verify_password(plain_password, hashed_password):
    return bcrypt_context.verify(plain_password, hashed_password)

# 로그인 판단
def authenticate_user(username: str, password: str, db, status_code=status.HTTP_200_OK): 
    user = db.query(Users).filter(Users.username == username).first()
    if not user:  # username does not exist
        raise HTTPException(status_code=404, detail='아이디가 존재하지 않습니다.')

    if not bcrypt_context.verify(password, user.hashed_password):  # Password verification
        raise HTTPException(status_code=404, detail='비밀번호가 틀렸습니다.')
    return user  # Return the user object

# 토큰 생성
def create_access_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : user_id, 'role': role} # id 와 sub 로 생성.
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# 리프레쉬 토큰 생성
def create_refresh_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : '', 'role': ''} # 엑세스 토큰과는 다르게 username 만 이용해서 생성.
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# JWT 엑세스 토큰 디코딩
async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # token+key+algorithms 넘겨줌.
        username: str = payload.get('sub') # 생성한 값을 가져옴
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None: # 둘 중에 하나라도 값이 없으면
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        return {'username' : username, 'id' : user_id, 'user_role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')

# # JWT 리프레쉬 토큰 디코딩
# async def get_current_user_refresh(token: Annotated[str, Depends(oauth2_bearer)]):
#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
#         # token+key+algorithms 넘겨줌.
#         username: str = payload.get('sub') # 생성한 값을 가져옴
#         # user_id: int = payload.get('id')
#         # user_role: str = payload.get('role')
#         if username is None: # 둘 중에 하나라도 값이 없으면
#             raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
#                                 detail='Could not validate user.')
#         return {'username' : username}
#     except JWTError:
#         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
#                             detail='Could not validate user.')

# 유저 유효한지 검사
async def get_valid_user(token: str) -> bool:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            return False
        return True
    except JWTError:
        return False


# 회원가입
@router.post("/register", status_code=status.HTTP_200_OK)
async def create_new_user(db: db_dependency, # 사용자 요청보다 앞에 와야함.
                          create_user: CreateUser):
    
    user_username = db.query(Users).filter(Users.username == create_user.username).first()
    if user_username:
        raise HTTPException(status_code=409, detail='중복된 아이디입니다.')
    
    create_user_model = models.Users()
    create_user_model.username = create_user.username# 아이디
    create_user_model.name = create_user.name# 실명 
    create_user_model.age = create_user.age# 나이 
    create_user_model.role = create_user.role# 역할 
    create_user_model.email = create_user.email# 이메일 (선생님만) 
    create_user_model.group = create_user.group# 분반 (학생만)

    hash_password = get_password_hash(create_user.password) # 입력한 비밀번호 -> 해쉬 비밀번호
    create_user_model.hashed_password = hash_password# 해쉬 비밀번호

    db.add(create_user_model)# DB에 저장
    db.commit() # 커밋
    db.refresh(create_user_model)
    study_info = models.StudyInfo()
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
    #검증 단계
    if not user:
        return 'Failed Authentication'
    
    # Redis에서 유저의 기존 액세스 토큰을 가져옴
    # existing_token = redis_client.get(f"{user.username}_access")
    
    # if existing_token and await get_valid_user(existing_token): # 토큰이 유효하다면
    #     raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="이미 로그인한 유저가 있습니다.")

    # 엑세스 + 리프레시 토큰 생성
    access_token = create_access_token(user.username, user.id, user.role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    refresh_token = create_access_token(user.username, '', '', timedelta(minutes=REFRESH_TOKEN_EXPIRE_DAYS))

    # Redis 에 리프레시 토큰 저장
    redis_client.set(f"{user.username}_refresh", refresh_token)
    redis_client.set(f"{user.username}_access", access_token)

    return {'access_token' : access_token, 'token_type' : 'bearer', 'role': user.role, 'refresh_token' : refresh_token}

# '엑세스 토큰' 유효성 검사.
@router.post("/access", status_code=status.HTTP_200_OK)
async def login_for_access_token(access_token: str = Header(default=None)):
    try:
        payload = jwt.decode(access_token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise HTTPException(status_code=status.HTTP_200_OK, detail="Token Invaild")    
        return {'detail' : 'Token Vaild', 'role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token Invaild")
    


# 기존 리프레시 토큰을 가지고 토큰 재발급.
@router.post("/refresh", response_model=Token)
async def refresh_access_token(db: db_dependency, refresh_token: str = Header(default=None)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM]) # 리프레시 토큰 디코딩
        username: str = payload.get('sub') # 생성한 값을 가져옴, 리프레시 토큰은 username만 저장.
        # user_id: int = payload.get('id')
        # user_role: str = payload.get('role')

        if username is None: # username 값이 없으면
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        
        stored_refresh_token = redis_client.get(f"{username}_refresh") # 저장된 리프레시 토큰 불러오기

        if stored_refresh_token is None or stored_refresh_token.decode('utf-8') != refresh_token: # 저장된 리프레시 토큰과 클라에서 보낸 토큰 비교
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token") # 에러

        user_id = db.query(Users.id).filter(Users.username == username).first()[0]
        user_role = db.query(Users.role).filter(Users.username == username).first()[0]

        if user_id is None or user_role is None: #검색된 값이 없으면 에러
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        
        # # 엑세스 토큰 발급
        # access_token = create_access_token(username, user_id, user_role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        
        # redis_client.set(f"{username}_access", access_token) # redis에 엑세스 토큰 저장? 안해도 되지 않을까. 
        # # 저장해야 중복 로그인을 막을 수 있음.
        # 엑세스 + 리프레시 토큰 생성
        access_token = create_access_token(username, user_id, user_role, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        refresh_token = create_access_token(username, '', '', timedelta(minutes=REFRESH_TOKEN_EXPIRE_DAYS))

        # Redis 에 리프레시 토큰 저장
        redis_client.set(f"{username}_refresh", refresh_token)
        redis_client.set(f"{username}_access", access_token)
        
        return {'access_token' : access_token, 'token_type' : 'bearer', 'role' : '', 'refresh_token': refresh_token}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

user_dependency = Annotated[dict, Depends(get_current_user)]    
# user_dependency_refresh = Annotated[dict, Depends(get_current_user_refresh)]    
# class User(BaseModel):
#     username: str
    
# @router.get("/users/me", response_model=User)
# async def read_users_me(current_user: user_dependency):
#     return current_user

@router.post("/logout")
async def logout(refresh_token: str = Header(default=None)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM]) # 리프레시 토큰 디코딩
        username: str = payload.get('sub') # 생성한 값을 가져옴, 리프레시 토큰은 username만 저장.
        # user_id: int = payload.get('id')
        # user_role: str = payload.get('role')

        if username is None: # username 값이 없으면
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        redis_client.delete(f"{username}_access") 
        redis_client.delete(f"{username}_refresh")
        return {'detail' : '성공적으로 로그아웃 되었습니다!'}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")



# Exceptions
def get_user_exception():
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    return credentials_exception


def token_exception():
    token_exception_response = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Incorrect username or password",
        headers={"WWW-Authenticate": "Bearer"},
    )
    return token_exception_response
