import asyncio
import numpy as np
from PIL import Image
import io
from sqlalchemy import collate, func, select, update
from sqlalchemy.orm import joinedload
from fastapi import APIRouter, BackgroundTasks
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Users, StudyInfo, Problems, Groups, Words, Blocks, Released, WrongType, ReleasedGroup
from fastapi import requests, UploadFile, File, Form
import requests
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import Problem, ProblemInfo, UserProblems, TempUserProblem, TempUserProblems, Answer
from problem.exceptions import *
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

# 연습 문제 반환
@router.get("/practice/set/", status_code = status.HTTP_200_OK)
async def read_problem_all(season:int, level:int, step:int, user: user_dependency, db: db_dependency):
    get_user_exception(user)

    result = await db.execute(select(Problems).filter(Problems.level == level, Problems.season == season).filter(Problems.step == step).filter(Problems.type == "normal"))
    stepinfo_model = result.scalars().all()

    TempUserProblems[user.get("id")] = TempUserProblem(0, 0, 0, 0, 0) # 객체 생성. 시작할 때.
    tempUserProblem = TempUserProblems.get(user.get("id"))
    tempUserProblem.solved_season = season
    tempUserProblem.solved_level = level
    tempUserProblem.solved_step = step
    tempUserProblem.solved_type = 'normal'

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

        problem.append({'id': p.id, 'englishProblem': p.englishProblem, 'koreaProblem': p.koreaProblem, 'blockColors':p_colors})

    return {'problems': problem}

# 연습문제: 레벨과 스텝 정보 반환
@router.get("/practice/info/", status_code = status.HTTP_200_OK)
async def practice_read_level_and_step(season:int, user: user_dependency, db: db_dependency):

    get_user_exception(user)
    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")).filter(Released.released_season == season))
    Released_model = result.scalars().first()
    get_season_exception(Released_model)
    

    result = await db.execute(select(Problems).filter(Problems.type == 'normal', Problems.season == season))
    problem_model = result.scalars().all()

    problems = set()
    result = []
    
    for problem in problem_model:
        if problem.level == 0 or problem.level:
            problems.add(problem.level)

    problems = list(problems)
    for level in problems:
        problem_step = set()  # 중복 제거를 위해 set 사용
        for problem in problem_model:
            if problem.level == level: 
                if problem.step == 0 or problem.step:
                    problem_step.add(problem.step) 
        result.append({'level_name': level, 'steps': list(problem_step)})
        
    return {'levels' : result }

