from typing import Dict, List, Optional
from pydantic import BaseModel

class Problem(BaseModel):
    season: str
    level: int
    step: int
    koreaProblem: str
    englishProblem: str
    img_path: Optional[str]

class Answer(BaseModel):
    problem_id: int
    user_string: str

class ProblemInfo(BaseModel):
    user_id: int 
    problem_id: int 
    count: int 

class Problems(BaseModel):
    problem_id: int
    incorrectCount: int

class UserProblems(BaseModel):
    user_id: int
    problems: List[Problems]  

class TempUserProblem:
    def __init__(self, totalIncorrectLetter: int, totalIncorrectPunc: int, totalIncorrectBlock: int, 
                 totalIncorrectWords: int, totalIncorrectOrder: int):
        self.totalIncorrectLetter = totalIncorrectLetter
        self.totalIncorrectPunc = totalIncorrectPunc
        self.totalIncorrectBlock = totalIncorrectBlock
        self.totalIncorrectWords = totalIncorrectWords
        self.totalIncorrectOrder = totalIncorrectOrder
        self.problem_incorrect_count: Dict[int, int] = {} # 문제 리스트 -> 딕셔너리 (횟수 계산용)
        self.solved_season: int
        self.solved_level: int
        self.solved_step: int

TempUserProblems: Dict[int, TempUserProblem] = {}