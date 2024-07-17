from fastapi import  HTTPException, status

async def username_exception(username: str, db):
    from auth.service import get_user_to_username
    user = await get_user_to_username(username, db)
    if user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="중복된 아이디입니다.")

def get_user_exception(username):
    if not username:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Could not validate credentials")

def get_valid_user_exception():
    credentials_exception = HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Could not validate user",
        headers={"WWW-Authenticate": "Bearer"},
    )
    return credentials_exception

def login_exception(user):
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Incorrect username or password")

def token_exception1(payload):
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Token")
    
def token_exception2(stored_token, token):
    if stored_token is None or stored_token.decode('utf-8') != token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="No Matched Token")
