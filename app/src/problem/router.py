import asyncio
import numpy as np
from PIL import Image
import io
from sqlalchemy import collate, func, select, update
from sqlalchemy.orm import joinedload
from fastapi import APIRouter, BackgroundTasks, Request
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import StudyInfo, Problems, Words, Blocks, Released, WrongType
from fastapi import UploadFile, File, Form
from problem.dependencies import user_dependency, db_dependency
from problem.schemas import TempUserProblem, TempUserProblems, SolvedData
from problem.exceptions import *
from problem.service import *
from problem.utils import check_answer, search_log_timestamp
from problem.constants import INDEX, QUERY_MATCH_ALL
from elasticsearch import AsyncElasticsearch
from datetime import datetime, timezone
import logging
from app.src.logging_setup import LoggerSetup

# from app.src.cache import get_word_color

LOGGER = logging.getLogger(__name__)
logger_setup = LoggerSetup()

router = APIRouter(
    prefix="/problem",
    tags=["problem"],
    responses={404: {"description": "Not found"}}
)

es = AsyncElasticsearch(['http://3.34.58.76:9200'])

### CALCULATE TOTAL STUDY TIME

# A function that calculates training time based on user training start and end timestamps.
async def calculate_study_times(user, db):
    studyStart_timestamp, studyEnd_timestamp = await get_study_timestamps(user, es)
    if studyStart_timestamp is None or studyEnd_timestamp is None:
        return

    # Error handling when learning end time is earlier than learning start time
    if studyStart_timestamp < studyEnd_timestamp:
        return

    time_difference = datetime.utcnow().replace(tzinfo=timezone.utc) - studyStart_timestamp
    seconds_difference = time_difference.total_seconds()

    await update_study_time_in_db(user, db, seconds_difference)

# Function to retrieve training start and end timestamps from the log.
async def get_study_timestamps(user, es):
    res = await es.search(index=INDEX, body=QUERY_MATCH_ALL)
    studyStart_timestamp = search_log_timestamp(res, "studyStart", user.get("id"))
    studyEnd_timestamp = search_log_timestamp(res, "studyEnd", user.get("id"))

    if studyEnd_timestamp is None:  # Set default time if there is no StudyEnd
        studyEnd_timestamp = datetime.fromisoformat("2024-01-01T00:00:00.847Z".replace('Z', '+00:00'))

    return studyStart_timestamp, studyEnd_timestamp

# A function that updates the total training time in the user database.
async def update_study_time_in_db(user, db, seconds_difference):
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user.get("id")))
    studyinfo_model = result.scalars().first()
    studyinfo_model.totalStudyTime += int(seconds_difference)

    db.add(studyinfo_model)
    await db.commit()

    return 

### CALCULATE TOTAL STUDY TIME END

@router.post("/study_end", status_code=status.HTTP_200_OK)
async def study_end(mode_str: str, user: user_dependency, db: db_dependency, 
                    background_tasks: BackgroundTasks):
    get_user_exception(user)
    isGroup = 0 # default mode is 'solo'
    if mode_str == 'group':
        isGroup = 1

    # It works even without this logger code. I don't know why. is it a dream?
    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyEnd ---")

    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems))
                              .options(joinedload(StudyInfo.incorrect_problems))
                              .filter(StudyInfo.owner_id == user.get("id")))
    study_info = result.scalars().first()
    if study_info is None: # Not Found
        raise http_exception()
    
    tempUserProblem = TempUserProblems.get(user.get("id")) 

    get_studyStart_exception(tempUserProblem) # Don't start study

    solved_season = tempUserProblem.solved_season
    solved_level = tempUserProblem.solved_level
    solved_step = tempUserProblem.solved_step
    solved_type = tempUserProblem.solved_type
    solvedData = SolvedData(solved_season, solved_type, solved_level, solved_step)

    # Check whether there is a wrong type object of the solved season-level, and create it if it does not exist.
    await add_wrong_type_value(solvedData ,study_info, tempUserProblem, db)

    # Solved all personal study and practice problems, You unlocks next step or level.
    if isGroup == 0 and solved_type == 'normal':
        await problem_unlock(user.get("id"), solvedData, db)

    # Stores the number of incorrect answers depending on whether or not the solved problems have incorrect answers.
    await update_solved_problem_data(study_info, tempUserProblem, isGroup, db)

    TempUserProblems.pop(user.get("id"))

    background_tasks.add_task(calculate_study_times, user, db)

    result = await db.execute(select(Released).filter(Released.owner_id == user.get("id")))
    released_model = result.scalars().all()
    released = []
    for release in released_model:
        released.append({'season':release.released_season, 'level':release.released_level,
                        'step':release.released_step})

    return {'released': released}

