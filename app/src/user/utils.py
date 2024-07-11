
import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from passlib.context import CryptContext


bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

def successful_response(status_code: int):
    return {
        'status': status_code,
        'detail': 'Successful'
    }