# 확장 문제 반환
@router.get("/expert/set/", status_code = status.HTTP_200_OK)
async def read_problem_all(season:int, level:int, step:int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    result = await db.execute(select(Problems).filter(Problems.level == level, Problems.season == season).filter(Problems.step == step).filter(Problems.type == "ai"))
    stepinfo_model = result.scalars().all()

    get_problem_exception(stepinfo_model)
    TempUserProblems[user.get("id")] = TempUserProblem(0, 0, 0, 0, 0) # 객체 생성. 시작할 때.
    tempUserProblem = TempUserProblems.get(user.get("id"))
    tempUserProblem.solved_season = season
    tempUserProblem.solved_level = level
    tempUserProblem.solved_step = step
    tempUserProblem.solved_type = 'ai'
    
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

        problem.append({'id': p.id, 'englishProblem': p.englishProblem, 'koreaProblem': p.koreaProblem, 'blockColors':p_colors})

    return {'problems': problem}

# 확장 문제: 스텝 정보 반환
@router.get("/expert/info/", status_code = status.HTTP_200_OK)
async def read_level_and_step_expert(season:int, level:int, difficulty:int, user: user_dependency, db: db_dependency):
    get_user_exception(user)

    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")).filter(Released.released_season == season))
    Released_model = result.scalars().first()
    if Released_model is None:
        return {'detail':'해당 시즌을 가지고 있지 않습니다.'}

    result = await db.execute(select(Problems).filter(Problems.type == 'ai', Problems.season == season).filter(Problems.level == level, Problems.difficulty == difficulty))
    problem_model = result.scalars().all()
    problem_model = list(problem_model)
    tail_step = problem_model[0].step
    head_step = problem_model[0].step

    for problem in problem_model:
        p_step = problem.step
        if p_step > head_step:
            head_step = p_step
        elif p_step < tail_step:
            tail_step = p_step

    return {'steps' : list(range(tail_step, head_step+1))}

async def ocr(file):
    img_binary = await file.read()
    image = await asyncio.to_thread(Image.open, io.BytesIO(img_binary))

    # 이미지 크기 줄이기
    max_dimension = 1000  # 예: 최대 1000픽셀
    if max(image.size) > max_dimension:
        scale = max_dimension / max(image.size)
        image = image.resize((int(image.width * scale), int(image.height * scale)))

    img_array = np.array(image)
    # 이미지 읽는게 img_array 크기 줄이니까 빨라짐.
    from app.src.main import reader
    result = await asyncio.to_thread(reader.readtext, img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', text_threshold=0.4,low_text=0.3)
    sorted_data = sorted(result, key=lambda item: item[0][0][0])
    max_height = 0
    ref_block_idx = 0
    for block_idx, block in enumerate(sorted_data):
        height = block[0][2][1] - block[0][0][1]
        if height > max_height:
            max_height = height
            ref_block_idx = block_idx
    word_list=[sorted_data[ref_block_idx][1]]

    # 오른쪽부터
    if(ref_block_idx+1<len(sorted_data)):
        low_y = sorted_data[ref_block_idx][0][3][1]
        high_y = sorted_data[ref_block_idx][0][0][1]
        for block in sorted_data[ref_block_idx+1:]:
            if (min(low_y, block[0][3][1]) >= max(high_y, block[0][0][1])):
                low_y = block[0][3][1]
                high_y = block[0][0][1]
                word_list.append(block[1])

    # 왼쪽
    if(ref_block_idx>0):
        low_y = sorted_data[ref_block_idx][0][3][1]
        high_y = sorted_data[ref_block_idx][0][0][1]
        for block in reversed(sorted_data[:ref_block_idx]):
            if (min(low_y, block[0][3][1]) >= max(high_y, block[0][0][1])):
                low_y = block[0][3][1]
                high_y = block[0][0][1]
                word_list.insert(0,block[1])
    
    return word_list


# 학생이 문제를 풀었을 때, 일단 임시로 맞았다고 처리 (33초) (31초) -> (6~7초)
@router.post("/solve_OCR", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, 
                             file: UploadFile = File(...)):
    get_user_exception(user)
    
    # img_binary = await file.read()
    # image = await asyncio.to_thread(Image.open,io.BytesIO(img_binary))
    # # image = Image.open(io.BytesIO(img_binary))
    # img_array = np.array(image)

    word_list = await ocr(file)
    
    user_string = ' '.join(word_list)

    temp_result = await db.execute(select(Words).filter(collate(Words.words,'utf8mb4_bin').in_(word_list)))
    word_model = temp_result.scalars().all()
    
    return {"user_input": user_string, "words_id": word_model}


@router.post("/solve_check", status_code = status.HTTP_200_OK)
async def user_solve_problem(background_tasks: BackgroundTasks, user_string: str, problem_id: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)

    temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
    problem_model = temp_result.scalars().first()
    if problem_model is None:
        raise http_exception()

    correct_answer = problem_model.englishProblem
    problem_parse = parse_sentence(correct_answer)
    response_parse = parse_sentence(user_string)
    isAnswer, false_location = check_answer(problem_parse, list(response_parse))
    tempUserProblem = TempUserProblems.get(user.get("id")) # 정답 반환할 때.
    # 없으면 0으로 초기화하면서 추가
    if not(problem_id in tempUserProblem.problem_incorrect_count):
        tempUserProblem.problem_incorrect_count[problem_id] = 0

    #  조금 느리긴 함 (약 2초) > 백그라운드 실행
    if isAnswer:
        result = {"you did good job"}
    else:
        background_tasks.add_task(calculate_wrong_info, problem_id, problem_parse, response_parse, tempUserProblem, db)

        tempUserProblem.problem_incorrect_count[problem_id] += 1

        logger = logger_setup.get_logger(user.get("id"))
        logger.info(f"problem={correct_answer},answer={user_string}")

    return {"answer": correct_answer, "isAnswer": isAnswer}


# 스텝 끝날때 마지막에 문제 저장
@router.post("/send_problems_data/", status_code = status.HTTP_200_OK)
async def send_problems_data(mode_str:int, user: user_dependency, db: db_dependency):
    get_user_exception(user)

    # isGroup 확인
    isGroup = 0
    if mode_str == 'group':
        isGroup = 1

    # study info 찾아오기
    result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result2.scalars().first()
    if study_info is None:
        raise http_exception()

    # tempUserProblem 찾아오기 + 푼 문제 id 리스트
    tempUserProblem = TempUserProblems.get(user.get("id")) #

    # 푼 시즌, 레벨, 스텝, 타입 정보 할당
    solved_season = tempUserProblem.solved_season
    solved_level = tempUserProblem.solved_level
    solved_step = tempUserProblem.solved_step
    solved_type = tempUserProblem.solved_type

    # 푼 시즌-레벨의 wrong type 객체가 있는 지 조회하고, 없으면 만듦
    result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id, WrongType.season == solved_season, WrongType.level == solved_level))
    wrong_type = result.scalars().first()
    if wrong_type is None:
        await create_wrong_type(solved_season, solved_level, study_info.id, db)
        result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id, WrongType.season == solved_season, WrongType.level == solved_level))
        wrong_type = result.scalars().first()

    # update wrong type
    wrong_type.wrong_letter += tempUserProblem.totalIncorrectLetter
    wrong_type.wrong_punctuation += tempUserProblem.totalIncorrectPunc
    wrong_type.wrong_block += tempUserProblem.totalIncorrectBlock
    wrong_type.wrong_order += tempUserProblem.totalIncorrectOrder
    wrong_type.wrong_word += tempUserProblem.totalIncorrectWords
    db.add(wrong_type)

    # 개인 학습 and 연습 문제 다 풀었음--> 다음 스텝 or 레벨 해금
    if isGroup == 0 and solved_type == 'normal':
        result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")))
        released_model = result.scalars().first()
        result = await db.execute(select(Problems.step).filter(Problems.season == solved_season, Problems.type==solved_type, Problems.level == solved_level))
        all_steps = result.scalars().all()
        max_step = max(all_steps)
        # released_level && released_step에 해당하는 문제를 풀어야 다음거 해금
        if released_model.released_level == solved_level and released_model.released_step == solved_step:
            if max_step == solved_step:
                if solved_level < 3:    # 한 시즌 당 레벨은 3까지만 있다고 가정...
                    released_model.released_level += 1
                    released_model.released_step = 1
            else:
                released_model.released_step += 1
            db.add(released_model)

    # 푼 문제 id 리스트
    solved_problem_ids = list(tempUserProblem.problem_incorrect_count.keys())
    # 푼 문제들의 id로 문제 객체들 찾아오기
    result = await db.execute(select(Problems).filter(Problems.id.in_(solved_problem_ids)))
    solved_problems = result.scalars().all()

    # 푼 문제들의 정오답 여부에 따른 정오답 횟수 저장
    for i in range(len(solved_problem_ids)):
        # step을 모두 풀었다면, 모든 문제는 적어도 한 번은 맞은 것 --> 기존 correct_problems에 없으면 무조건 추가해야함
        if solved_problems[i] not in study_info.correct_problems:
            study_info.correct_problems.append(solved_problems[i])

        # problem_incorrect_count != 0 --> 틀린 적이 있다, incorrect_problems에도 추가
        if tempUserProblem.problem_incorrect_count[solved_problem_ids[i]] != 0:            
            if solved_problems[i] not in study_info.incorrect_problems:
                study_info.incorrect_problems.append(solved_problems[i])

    for problem_id, incorrect_count in tempUserProblem.problem_incorrect_count.items():
        await increment_correct_problem_count(study_info.id, problem_id, 1, isGroup, db)
        if incorrect_count != 0:
            await increment_incorrect_problem_count(study_info.id, problem_id, incorrect_count, isGroup, db)

    # for problem in user_problems.problems:
    #         await increment_correct_problem_count(study_info.id, problem.problem_id, 1, db)
    #         if problem.incorrectCount != 0:
    #             await increment_incorrect_problem_count(study_info.id, problem.problem_id, problem.incorrectCount, db)

    db.add(study_info)
    await db.commit()
    return {"detail": "저장되었습니다."}