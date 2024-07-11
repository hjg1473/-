from typing import Optional
from pydantic import BaseModel


class Problem(BaseModel):
    season: str
    type: str
    problemLevel: int
    koreaProblem: str
    englishProblem: str
    img_path: Optional[str]

class Answer(BaseModel):
    problem_id: int
    picture: str