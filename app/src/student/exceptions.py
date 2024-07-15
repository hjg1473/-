from fastapi import HTTPException, status
import sys, os
from dependencies import user_dependency
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.auth.exceptions import get_user_exception


def auth_student_exception(user:user_dependency):
    if user is None:
        raise get_user_exception()
    if user.get('user_role') != 'student': # student 인 경우만
        raise HTTPException(status_code=401, detail='Authentication Failed')


def teacher_exception(teacher:user_dependency, student:user_dependency):
    if not teacher:
        raise HTTPException(status_code=404, detail='선생님을 찾을 수 없습니다.')
    if teacher.get("id") == student.get("id"):
        raise HTTPException(status_code=404, detail='자기 자신은 지정할 수 없습니다.')

