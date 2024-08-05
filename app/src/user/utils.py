import json
import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from passlib.context import CryptContext

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

def get_string_to_json(input:str):
    return json.loads(input)

def get_json_to_string(input:json):
    return json.dumps(input)