# Return incorrect answer note problem information appropriate for season and level.
@router.get("/practice/wrong_note/set/", status_code=status.HTTP_200_OK)
async def read_problem_wrongs(mode_str:str, season:int, level:int,
                            user:user_dependency, db:db_dependency):
    get_user_exception(user)
    isGroup = 0
    if mode_str == 'group':
        isGroup = 1

    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.incorrect_problems))
                               .filter(StudyInfo.owner_id == user.get("id")))
    study_info = result.scalars().first()

    result = await db.execute(select(incorrect_problem_table.c.problem_id).\
                              where(
                                    incorrect_problem_table.c.study_info_id == study_info.id,
                                    incorrect_problem_table.c.isGroup == isGroup,
                                    incorrect_problem_table.c.count > 0
                              ))
    wrong_problems = result.scalars().all()

    # Filter problems corresponding to the season level in incorrect problems.
    filterd_problems = []
    for incorrect_problem in list(study_info.incorrect_problems):
        if incorrect_problem.id in wrong_problems \
        and incorrect_problem.type=='normal' \
        and int(incorrect_problem.season) == season \
        and incorrect_problem.level == level:
            filterd_problems.append(incorrect_problem)

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
        problems.append({'id':item.id, 'englishProblem':item.englishProblem, 
                        'koreaProblem':item.koreaProblem, 'blockColors':colors})
    
    return {"incorrects":problems}


@router.post("/practice/wrong_note/end/", status_code=status.HTTP_200_OK)
async def read_problem_wrongs(mode_str:str, season:int, level:int,
                            user:user_dependency, db:db_dependency):
    get_user_exception(user)
    isGroup = 0
    if mode_str == 'group':
        isGroup = 1
        
    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.incorrect_problems))
                              .filter(StudyInfo.owner_id == user.get("id")))
    study_info = result.scalars().first()

    result = await db.execute(select(incorrect_problem_table.c.problem_id).\
                              where(
                                    incorrect_problem_table.c.study_info_id == study_info.id,
                                    incorrect_problem_table.c.isGroup == isGroup,
                                    incorrect_problem_table.c.count > 0
                              ))
    wrong_problems = result.scalars().all()

    # Subtract wrong answers for that season, level
    for incorrect_problem in list(study_info.incorrect_problems):
        if incorrect_problem.id in wrong_problems \
        and incorrect_problem.type=='normal' \
        and int(incorrect_problem.season) == season \
        and incorrect_problem.level == level:
            study_info.incorrect_problems.remove(incorrect_problem)
            await clear_incorrect_problem_count(study_info.id, incorrect_problem.id, isGroup, db)

    db.add(study_info)
    await db.commit()
    return {"detail":"success"}

