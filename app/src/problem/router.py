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
from app.src.models import StudyInfo, Problems, Words, Blocks, Released, WrongType
from fastapi import UploadFile, File, Form
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import TempUserProblem, TempUserProblems
from problem.exceptions import *
from problem.service import *
from problem.utils import check_answer, search_log_timestamp
from problem.constants import INDEX, QUERY_MATCH_ALL
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

async def calculate_study_times(user, db):

    res = await es.search(index=INDEX, body=QUERY_MATCH_ALL)
    studyStart_timestamp = search_log_timestamp(res, "studyStart", user.get("id"))
    # get_studyStart_exception(studyStart_timestamp)
    if studyStart_timestamp is None: #
        return

    recent_studyEnd_timestamp = search_log_timestamp(res, "studyEnd", user.get("id"))
    if recent_studyEnd_timestamp is None:
        recent_studyEnd_timestamp = datetime.fromisoformat("2024-01-01T00:00:00.847Z".replace('Z', '+00:00'))
    # get_doubleEnd_exception(studyStart_timestamp, recent_studyEnd_timestamp)
    if studyStart_timestamp < recent_studyEnd_timestamp:
        return

    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyEnd ---")

    time_difference = datetime.utcnow().replace(tzinfo=timezone.utc) - studyStart_timestamp
    seconds_difference = time_difference.total_seconds() // 60
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
    studyinfo_model = result.scalars().first()
    studyinfo_model.totalStudyTime += int(seconds_difference)
    db.add(studyinfo_model)
    await db.commit()

    return

@router.post("/study_end", status_code=status.HTTP_200_OK)
async def study_end(mode_str: str, user: user_dependency, db: db_dependency, background_tasks: BackgroundTasks):
    get_user_exception(user)
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

    get_studyStart_exception(tempUserProblem)

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
                if solved_level < 3:    # 한 시즌 당 레벨은 2까지만 있다고 가정...
                    released_model.released_level += 1
                    released_model.released_step = 0
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

    db.add(study_info)
    await db.commit()

    TempUserProblems.pop(user.get("id"))

    background_tasks.add_task(calculate_study_times, user, db)

    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")))
    released_model = result.scalars().all()
    released = []
    for r in released_model:
        released.append({'season':r.released_season, 'level':r.released_level, 'step':r.released_step})
    return {'released': released}

# 시즌, 레벨에 맞는 오답 노트 문제 정보 반환
@router.get("/practice/wrong_note/set/", status_code=status.HTTP_200_OK)
async def read_problem_wrongs(mode_str:str, season:int, level:int, user:user_dependency, db:db_dependency):
    get_user_exception(user)
    isGroup = 0
    if mode_str == 'group':
        isGroup = 1
    # study info 찾아오기
    result2 = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result2.scalars().first()
    result = await db.execute(select(incorrect_problem_table.c.problem_id).\
                              where(
                                    incorrect_problem_table.c.study_info_id == study_info.id,
                                    incorrect_problem_table.c.isGroup == isGroup,
                                    incorrect_problem_table.c.count > 0
                              ))
    wrong_problems = result.scalars().all()

    filterd_problems = []
    for ip in list(study_info.incorrect_problems):
        if ip.id in wrong_problems and ip.type=='normal' and int(ip.season) == season and ip.level == level:
            filterd_problems.append(ip)

    result = await db.execute(select(Blocks))
    blocks = result.scalars().all()

    result = await db.execute(select(Words))
    words = result.scalars().all()
    problems = []
    for item in filterd_problems:
        p_list = parse_sentence(item.englishProblem)
        colors = []
        for word in p_list:
            word_block_id = list(filter(lambda item : item.words == word, words))[0].block_id
            colors.append(list(filter(lambda item : item.id == word_block_id, blocks))[0].color)
        problems.append({'id':item.id, 'englishProblem':item.englishProblem, 'koreaProblem':item.koreaProblem, 'blockColors':colors})
    
    return {"incorrects":problems}


# 오답노트 종료 --> 해당 레벨의 오답들 빼기
@router.post("/practice/wrong_note/end/", status_code=status.HTTP_200_OK)
async def read_problem_wrongs(mode_str:str, season:int, level:int, user:user_dependency, db:db_dependency):
    get_user_exception(user)
    isGroup = 0
    if mode_str == 'group':
        isGroup = 1

    # fetch study info
    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user.get("id")))
    study_info = result.scalars().first()

    result = await db.execute(select(incorrect_problem_table.c.problem_id).\
                              where(
                                    incorrect_problem_table.c.study_info_id == study_info.id,
                                    incorrect_problem_table.c.isGroup == isGroup,
                                    incorrect_problem_table.c.count > 0
                              ))
    wrong_problems = result.scalars().all()
    filterd_problems = []
    for ip in list(study_info.incorrect_problems):
        if ip.id in wrong_problems and ip.type=='normal' and int(ip.season) == season and ip.level == level:
            study_info.incorrect_problems.remove(ip)
            await clear_incorrect_problem_count(study_info.id, ip.id, isGroup, db)

    db.add(study_info)
    await db.commit()
    return {"detail":"success"}


