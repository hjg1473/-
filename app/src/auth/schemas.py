from typing import Optional
from pydantic import BaseModel

class CreateUser(BaseModel):
    name: str
    username: str
    password: str
    age: int
    role: str
    email: Optional[str]

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    refresh_token: str

class Message(BaseModel):
    message: str