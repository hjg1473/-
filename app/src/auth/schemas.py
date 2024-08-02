from typing import Optional
from pydantic import BaseModel

class CreateUser(BaseModel):
    name: str
    username: str
    password: str
    role: str
    questionType: int
    question: str
    
class Username(BaseModel):
    username: str

class FindPassword(BaseModel):
    username: str
    questionType: int
    question: str

class UpdatePassword(BaseModel):
    username: str
    newPassword: str
    newPasswordVerify: str

class CustomResponseException(Exception):
    def __init__(self, code: int, content: dict):
        self.code = code
        self.content = content
        
class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    refresh_token: str

class Message(BaseModel):
    message: str
