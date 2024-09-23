from fastapi import HTTPException

def not_found_exception():
    return HTTPException(status_code=404, detail="Not found")

def user_credentials_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")
    if not user:
        raise HTTPException(status_code=404, detail="Could not validate credentials")

def student_role_exception(user_role):
    if user_role != 'student': 
        raise HTTPException(status_code=404, detail="Authentication Failed")

def self_select_exception(teacher_id, user_id):
    if teacher_id == user_id:
        raise HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')

def find_teacher_exception(teacher):
    if not teacher:
        raise HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')

def duplicate_connection_exception(teacher, student_teachers):
    if teacher in student_teachers:
        raise HTTPException(status_code=404, detail='이미 연결되었습니다.')
    

# def get_user_exception2(user):
#     if not user:
#         raise HTTPException(status_code=404, detail="Could not validate credentials")