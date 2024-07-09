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
from fastapi import requests, UploadFile, File, Form

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


# 연습 문제 반환 (10개)
@router.get("/season/{season_name}/type/{type_name}/practice_set", status_code = status.HTTP_200_OK)
async def read_problem_all(season_name:str, type_name:str, user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    if season_name != ('시즌1' or '시즌2'):
        raise HTTPException(status_code=404, detail='일치하는 시즌이 없습니다. (시즌명 : 시즌1, 시즌2)')
    
    if type_name != ('부정문' or '의문문' or '단어와품사'):
        raise HTTPException(status_code=404, detail='일치하는 유형이 없습니다. (유형 : 부정문, 의문문, 단어와품사)')

    # 시즌과 타입이 같은 모든 문제 반환. 
    season_type_problem = db.query(Problems).filter(Problems.season == season_name)\
    .filter(Problems.type == type_name)\
    .all()

    if season_type_problem is None:
        raise HTTPException(status_code=404, detail='문제 데이터가 존재하지 않습니다.')


    # 모든 학습 정보 반환
    study_info = db.query(StudyInfo).options(
        joinedload(StudyInfo.correct_problems),
        joinedload(StudyInfo.incorrect_problems)
    ).filter(StudyInfo.owner_id == user.get("id")).first()

    # 시즌, 유형 제외, 이미지 정보 제외, cproblem_id 제외, / 시즌, 유형은 따로 한번에 / 선택한 유형의 학생 수준을 전달 / await 사용
    solved_problems = []
    for problem in study_info.correct_problems:
        if problem.season == season_name and problem.type == type_name:
            solved_problems.append({
                'id': problem.id,
                'isCorrect': 1
            })

    for problem in study_info.incorrect_problems:
        solved_problems.append({
            'id': problem.id,
            'isCorrect': 0
        })

    # season_name, type_name, 
    send_data_to_gpu = {
        'owner_id': study_info.id,
        'type1Level': study_info.type1Level,
        'type2Level': study_info.type2Level,
        'type3Level': study_info.type3Level,
        'season': season_name,
        'type': type_name,
        'solved_problems': solved_problems }
    
    # requests.post("http://URL/server/calculate_student_level", json=send_data_to_gpu)
    
    if study_info is None:
        raise http_exception()
    # 받을 때, 업데이트된 유형별 학생 수준만. 
    # study_info.type1Level

    # 수준을 받았음. 이제 문제는 어떻게 선별?


    # 임의로 앞에서부터 10개 사용
    select_problem = []
    cnt = 1
    for problem in season_type_problem:
        select_problem.append({'id': problem.id, 'englishProblem': problem.englishProblem, 'koreanProblem': problem.koreaProblem})
        cnt += 1
        if cnt == 10:
            return select_problem

    # 10개가 안되도 출력 (임시)
    return select_problem

# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
@router.post("/solve", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, problem_id: int = Form(...), file: UploadFile = File(...)):
    user_instance = db.query(Users).filter(Users.id == user.get("id")).first()

    study_info = db.query(StudyInfo).filter(StudyInfo.owner_id == user.get("id")).first()
    if study_info is None:
        raise http_exception()

    # 학생이 제시받은 문제 id와 문제 id 비교해서 문제 찾아냄.
    problem = db.query(Problems)\
        .filter(Problems.id == problem_id)\
        .first()

    # 학생이 제출한 답변을 OCR을 돌리고 있는 GPU 환경으로 전송 및 단어를 순서대로 배열로 받음.
    GPU_SERVER_URL = "http://146.148.75.252:8000/ocr/" 

    img_binary = await file.read()
    file.filename = "img.png"
    files = {"file": (file.filename, img_binary)}
    user_word_list = requests.post(GPU_SERVER_URL, files=files)
    
    # 단어리스트를 문장으로 변환
    user_string = " ".join(user_word_list.json())

    #answer = problem.englishProblem
    answer = "I am pretty"

    # 문제를 맞춘 경우, correct_problems에 추가. id 만 추가. > 하고 싶은데 안되서 일단 problem 전체 저장함.
    # 일단 정답인 경우만 구현, 문장이 다르면 오답처리
    if(user_string==answer):
        study_info.correct_problems.append(problem)
        db.add(study_info)
        db.commit()

        return {'isAnswer' : problem.englishProblem, 'user_answer': user_string, 'false_location': '정답 알고리즘 결과'}
    else:
        return 


def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
