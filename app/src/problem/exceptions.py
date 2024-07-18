from fastapi import  HTTPException, status

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def get_user_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")

def get_problem_exception(stepinfo_model):
    if stepinfo_model is None:
        raise HTTPException(status_code=404, detail='문제 데이터가 존재하지 않습니다.')