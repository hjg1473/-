from typing import List
from pydantic import BaseModel, Field\


class UserVerification(BaseModel):
    password: str
    new_password: str = Field(min_length=6)

class UserQuitVerification(BaseModel):
    password: str

class User_info(BaseModel):
    name: str

class User_season(BaseModel):
    season: str