import sys, os
from sqlalchemy.dialects.mysql import insert
from sqlalchemy import select, update
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems, correct_problem_table, incorrect_problem_table, Words, WrongType, Blocks, Released
from problem.schemas import Problem, TempUserProblem, SolvedData
from problem.dependencies import db_dependency
from problem.utils import *
from problem.constants import MAX_LEVEL

### PROBLEM COUNT 

async def increment_correct_problem_count(study_info_id: int, problem_id: int, p_count: int, isGroup:int, db: db_dependency):
    stmt = update(correct_problem_table).\
        where(
            correct_problem_table.c.study_info_id == study_info_id,
            correct_problem_table.c.problem_id == problem_id,
            correct_problem_table.c.isGroup == isGroup
        ).\
        values(count=correct_problem_table.c.count + p_count)

    await db.execute(stmt)
    await db.commit()

async def increment_incorrect_problem_count(study_info_id: int, problem_id: int, p_count: int, isGroup:int, db: db_dependency):
    stmt = update(incorrect_problem_table).\
        where(
            incorrect_problem_table.c.study_info_id == study_info_id,
            incorrect_problem_table.c.problem_id == problem_id,
            incorrect_problem_table.c.isGroup == isGroup
        ).\
        values(count=incorrect_problem_table.c.count + p_count)

    await db.execute(stmt)
    await db.commit()

async def get_correct_problem_count(study_info_id: int, problem_id: int, db):
    query = select(correct_problem_table.c.count).where(
        correct_problem_table.c.study_info_id == study_info_id,
        correct_problem_table.c.problem_id == problem_id
    )
    result = await db.execute(query)
    count = result.scalar()
    return count

async def get_incorrect_problem_count(study_info_id: int, problem_id: int, db):
    query = select(incorrect_problem_table.c.count).where(
        incorrect_problem_table.c.study_info_id == study_info_id,
        incorrect_problem_table.c.problem_id == problem_id
    )
    result = await db.execute(query)
    count = result.scalar()
    return count

async def clear_incorrect_problem_count(study_info_id: int, problem_id: int, isGroup:int, db: db_dependency):
    stmt = update(incorrect_problem_table).\
        where(
            incorrect_problem_table.c.study_info_id == study_info_id,
            incorrect_problem_table.c.problem_id == problem_id,
            incorrect_problem_table.c.isGroup == isGroup
        ).\
        values(count=0)

    await db.execute(stmt)
    await db.commit()


async def update_solved_problem_data(study_info, tempUserProblem, isGroup, db):
    solved_problem_ids = list(tempUserProblem.problem_incorrect_count.keys())

    result = await db.execute(select(Problems).filter(Problems.id.in_(solved_problem_ids)))
    solved_problems = result.scalars().all()

    for i in range(len(solved_problem_ids)):
        # If all steps have been completed, every problem has been solved at least once.
        # If it doesn't already exist in correct_problems, it must be added.
        if solved_problems[i] not in study_info.correct_problems:
            study_info.correct_problems.append(solved_problems[i])

        # "problem_incorrect_count != 0" means "The problem has been answered incorrectly before" 
        # So, It should be added to incorrect_problems as well.
        if tempUserProblem.problem_incorrect_count[solved_problem_ids[i]] != 0:            
            if solved_problems[i] not in study_info.incorrect_problems:
                study_info.incorrect_problems.append(solved_problems[i])

    for problem_id, incorrect_count in tempUserProblem.problem_incorrect_count.items():
        await increment_correct_problem_count(study_info.id, problem_id, 1, isGroup, db)
        if incorrect_count != 0:
            await increment_incorrect_problem_count(study_info.id, problem_id, incorrect_count, isGroup, db)

    db.add(study_info)
    await db.commit()


### WRONG

async def create_wrong_type(season:int, level:int, studyinfo_id:int, db):
    wrongType = WrongType(
        info_id = studyinfo_id,
        season = season,
        level = level
    )
    db.add(wrongType)
    await db.commit()

async def calculate_wrongs(problem_parse:list, response_parse:list, db=db_dependency):
    
    response = combine_sentence(response_parse)
    problem = combine_sentence(problem_parse)
    # v1: 대소문자 filter 거친 문장 --> 대소문자 맞는 걸로 바뀜
    # v2: 구두점 filter 거친 문장   --> 구두점 사라짐
    # v3: 블록 filter 거친 문장     --> 틀린 블록은 삭제됨

    # 1. 대소문자 판단
    letter_wrong, response_v1 = lettercase_filter(problem, response)

    # 2. 구두점 판단
    punc_wrong, problem_v2, response_v2 = punctuation_filter(problem, response_v1)

    # 3. 블록이 맞는지
    block_wrong = 0
    response_v2_split = response_v2.split(' ')
    problem_v2_split = problem_v2.split(' ')
    r_len_v2 = len(response_v2_split)
    p_len_v2 = len(problem_v2_split)


    all_words = set()
    all_words.update(response_v2_split)
    all_words.update(problem_v2_split)

    result = await db.execute(select(Words).filter(Words.words.in_(all_words)))
    word_models = result.scalars().all()

    word_to_block_id = {word.words: word.block_id for word in word_models}

    # problem 블록 id 리스트
    problem_block = [word_to_block_id.get(item) for item in problem_v2_split]
    # response 블록 id 리스트
    response_block = [word_to_block_id.get(item) for item in response_v2_split]

    block_wrong += max(r_len_v2 - p_len_v2, p_len_v2-r_len_v2)
    response_v3_split = response_v2_split.copy()

    for i in range(r_len_v2):
        id = response_block[i]
        if id in problem_block:
            problem_block.remove(id)
        else:
            block_wrong += 1
            response_v3_split.remove(response_v2_split[i])

    word_wrong = 0
    order_wrong = 0
    # 4. 블록이 맞은 것 중, 단어가 틀렸는지 and 순서가 틀렸는지
    for item in response_v3_split:
        if item in problem_v2_split:
            if response_v3_split.index(item) != problem_v2_split.index(item):
                order_wrong += 1
        else:
            word_wrong += 1  

    return letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong


