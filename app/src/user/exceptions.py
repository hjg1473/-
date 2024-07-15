from fastapi import HTTPException

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }


def auth_user_exception(user):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')


def http_exception():
    return HTTPException(status_code=404, detail="Not Found")

def email_exception(email):
    if email:
        raise HTTPException(status_code=409, detail="중복된 이메일입니다.")

def password_exception():
    return HTTPException(status_code=409, detail="비밀번호가 틀렸습니다.")
