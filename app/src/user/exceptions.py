from fastapi import HTTPException


def not_found_default():
    return HTTPException(status_code=404, detail='Not found.')

def wrong_password(detail:str):
    return HTTPException(status_code=401, detail='비밀번호가 틀렸습니다.')

def auth_failed(detail:str):
    return HTTPException(status_code=401, detail='Authentication Failed')