async def calculate_wrong_info(problem_id, problem_parse:list, response_parse:list, tempUserProblem, db=db_dependency):
    letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong = await calculate_wrongs(problem_parse, response_parse, db)
    
    tempUserProblem.totalIncorrectLetter += letter_wrong 
    tempUserProblem.totalIncorrectPunc += punc_wrong
    tempUserProblem.totalIncorrectBlock += block_wrong
    tempUserProblem.totalIncorrectWords += word_wrong
    tempUserProblem.totalIncorrectOrder += order_wrong

    return

async def add_wrong_type_value(solvedData: SolvedData, study_info, tempUserProblem, db):
    result = await db.execute(select(WrongType)
                              .filter(WrongType.info_id == study_info.id, 
                                    WrongType.season == solvedData.season, 
                                    WrongType.level == solvedData.level))
    wrong_type = result.scalars().first()

    if wrong_type is None:
        await create_wrong_type(solvedData.season, solvedData.level, study_info.id, db)
        result = await db.execute(select(WrongType)
                                  .filter(WrongType.info_id == study_info.id, 
                                        WrongType.season == solvedData.season, 
                                        WrongType.level == solvedData.level))
        wrong_type = result.scalars().first()

    # Update wrong type
    wrong_type.wrong_letter += tempUserProblem.totalIncorrectLetter
    wrong_type.wrong_punctuation += tempUserProblem.totalIncorrectPunc
    wrong_type.wrong_block += tempUserProblem.totalIncorrectBlock
    wrong_type.wrong_order += tempUserProblem.totalIncorrectOrder
    wrong_type.wrong_word += tempUserProblem.totalIncorrectWords
    db.add(wrong_type)


### FETCH

async def fetch_problem_set(season: int, level: int, step: int, problem_type: str, db: db_dependency):
    result = await db.execute(select(Problems)
                              .filter(Problems.level == level, Problems.season == season)
                              .filter(Problems.step == step, Problems.type == problem_type))
    stepinfo_model = result.scalars().all()
    
    return stepinfo_model

async def fetch_user_releasedSeason(user, season, db):
    result = await db.execute(select(Released)
                              .filter(Released.owner_id == user.get("id"))
                              .filter(Released.released_season == season))
    return result.scalars().first()

async def get_level_steps_info(season: int, problem_type: str, db: db_dependency):
    result = await db.execute(select(Problems)
                              .filter(Problems.type == problem_type, Problems.season == season))
    problem_model = result.scalars().all()
    
    problems_by_level = {}
    for problem in problem_model:
        if problem.level not in problems_by_level:
            problems_by_level[problem.level] = set()
        problems_by_level[problem.level].add(problem.step)

    levels_info = [{'level_name': level, 'steps': list(steps)} for level, steps in problems_by_level.items()]
    return levels_info

### RELEASED

async def problem_unlock(user_id, solvedData: SolvedData, db):
    result = await db.execute(select(Released).filter(Released.owner_id == user_id))
    released_model = result.scalars().first()
    result = await db.execute(select(Problems.step)
                              .filter(Problems.season == solvedData.season, 
                                      Problems.type== solvedData.type, 
                                      Problems.level == solvedData.level))
    all_steps = result.scalars().all()
    if not all_steps: # Invaild Access (Out of Bound)
        return
    
    max_step = max(all_steps)
    # Problem Unlock Process
    if released_model.released_level == solvedData.level and released_model.released_step == solvedData.step:
        if max_step == solvedData.step:
            if solvedData.level < MAX_LEVEL:
                released_model.released_level += 1
                released_model.released_step = 0
        else:
            released_model.released_step += 1
        db.add(released_model)

### BLCOK COLORS

async def read_problem_block_colors(stepinfo_model,db):
    problem = []
    # 1. Extract all words at once
    all_words = set()
    for p in stepinfo_model:
        p_str = p.englishProblem
        p_list = parse_sentence(p_str)
        all_words.update(p_list)

    # 2. Get all word and block information with 1 query
    result = await db.execute(
        select(Words, Blocks).join(Blocks, Words.block_id == Blocks.id).filter(Words.words.in_(all_words))
    )

    # 3. Mapping the required data into a dictionary
    word_to_color = {word_model.words: block_model.color for word_model, block_model in result.fetchall()}

    # 4. Get the colors you need
    for p in stepinfo_model:
        p_str = p.englishProblem
        p_list = parse_sentence(p_str)
        p_list.pop(-1)
        p_colors = [word_to_color[word] for word in p_list]
        problem.append({'id': p.id, 'question': p.koreaProblem, 'answer': p_list, 'blockColors':p_colors})
        
    return problem

# Not used ?
# async def get_problem_info(db):
#     result = await db.execute(select(Problems))
#     problem_list = result.scalars().all()
#     return problem_list

# async def create_problem_in_db(db: db_dependency, problem: Problem) -> Problems:
#     new_problem = Problems(
#         season = problem.season,
#         level = problem.level,
#         step = problem.step,
#         koreaProblem = problem.koreaProblem,
#         englishProblem = problem.englishProblem,
#         img_path = problem.img_path
#     )
#     db.add(new_problem)
#     await db.commit()
#     await db.refresh(new_problem)
#     return new_problem
