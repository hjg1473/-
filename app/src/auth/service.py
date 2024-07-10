from datetime import datetime, timedelta
from jose import jwt
from auth.constants import ALGORITHM, SECRET_KEY
import redis 

redis_client = redis.Redis(host='localhost', port=6379, db=0)

# 토큰 생성
def create_access_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : user_id, 'role': role} 
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

# 리프레시 토큰 생성
def create_refresh_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub' : username, 'id' : '', 'role': ''}
    expires = datetime.utcnow() + expires_delta
    encode.update({'exp' : expires})
    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)