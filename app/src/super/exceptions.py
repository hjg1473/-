from fastapi import HTTPException
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.auth.exceptions import get_user_exception

def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def authenticate_user_exception(user):
    if user is None:
        raise get_user_exception()
    
def authenticate_super_excetpion(user):
    if user is None:
        raise get_user_exception()
    if user.get('user_role') != 'super':
        raise HTTPException(status_code=401, detail='Authentication Failed')