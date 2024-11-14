from typing import List
from pydantic import BaseModel


class PinNumber(BaseModel):
    pin_number: int

class SoloGroup(BaseModel):
    mode: str # solo , group

class SeasonList(BaseModel):
    season: List[int] = []

class TableData:
    def __init__(self, table_id, table_count, problems):
        self.table_id = table_id
        self.table_count = table_count
        self.problems = problems

class LogResponse(BaseModel):
    problem: str
    answer: str