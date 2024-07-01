from fastapi import Depends, HTTPException, status, APIRouter
from pydantic import BaseModel
from typing import Optional, Annotated
import models
from models import Users
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from database import SessionLocal, engine
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import datetime, timedelta
from jose import jwt, JWTError


SECRET_KEY = "KlgH6AzYDeZeGwD288to79I3vTHT8wp7"# 비밀키(추후 설정)
ALGORITHM = "HS256"

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

# 비밀번호(string) -> 해시값(FMEL$#@LMDSFS)
def get_password_hash(password):
    return bcrypt_context.hash(password)

# 비밀번호 확인
def verify_password(plain_password, hashed_password):
    return bcrypt_context.verify(plain_password, hashed_password)

# 로그인 판단
def authenticate_user(username: str, password: str, db): 
    user = db.query(Users).filter(Users.username == username).first()
    if not user:  # username does not exist
        return None  # Changed from False to None

    if not bcrypt_context.verify(password, user.hashed_password):  # Password verification
        return None  # Changed from False to None
    return user  # Return the user object

# 토큰 생성
def create_access_token(username: str, user_id: int, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : user_id} # id 와 sub 로 생성.
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# JWT 디코딩
async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # token+key+algorithms 넘겨줌.
        username: str = payload.get('sub') # 생성한 값을 가져옴
        user_id: int = payload.get('id')
        if username is None or user_id is None: # 둘 중에 하나라도 값이 없으면
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user1.')
        return {'username' : username, 'id' : user_id}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user2.')


# 회원가입
@router.post("/register")
async def create_new_user(db: db_dependency, # 사용자 요청보다 앞에 와야함.
                          create_user: CreateUser):

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


# 로그인 (토큰 요청)
@router.post("/token", response_model=Token)
async def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
                                 db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    #검증 단계
    if not user:
        return 'Failed Authentication'
    token = create_access_token(user.username, user.id, timedelta(minutes=20))
    return {'access_token' : token, 'token_type' : 'bearer'}

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
