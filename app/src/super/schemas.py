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