@router.get("/practice/set/", status_code=status.HTTP_200_OK)
async def read_practice_problem(season: int, level: int, step: int, 
                            user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    problems_model = await fetch_problem_set(season, level, step, "normal", db)
    get_problem_exception(problems_model)
    init_user_problem(user.get("id"), season, level, step, "normal")

    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyStart ---")
    
    return {'problems': await read_problem_block_colors(problems_model, db)}

@router.get("/expert/set/", status_code=status.HTTP_200_OK)
async def read_expert_problem(season: int, level: int, step: int, 
                            user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    problems_model = await fetch_problem_set(season, level, step, "ai", db)
    get_problem_exception(problems_model)
    init_user_problem(user.get("id"), season, level, step, "ai")

    logger = logger_setup.get_logger(user.get("id"))
    logger.info("--- studyStart ---")
    
    return {'problems': await read_problem_block_colors(problems_model, db)}

# Practice Problem: Returning Level and Step Information
@router.get("/practice/info/", status_code=status.HTTP_200_OK)
async def practice_read_level_and_step(season: int, user: user_dependency, db: db_dependency):
    get_user_exception(user)
    
    Released_model = await fetch_user_releasedSeason(user, season, db)
    get_season_exception(Released_model)

    level_steps_info = await get_level_steps_info(season, "normal", db)
    
    return {'levels': level_steps_info}

# Expert Problem: Returning Level and Step Information
@router.get("/expert/info/", status_code=status.HTTP_200_OK)
async def read_level_and_step_expert(season: int, level: int, difficulty: int,
                                    user: user_dependency, db: db_dependency):
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

# Utils
# This function selects a text block according to direction \
# based on a specific object block (ref_block_idx) in the list called sorted_data \
# and adds the words of the block to the word_list.
def collect_adjacent_blocks(sorted_data, ref_block_idx, word_list, direction='right'):
    if direction == 'right':
        blocks = sorted_data[ref_block_idx+1:]
        append_func = word_list.append
    else:  # direction == 'left'
        blocks = reversed(sorted_data[:ref_block_idx])
        append_func = lambda word: word_list.insert(0, word)

    low_y = sorted_data[ref_block_idx][0][3][1]
    high_y = sorted_data[ref_block_idx][0][0][1]

    for block in blocks:
        if min(low_y, block[0][3][1]) >= max(high_y, block[0][0][1]):
            low_y = block[0][3][1]
            high_y = block[0][0][1]
            append_func(block[1][0])

# PaddlePaddle 2.5.2
async def ocr(file):
    img_binary = await file.read()
    image = await asyncio.to_thread(Image.open, io.BytesIO(img_binary))
    # Reduce image size
    max_dimension = 1000  # 1000 px
    if max(image.size) > max_dimension:
        scale = max_dimension / max(image.size)
        image = image.resize((int(image.width * scale), int(image.height * scale)))

    img_array = np.array(image)
    # Reading images becomes faster by reducing the img_array size.
    from app.src.main import ocr
    result = await asyncio.to_thread(ocr.ocr, img_array, cls=False)
    if not result:
        return result
    result = result[0]
    # print("ocr:result ", result)
    sorted_data = sorted(result, key=lambda item: item[0][0][0])
    max_height = 0
    ref_block_idx = 0

    for block_idx, block in enumerate(sorted_data):
        height = block[0][2][1] - block[0][0][1] # Index Error ? 
        if height > max_height:
            max_height = height
            ref_block_idx = block_idx
    word_list=[sorted_data[ref_block_idx][1][0]]

    # low_y = sorted_data[ref_block_idx][0][3][1]
    # high_y = sorted_data[ref_block_idx][0][0][1]
    
    # Check right
    if(ref_block_idx+1<len(sorted_data)):
        collect_adjacent_blocks(sorted_data, ref_block_idx, word_list, direction='right')

    # Check left
    if(ref_block_idx>0):
        collect_adjacent_blocks(sorted_data, ref_block_idx, word_list, direction='left')

    stripped_word_list=[]
    for word in word_list:
        stripped_word_list.append(word.strip("\" "))

    return stripped_word_list

# Determine whether the answer is correct or not 
@router.post("/solve_OCR", status_code = status.HTTP_200_OK)
async def user_solve_problem(user: user_dependency, db: db_dependency, background_tasks: BackgroundTasks,
                            request: Request, problem_id: int = Form(...),file: UploadFile = File(...)):
    get_user_exception(user)
    user_word_list = await ocr(file)

    all_words = set()
    all_words.update(user_word_list)
    
    word_to_color_cache = request.app.state.word_to_color_cache
    word_to_color = {word: block for word, block in word_to_color_cache.items() if word in all_words}
    # word_to_color = get_word_color(word)

    # ex) 'You liked him' is recognized 
    # -> Check whether each word is included in the DB-word. 
    # -> If there is no word in DB-word, the word is excluded from p_list.
    popList = []
    for p_word in user_word_list:
        if p_word in word_to_color:
            pass
        else:
            popList.append(p_word)

    for item in popList:
        user_word_list.remove(item)
    # Get the colors you need
    p_colors = [word_to_color[word] for word in user_word_list]

    # To determine whether the picture is the correct answer or not, 
    # it brings up the problem model.
    temp_result = await db.execute(select(Problems).filter(Problems.id == problem_id))
    problem_model = temp_result.scalars().first()
    if problem_model is None:
        raise http_exception()

    correct_answer = problem_model.englishProblem
    answer_word_list = parse_sentence(correct_answer)
    user_string = ' '.join(user_word_list)

    isAnswer = check_answer(answer_word_list, user_word_list)

    tempUserProblem = TempUserProblems.get(user.get("id"))
    # init
    if not(problem_id in tempUserProblem.problem_incorrect_count):
        tempUserProblem.problem_incorrect_count[problem_id] = 0

    if isAnswer:
        pass
    else:
        # background execution : 
        # Check the wrong part of the submitted picture in the background, 
        # and increase the wrong part.
        background_tasks.add_task(calculate_wrong_info, problem_id, answer_word_list, user_word_list, tempUserProblem, db)
        tempUserProblem.problem_incorrect_count[problem_id] += 1
        # report log
        logger = logger_setup.get_logger(user.get("id"))
        logger.info(f"problem={correct_answer},answer={user_string}")

    return {"user_input": user_word_list, "colors": p_colors}


