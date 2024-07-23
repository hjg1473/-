import asyncio
from typing_extensions import List
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
async def user_solve_problem(problem_id : int = Form(...), files: List[UploadFile] = File(...)):
    user_word_list=[]
    file_count = len(files)

    from app.src.main import reader

    for file_index, file in enumerate(files):
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        img_array = np.array(image)
        result = reader.readtext(img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)
 
        sorted_data = sorted(result, key=lambda item: item[0][0][0])

        # 가장 낮은 불록의 인덱스를 구함
        low_point=0
        ref_block_idx=0
        for index, item in enumerate(sorted_data):
            point = item[0][3][1]
            if point > low_point:
                low_point = point
                ref_block_idx = index
        lower_word_list=[sorted_data[ref_block_idx][1]]

        # 오른쪽부터
        if(ref_block_idx+1<len(sorted_data)):
            low_y = sorted_data[ref_block_idx][0][3][1]
            high_y = sorted_data[ref_block_idx][0][0][1]
            for block in sorted_data[ref_block_idx+1:]:
                if (min(low_y, block[0][3][1]) >= max(high_y, block[0][0][1])):
                    low_y = block[0][3][1]
                    high_y = block[0][0][1]
                    lower_word_list.append(block[1])

        # 왼쪽
        if(ref_block_idx>0):
            low_y = sorted_data[ref_block_idx][0][3][1]
            high_y = sorted_data[ref_block_idx][0][0][1]
            for block in reversed(sorted_data[:ref_block_idx]):
                if (min(low_y, block[0][3][1]) >= max(high_y, block[0][0][1])):
                    low_y = block[0][3][1]
                    high_y = block[0][0][1]
                    lower_word_list.insert(0,block[1])

        # 단어가 잘린 경우를 피하기 위해 리스트의 앞 혹은 뒤를 자름
        if file_count == 1:
            user_word_list = lower_word_list
        else:
            if file_index==0:
                lower_word_list.pop()
            elif file_index==file_count-1:
                lower_word_list.pop(0)
            else:
                lower_word_list.pop(0)
                lower_word_list.pop()
        
        seen_words = set(user_word_list)        

        for index, word in enumerate(lower_word_list):

            if word not in seen_words:
                user_word_list.extend(lower_word_list[index:])
                break
    
    user_string = " ".join(user_word_list)
    correct_answer = await db_dependency.query(Problems).filter(Problems.id==problem_id).first().englishProblem
    isAnswer=False
    if user_string==correct_answer:
        isAnswer=True
    
    return {'user_string': user_string, 'isAnswer': isAnswer, 'correct_answer': correct_answer}