import asyncio
import numpy as np
from PIL import Image
import io
from sqlalchemy import select
from sqlalchemy.orm import joinedload
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Problems, Blocks
from fastapi import requests, UploadFile, File, Form
import requests
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import Problem, ProblemInfo, UserProblems, TempUserProblem, TempUserProblems, Answer
from problem.exceptions import http_exception, successful_response, get_user_exception, get_problem_exception, get_studyStart_exception, get_doubleEnd_exception
from problem.service import *
from problem.utils import check_answer, search_log_timestamp
from problem.constants import INDEX, QUERY_MATCH_ALL
import re
from elasticsearch import AsyncElasticsearch
from datetime import datetime, timezone
import logging
from app.src.logging_setup import LoggerSetup

LOGGER = logging.getLogger(__name__)
logger_setup = LoggerSetup()

router = APIRouter(
    prefix="/problem",
    tags=["problem"],
    responses={404: {"description": "Not found"}}
)

es = AsyncElasticsearch(['http://3.34.58.76:9200'])

@router.get("/study_start")
async def study_start(user: user_dependency):
    get_user_exception(user)
    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyStart ---")
    TempUserProblems[user.get("id")] = TempUserProblem(0, 0, 0, 0, 0) # 객체 생성. 시작할 때.
    return {"detail":"학습을 시작합니다."}

