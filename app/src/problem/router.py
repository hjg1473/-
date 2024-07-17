import numpy as np
from PIL import Image
import io
from sqlalchemy import select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter, HTTPException
from starlette import status
import easyocr
import asyncio
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Problems
from fastapi import requests, UploadFile, File, Form
from app.src.main import reader
import requests
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import Problem
from problem.exceptions import http_exception, successful_response, get_user_exception
from problem.service import create_problem_in_db

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

@router.get("/info", status_code = status.HTTP_200_OK)
async def read_problem_all(user: user_dependency, db: db_dependency):
    get_user_exception(user)
    result = await db.execute(select(Problems))
    problem_model = result.scalars().all()
    return problem_model
    # 모든 문제 정보 반환 (일단)


# 연습 문제 반환 (10개)
@router.get("/season/{season_name}/type/{type_name}/practice_set", status_code = status.HTTP_200_OK)
async def read_problem_all(season_name:str, type_name:str, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
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
    correct_problems = []
    for problem in study_info.correct_problems:
        correct_problems.append({
            'id': problem.id
        })

    send_data_to_gpu = {
        'owner_id': study_info.id,
        'type1Level': study_info.type1Level,
        'type2Level': study_info.type2Level,
        'type3Level': study_info.type3Level,
        'season': season_name,
        'type': type_name,
        'coorect_problems': correct_problems }
    
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

# # 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
# @router.post("/solve", status_code = status.HTTP_200_OK)
# async def user_solve_problem(user: user_dependency, db: db_dependency, problem_id: int = Form(...), file: UploadFile = File(...)):
#     get_user_exception(user)

#     # study_info = db.query(StudyInfo).filter(StudyInfo.owner_id == user.get("id")).first()
#     result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
#     study_info = result.scalars().first()
#     if study_info is None:
#         raise http_exception()

#     # 학생이 제시받은 문제 id와 문제 id 비교해서 문제 찾아냄.
#     # problem = db.query(Problems)\
#     #     .filter(Problems.id == problem_id)\
#     #     .first()
#     result = await db.execute(select(Problems).filter(Problems.id == problem_id))
#     problem = result.scalars().first()
    
#     img_binary = await file.read()

#     reader = await easyocr.Reader(['en'])
#     result = await reader.readtext(img_binary,allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)
#     # 1. 각 사각형의 높이 구하기
#     heights = []
#     for item in result:
#         coords = item[0]
#         y_values = [point[1] for point in coords]
#         height = max(y_values) - min(y_values)
#         heights.append(height)

#     # 높이의 최댓값 구하기
#     max_height = max(heights)

#     # 2. 높이의 최댓값의 0.7배 이하 무시하기
#     threshold = max_height * 0.7
#     filtered_data = [item for item, height in zip(result, heights) if height > threshold]

#     # 3. 남은 단어들을 x축 오름차순으로 정렬해서 단어 리스트 만들기
#     sorted_data = sorted(filtered_data, key=lambda item: min(point[0] for point in item[0]))
#     words = [item[1] for item in sorted_data]

#     user_word_list = words
    
#     user_string = " ".join(user_word_list.json())

#     #answer = problem.englishProblem
#     answer = "I am pretty"
    
#     return {'user_string': user_string }
#     # 문제를 맞춘 경우, correct_problems에 추가. id 만 추가. > 하고 싶은데 안되서 일단 problem 전체 저장함.
#     # 일단 정답인 경우만 구현, 문장이 다르면 오답처리
#     if(user_string==answer):
#         study_info.correct_problems.append(problem)
#         db.add(study_info)
#         await db.commit()

#         return {'isAnswer' : problem.englishProblem, 'user_answer': user_string, 'false_location': '정답 알고리즘 결과'}
#     else:
#         return 


# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
@router.post("/solve_test", status_code = status.HTTP_200_OK)
async def user_solve_problem(file: UploadFile = File(...)):
    
    img_binary = await file.read()

    # image = Image.open(io.BytesIO(img_binary))
    image = await asyncio.to_thread(Image.open,io.BytesIO(img_binary))
    img_array = np.array(image)
    # from app.src.main import reader
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