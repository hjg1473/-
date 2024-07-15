from fastapi import HTTPException

def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def get_user_exception():
    return HTTPException(status_code=401, detail="Could not validate credentials")

def auth_exception():
    return HTTPException(status_code=401, detail="Authentication Failed")

def select_exception1():
    return HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')

def select_exception2():
    return HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')

def select_exception3():
    return HTTPException(status_code=404, detail='이미 연결되었습니다.')