from fastapi import HTTPException

def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def get_user_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")

def get_user_exception2(user):
    if not user:
        raise HTTPException(status_code=404, detail="Could not validate credentials")
    
def auth_exception(user_role):
    if user_role != 'student': 
        raise HTTPException(status_code=404, detail="Authentication Failed")

def select_exception1(teacher_id, user_id):
    if teacher_id == user_id:
        raise HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')

def select_exception2(teacher):
    if not teacher:
        raise HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')

def select_exception3(teacher, student_teachers):
    if teacher in student_teachers:
        raise HTTPException(status_code=404, detail='이미 연결되었습니다.')