# fetch practice problems as season, level, step
# for each problem, its id, question(korean, str), answer(english, list of words) with each word's color.
@router.get("/practice/set/", status_code=status.HTTP_200_OK)
async def read_practice_problem(season: int, level: int, step: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    stepinfo_model = await fetch_problem_set(season, level, step, "normal", db)
    get_problem_exception(stepinfo_model)
    init_user_problem(user.get("id"), season, level, step, "normal")
    
    return {'problems': await read_problem_block_colors(stepinfo_model, db)}


# fetch expert problems as season, level, step.
# for each problem, its id, question(korean, str), answer(english, list of words) with each word's color.
@router.get("/expert/set/", status_code=status.HTTP_200_OK)
async def read_expert_problem(season: int, level: int, step: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    stepinfo_model = await fetch_problem_set(season, level, step, "ai", db)
    get_problem_exception(stepinfo_model)
    init_user_problem(user.get("id"), season, level, step, "ai")
    
    return {'problems': await read_problem_block_colors(stepinfo_model, db)}


# return the user's released practice problems level & step as specific season.
@router.get("/practice/info/", status_code=status.HTTP_200_OK)
async def practice_read_level_and_step(season: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    Released_model = await fetch_user_releasedSeason(user, season, db)
    get_season_exception(Released_model)

    levels_info = await get_steps_info(season, "normal", db)
    
    return {'levels': levels_info}


# return the user's released expert problems level & step as specific season, level, and difficulty
@router.get("/expert/info/", status_code=status.HTTP_200_OK)
async def read_level_and_step_expert(season: int, level: int, difficulty: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    Released_model = await fetch_user_releasedSeason(user, season, db)
    get_season_exception(Released_model)

    result = await db.execute(select(Problems)
                              .filter(Problems.type == 'ai', Problems.season == season)
                              .filter(Problems.level == level, Problems.difficulty == difficulty))
    problem_model = result.scalars().all()
    
    if problem_model:
        tail_step = min(problem.step for problem in problem_model)
        head_step = max(problem.step for problem in problem_model)
        steps = list(range(tail_step, head_step + 1))
    else:
        steps = []
    
    return {'steps': steps}


# execute ocr and return a list of recognized words.
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
    result = await asyncio.to_thread(reader.readtext, img_array, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!,?.', rotation_info=[180] ,text_threshold=0.4,low_text=0.3)
    if not result:
        return result
    
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


# check the user's answer
@router.post("/solve_OCR", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, background_tasks: BackgroundTasks,
                             problem_id: int = Form(...),file: UploadFile = File(...)):
    get_user_exception(user)
    word_list = await ocr(file)
    
    stripped_list = []
    for item in word_list:
        if item.strip() != "":
            stripped_list.append(item.strip())
    # Empty List
    if not stripped_list:
        return {"user_input": [], "colors": []}

    user_string = ' '.join(stripped_list)
    # 1. 모든 단어를 한 번에 추출
    all_words = set()
    p_str = user_string
    p_list = parse_sentence(p_str)
    all_words.update(p_list)
    # 2. 한 번의 쿼리로 모든 word와 block 정보 가져오기
    result = await db.execute(
        select(Words, Blocks).join(Blocks, Words.block_id == Blocks.id).filter(Words.words.in_(all_words))
    )
    # 3. 필요한 데이터를 딕셔너리로 매핑
    word_to_color = {word_model.words: block_model.color for word_model, block_model in result.fetchall()}
    # U liked him. 이 인식이 됨 -> 각 단어별로 word 에 포함되어 있는 단어인지 검사. -> word에 단어가 없으면, 그 단어는 p_list 에서 제외.
    popList = []
    for p_word in p_list:
        if p_word in word_to_color:
            pass
        else:
            popList.append(p_word)

    for item in popList:
        p_list.remove(item)
    # 4. 필요한 색상을 가져오기
    p_colors = [word_to_color[word] for word in p_list]

    temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
    problem_model = temp_result.scalars().first()
    if problem_model is None:
        raise http_exception()

    correct_answer = problem_model.englishProblem
    problem_parse = parse_sentence(correct_answer)
    response_parse = parse_sentence(user_string)
    isAnswer, false_location = check_answer(problem_parse[:-1], list(response_parse))
    tempUserProblem = TempUserProblems.get(user.get("id"))
    # 없으면 0으로 초기화하면서 추가
    if not(problem_id in tempUserProblem.problem_incorrect_count):
        tempUserProblem.problem_incorrect_count[problem_id] = 0
    # 백그라운드 실행
    if isAnswer:
        pass
    else:
        background_tasks.add_task(calculate_wrong_info, problem_id, problem_parse, response_parse, tempUserProblem, db)
        tempUserProblem.problem_incorrect_count[problem_id] += 1
        logger = logger_setup.get_logger(user.get("id"))
        logger.info(f"problem={correct_answer},answer={user_string}")

    return {"user_input": p_list, "colors": p_colors}
