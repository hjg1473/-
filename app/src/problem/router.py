import asyncio
import numpy as np
from PIL import Image
import io
from sqlalchemy import select
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Problems
from fastapi import requests, UploadFile, File, Form
import requests
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import Problem
from problem.exceptions import http_exception, successful_response, get_user_exception, get_problem_exception
from problem.service import *
from problem.utils import check_answer

router = APIRouter(
    prefix="/problem",
    tags=["problem"],
    responses={404: {"description": "Not found"}}
)


@router.post("/create")
async def create_problem(problem: Problem, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    await create_problem_in_db(db, problem)
    return successful_response(201)

@router.get("/test_info", status_code = status.HTTP_200_OK)
async def read_problem_all(user: user_dependency, db: db_dependency):
    get_user_exception(user)
    problem_model = await get_problem_info(db)
    return problem_model
    # 모든 문제 정보 반환 (일단)


# 레벨과 스텝 정보 반환
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_level_and_step_all(user: user_dependency, db: db_dependency):

    get_user_exception(user)

    result = await db.execute(select(Problems))
    problem_model = result.scalars().all()

    result2 = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
    studyinfo_model = result2.scalars().first()

    problems = set()
    result = []

    for problem in problem_model:
        if problem.level:
            problems.add(problem.level)

    problems = list(problems)
    for level in problems:
        problem_step = []
        for problem in problem_model:
            if problem.level == level: 
                if problem.step:
                    problem_step.append(problem.step) 
        result.append({'level_name': level, 'steps': problem_step})
        
    # 학생 정보 테이블에 current_level, current_step 추가.
    return {'current_level': 1, 'current_step': 1, 'levels' : result }


# 연습 문제 반환
@router.get("practice_set/level={level}/step={step}", status_code = status.HTTP_200_OK)
async def read_problem_all(level:str, step:str, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    result = await db.execute(select(Problems).filter(Problems.level == level).filter(Problems.step == step))
    stepinfo_model = result.scalars().all()

    get_problem_exception(stepinfo_model)

    problem = []
    for p in stepinfo_model:
        problem.append({'id': p.id, 'englishProblem': p.englishProblem})
    return {'problems': problem}


# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
@router.post("/solve", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, problem_id: int = Form(...), file: UploadFile = File(...)):
    get_user_exception(user)
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
    
    user_string = " ".join(user_word_list.json())

    #answer = problem.englishProblem
    answer = "I am pretty"
    
    # 문제를 맞춘 경우, correct_problems에 추가. id 만 추가. > 하고 싶은데 안되서 일단 problem 전체 저장함.
    # 일단 정답인 경우만 구현, 문장이 다르면 오답처리
    isAnswer, false_location = check_answer(answer, user_string)
    if isAnswer:
        study_info.correct_problems.append(problem)

    else:
        study_info.incorrect_problems.append(problem)
    db.add(study_info)
    db.commit()

    return {'isAnswer' : problem.englishProblem, 'user_answer': user_string, 'false_location': false_location}


# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
@router.post("/solve_test", status_code = status.HTTP_200_OK)
async def user_solve_problem(file: UploadFile = File(...)):
    
    img_binary = await file.read()
    image = await asyncio.to_thread(Image.open,io.BytesIO(img_binary))
    # image = Image.open(io.BytesIO(img_binary))
    img_array = np.array(image)
    from app.src.main import reader
    result = await asyncio.to_thread(reader.readtext, img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)
    # result = reader.readtext(img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)
    # 1. 각 사각형의 높이 구하기
    heights = []
    for item in result:
        coords = item[0]
        y_values = [point[1] for point in coords]
        height = max(y_values) - min(y_values)
        heights.append(height)

    # 높이의 최댓값 구하기
    max_height = max(heights)

    # 2. 높이의 최댓값의 0.7배 이하 무시하기
    threshold = max_height * 0.7
    filtered_data = [item for item, height in zip(result, heights) if height > threshold]

    # 3. 남은 단어들을 x축 오름차순으로 정렬해서 단어 리스트 만들기
    sorted_data = sorted(filtered_data, key=lambda item: min(point[0] for point in item[0]))
    words = [item[1] for item in sorted_data]

    user_word_list = words
    
    user_string = " ".join(user_word_list)

    #answer = problem.englishProblem
    answer = "I am pretty"
    
    return {'user_string': user_string }