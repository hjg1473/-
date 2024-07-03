from typing import Annotated, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo, Problems
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from routers.auth import get_current_user, get_user_exception

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter(
    prefix="/problem",
    tags=["problem"],
    responses={404: {"description": "Not found"}}
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]

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

@router.post("/create")
async def create_problem(problem: Problem,
                      user: dict = Depends(get_current_user),
                      db: Session = Depends(get_db)):
    if user is None:
        raise get_user_exception()
    problem_model = models.Problems()
    problem_model.season = problem.season
    problem_model.type = problem.type
    problem_model.problemLevel = problem.problemLevel
    problem_model.koreaProblem = problem.koreaProblem
    problem_model.englishProblem = problem.englishProblem
    problem_model.img_path = problem.img_path
    # problem_model.owner_id = user.get("id")

    db.add(problem_model)
    db.commit()

    return successful_response(201)

@router.get("/info", status_code = status.HTTP_200_OK)
async def read_problem_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    return db.query(Problems).all()
    # 모든 문제 정보 반환 (일단)

# 학생이 문제를 풀었을 때,
@router.post("/solve", status_code = status.HTTP_200_OK)
async def user_solve_problem(answer: Answer, 
                            user: user_dependency, db: db_dependency):
    user_instance = db.query(Users).filter(Users.id == user.get("id")).first()

    study_info = StudyInfo(stdLevel=1, owner=user_instance) # 학습 정보 추가. 

    # 학생이 제시받은 문제 id와 문제 id 비교해서 문제 찾아냄.
    problem = db.query(Problems)\
        .filter(Problems.id == answer.problem_id)\
        .first()

    # 학생이 제출한 답변을 OCR을 돌리고 있는 GPU 환경으로 전송.
    # answer.picture 사용

    # 로직 추가
    # 문제를 맞춘 경우, correct_problems에 추가
    study_info.correct_problems.append(problem)
    # 문제를 틀린 경우, incorrect_problems에 추가 
    study_info.incorrect_problems.append(problem)
    
    db.add(study_info)
    db.commit()

    # return 
    # 문제가 정답인지 아닌지 반환.

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