@router.get("/study_end")
async def study_end(user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    res = await es.search(index=INDEX, body=QUERY_MATCH_ALL)
    
    studyStart_timestamp = search_log_timestamp(res, "studyStart", user.get("id"))

    get_studyStart_exception(studyStart_timestamp)

    recent_studyEnd_timestamp = search_log_timestamp(res, "studyEnd", user.get("id"))

    if recent_studyEnd_timestamp is None:
        recent_studyEnd_timestamp = datetime.fromisoformat("2024-01-01T00:00:00.847Z".replace('Z', '+00:00'))

    get_doubleEnd_exception(studyStart_timestamp, recent_studyEnd_timestamp)

    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyEnd ---")

    time_difference = datetime.utcnow().replace(tzinfo=timezone.utc) - studyStart_timestamp
    seconds_difference = time_difference.total_seconds() // 60
    
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
    studyinfo_model = result.scalars().first()

    studyinfo_model.totalStudyTime += int(seconds_difference)
    db.add(studyinfo_model)
    await db.commit()

    return {"detail":"학습을 마쳤습니다.",'study_time(minutes)': int(seconds_difference)}

# @router.post("/create")
# async def create_problem(problem: Problem, user: user_dependency, db: db_dependency):
#     get_user_exception(user)
#     await create_problem_in_db(db, problem)
#     return successful_response(201)

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
        problem_step = set()  # 중복 제거를 위해 set 사용
        for problem in problem_model:
            if problem.level == level: 
                if problem.step:
                    problem_step.add(problem.step) 
        result.append({'level_name': level, 'steps': list(problem_step)})
        
    # 학생 정보 테이블에 current_level, current_step 추가.
    return {'current_level': 1, 'current_step': 1, 'levels' : result }


# 연습 문제 반환
@router.get("practice_set/level={level}/step={step}", status_code = status.HTTP_200_OK)
async def read_problem_all(level:int, step:int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    result = await db.execute(select(Problems).filter(Problems.level == level).filter(Problems.step == step).filter(Problems.type == "normal"))
    stepinfo_model = result.scalars().all()

    get_problem_exception(stepinfo_model)

    problem = []
    for p in stepinfo_model:
        p_str = p.englishProblem
        p_list = parse_sentence(p_str)
        p_colors = []
        # 단어마다 block 색깔 가져오기 ...
        for word in p_list:
            result = await db.execute(select(Words).filter(Words.words == word))
            word_model = result.scalars().first()
            
            result = await db.execute(select(Blocks).filter(Blocks.id == word_model.block_id))
            block_model = result.scalars().first()
            p_colors.append(block_model.color)

        problem.append({'id': p.id, 'englishProblem': p.englishProblem, 'blockColors':p_colors})

    return {'problems': problem}


# # 푼 문제 학습 정보 업데이트
# @router.post("/update_study_data", status_code = status.HTTP_200_OK)
# async def send_problems_data(user: user_dependency, db: db_dependency, answer: Answer):

#     get_user_exception(user)

#     # study info 가져오기
#     temp_result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
#     study_info = temp_result.scalars().first()

#     # 문제 id로 문제 가져오기
#     temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
#     problem_model = temp_result.scalars().first()
#     problem = problem_model.englishProblem
#     problem_parse = parse_sentence(problem)

#     # OCR로 response 읽어오기
#     img_binary = await file.read()
#     image = await asyncio.to_thread(Image.open,io.BytesIO(img_binary))
#     # image = Image.open(io.BytesIO(img_binary))
#     img_array = np.array(image)
#     from app.src.main import reader
#     result = await asyncio.to_thread(reader.readtext, img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)

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
#     response_parse = [item[1] for item in sorted_data]

#     # 채점
#     isAnswer, false_location = check_answer(problem_parse, response_parse)

#     if isAnswer:
#         study_info.correct_problems.append(problem_model)
#         await increment_correct_problem_count(study_info.id, problem_id, db)
#         count = await get_correct_problem_count(study_info.id, problem_id, db)
#         db.add(study_info)
#         await db.commit()
#         result = {"you did good job":True, "correct_problems":count}
#     else:
#         study_info.incorrect_problems.append(problem_model)
#         result = await calculate_wrong_info(problem_parse, response_parse, db)
#         await increment_incorrect_problem_count(study_info.id, problem_id, db)
#         count = await get_incorrect_problem_count(study_info.id, problem_id, db)
#         result["incorrect_problems"] = count
#         db.add(study_info)
#         await db.commit()
#     return result    

# # 푼 문제 학습 정보 업데이트
# @router.post("/update_study_data", status_code = status.HTTP_200_OK)
# async def send_problems_data(user: user_dependency, db: db_dependency, answer: Answer):

#     get_user_exception(user)
#     tempUserProblem = TempUserProblems.get(user.get("id")) # 정답 반환할 때.
#     tempUserProblem.totalFullStop += 1 # 알고리즘 따라서 어느걸 틀렸는지.
#     if answer.problem_id in tempUserProblem.problem_incorrect_count:
#         tempUserProblem.problem_incorrect_count[answer.problem_id] += 1
#     else:
#         tempUserProblem.problem_incorrect_count[answer.problem_id] = 1
#     for problem_id, incorrect_count in tempUserProblem.problem_incorrect_count.items():
#         print(f"Problem ID: {problem_id}, Incorrect Count: {incorrect_count}")
#     return tempUserProblem

# 스텝 끝날때 마지막에 문제 저장
@router.post("/send_problems_data", status_code = status.HTTP_200_OK)
async def send_problems_data(user: user_dependency, db: db_dependency):
    get_user_exception(user)
    result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result2.scalars().first()
    if study_info is None:
        raise http_exception()
    
    tempUserProblem = TempUserProblems.get(user.get("id")) # 정답 반환할 때.
    problem_ids = list(tempUserProblem.problem_incorrect_count.keys())
    result = await db.execute(select(Problems).filter(Problems.id.in_(problem_ids)))
    problems_info = result.scalars().all()
    # return problems_info
    for problem in problems_info:
        if problem not in study_info.correct_problems: # 문제 리스트 검사. 없다면 추가. 근데 매번 해야됨? ..
            study_info.correct_problems.append(problem)
        if problem not in study_info.incorrect_problems:
            study_info.incorrect_problems.append(problem)

    for problem_id, incorrect_count in tempUserProblem.problem_incorrect_count.items():
        await increment_correct_problem_count(study_info.id, problem_id, 1, db)
        if incorrect_count != 0:
            await increment_incorrect_problem_count(study_info.id, problem_id, incorrect_count, db)

    # for problem in user_problems.problems:
    #         await increment_correct_problem_count(study_info.id, problem.problem_id, 1, db)
    #         if problem.incorrectCount != 0:
    #             await increment_incorrect_problem_count(study_info.id, problem.problem_id, problem.incorrectCount, db)
                
    db.add(study_info)
    await db.commit()
    return {"detail": "저장되었습니다."}


# # 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
# @router.post("/solve", status_code = status.HTTP_200_OK)
# async def user_solve_problem(user: user_dependency, db: db_dependency, problem_id: int = Form(...), file: UploadFile = File(...)):
#     get_user_exception(user)
#     user_instance = db.query(Users).filter(Users.id == user.get("id")).first()

#     study_info = db.query(StudyInfo).filter(StudyInfo.owner_id == user.get("id")).first()
#     if study_info is None:
#         raise http_exception()

#     # 학생이 제시받은 문제 id와 문제 id 비교해서 문제 찾아냄.
#     problem = db.query(Problems)\
#         .filter(Problems.id == problem_id)\
#         .first()
#     temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
#     problem_model = temp_result.scalars().first()
    
#     # 학생이 제출한 답변을 OCR을 돌리고 있는 GPU 환경으로 전송 및 단어를 순서대로 배열로 받음.
#     GPU_SERVER_URL = "http://146.148.75.252:8000/ocr/" 
    
#     img_binary = await file.read()
#     file.filename = "img.png"
#     files = {"file": (file.filename, img_binary)}
#     user_word_list = requests.post(GPU_SERVER_URL, files=files)
    
#     user_string = " ".join(user_word_list.json())

#     #answer = problem.englishProblem
#     answer = "I am pretty"
    
#     # 문제를 맞춘 경우, correct_problems에 추가. id 만 추가. > 하고 싶은데 안되서 일단 problem 전체 저장함.
#     # 일단 정답인 경우만 구현, 문장이 다르면 오답처리
#     isAnswer, false_location = check_answer(answer, user_string)
#     if isAnswer:
#         study_info.correct_problems.append(problem)
#     else:
#         study_info.incorrect_problems.append(problem)
#     db.add(study_info)
#     db.commit()

#     return {'isAnswer' : problem.englishProblem, 'user_answer': user_string, 'false_location': false_location}

# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 
@router.post("/solve_test", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, problem_id: int = Form(...), file: UploadFile = File(...)):
    get_user_exception(user)

    # 학생이 제시받은 문제 id와 문제 id 비교해서 문제 찾아냄.
    temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
    problem_model = temp_result.scalars().first()
    if problem_model is None:
        raise http_exception()
    
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
    
    correct_answer = problem_model.englishProblem
    
    user_string = ' '.join(words)
    # isAnswer, false_location = check_answer(correct_answer, words)
    problem_parse = parse_sentence(correct_answer)
    response_parse = parse_sentence(user_string)

    isAnswer, false_location = check_answer(problem_parse, response_parse)
    tempUserProblem = TempUserProblems.get(user.get("id")) # 정답 반환할 때.
    if isAnswer:
        result = {"you did good job"}
    else:
        result = await calculate_wrong_info(problem_parse, response_parse, db)
        tempUserProblem.totalFullStop += result["letter_wrong"] 
        tempUserProblem.totalTextType += result["punc_wrong"]
        tempUserProblem.totalIncorrectCompose += result["block_wrong"] 
        tempUserProblem.totalIncorrectWords += result["word_wrong"] 
        tempUserProblem.totalIncorrectOrder += result["order_wrong"] 

    if problem_id in tempUserProblem.problem_incorrect_count:
        tempUserProblem.problem_incorrect_count[problem_id] += 1
    else:
        tempUserProblem.problem_incorrect_count[problem_id] = 1

    return result


# @router.post("/solve_test_feedback", status_code = status.HTTP_200_OK)
# async def user_solve_problem(response:str, problem_id:int, user:user_dependency, db:db_dependency):
#     get_user_exception(user)

#     result = await db.execute(select(Problems).filter(Problems.id == problem_id))
#     problem_model = result.scalars().first()
#     if problem_model is None:
#         raise http_exception()
#     problem = problem_model.englishProblem
#     # 일단 문자열로 받아서 테스트
#     problem_parse = parse_sentence(problem)
#     response_parse = parse_sentence(response)

#     isAnswer, false_location = check_answer(problem_parse, response_parse)
#     result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
#     study_info = result2.scalars().first()

#     if isAnswer:
#         study_info.correct_problems.append(problem_model)
#         await increment_correct_problem_count(study_info.id, problem_model.id, 1, db)
#         db.add(study_info)
#         await db.commit()
#         result = {"you did good job"}
#     else:
#         study_info.incorrect_problems.append(problem_model)
#         result = await calculate_wrong_info(problem_parse, response_parse, db)
#     db.add(study_info)
#     await db.commit()

#     return result