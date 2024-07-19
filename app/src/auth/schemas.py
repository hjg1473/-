from typing import Optional
from pydantic import BaseModel

class CreateUser(BaseModel):
    name: str
    username: str
    password: str
    age: int
    role: str
    phone_number: str
    email: Optional[str]

class Username_Phone(BaseModel):
    username: str
    phone_number: str

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    refresh_token: str

class Message(BaseModel):
    message: str

class PhoneNumber(BaseModel):
    phone_number: str

class verify_number(BaseModel):
    phone_number: str
    verify_number: str