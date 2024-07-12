import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users
from auth.constants import SECRET_KEY, ALGORITHM
from auth.exceptions import get_user_exception
from passlib.context import CryptContext
from jose import jwt, JWTError

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return bcrypt_context.hash(password)

def verify_password(plain_password, hashed_password):
    return bcrypt_context.verify(plain_password, hashed_password)

def authenticate_user(username: str, password: str, db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def decode_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        return None

def validate_token_payload(payload: dict):
    username = payload.get('sub')
    user_id = payload.get('id')
    user_role = payload.get('role')
    if not username or not user_id:
        raise get_user_exception()
    return username, user_id, user_role