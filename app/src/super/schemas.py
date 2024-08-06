from typing import Optional, List
from pydantic import BaseModel

class CustomProblem(BaseModel):
    koreaProblem: str
    englishProblem: str
    img_path: str

class ProblemSet(BaseModel):
    name: str
    customProblems: List[CustomProblem]

class AddGroup(BaseModel):
    name: str
    detail: str

class GroupStep(BaseModel):
    group_id: int
    step: str

class GroupAvgTime(BaseModel):
    group_id: int

class GroupLevelStep(BaseModel):
    group_id: int
    step: int
    level: int

class PinNumber(BaseModel):
    pin_number: int

class GroupName(BaseModel):
    group_id: int
    group_name: str
    group_detail: str

class GroupId(BaseModel):
    group_id: int


class UserStep(BaseModel):
    user_id: int

class UserStep2(BaseModel):
    user_id: int
    season: int
    level: int
