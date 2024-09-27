import sys, os
from sqlalchemy.dialects.mysql import insert
from sqlalchemy import select, update
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems, correct_problem_table, incorrect_problem_table, Words, WrongType, Blocks, Released
from problem.schemas import Problem, TempUserProblem
from problem.dependencies import db_dependency
from problem.utils import *

# async def create_Types_in_db(id, db: db_dependency, tempUserProblem: TempUserProblem) -> Types:
#     print(type(tempUserProblem.totalFullStop))
#     new_Types = Types(
#         punctuation=tempUserProblem.totalFullStop,
#         letter=tempUserProblem.totalTextType,
#         block=tempUserProblem.totalIncorrectCompose,
#         word=tempUserProblem.totalIncorrectWords,
#         order=tempUserProblem.totalIncorrectOrder,
#         owner_id = id
#     )
#     db.add(new_Types)
#     await db.commit()
#     await db.refresh(new_Types)
#     return 

# async def update_Types_in_db(model, db: db_dependency, tempUserProblem: TempUserProblem) -> Types:

#     model.punctuation=tempUserProblem.totalFullStop
#     model.letter=tempUserProblem.totalTextType
#     model.block=tempUserProblem.totalIncorrectCompose
#     model.word=tempUserProblem.totalIncorrectWords
#     model.order=tempUserProblem.totalIncorrectOrder

#     db.add(model)
#     await db.commit()
#     await db.refresh(model)
#     return 


async def create_problem_in_db(db: db_dependency, problem: Problem) -> Problems:
    new_problem = Problems(
        season = problem.season,
        level = problem.level,
        step = problem.step,
        koreaProblem = problem.koreaProblem,
        englishProblem = problem.englishProblem,
        img_path = problem.img_path
    )
    db.add(new_problem)
    await db.commit()
    await db.refresh(new_problem)
    return new_problem

async def get_problem_info(db):
    result = await db.execute(select(Problems))
    problem_list = result.scalars().all()
    return problem_list

async def create_wrong_type(season:int, level:int, studyinfo_id:int, db):
    wrongType = WrongType(
        info_id = studyinfo_id,
        season = season,
        level = level
    )
    db.add(wrongType)
    await db.commit()

async def increment_correct_problem_count(study_info_id: int, problem_id: int, p_count: int, isGroup:int, db: db_dependency):
    # 업데이트 문 생성
    stmt = update(correct_problem_table).\
        where(
            correct_problem_table.c.study_info_id == study_info_id,
            correct_problem_table.c.problem_id == problem_id,
            correct_problem_table.c.isGroup == isGroup
        ).\
        values(count=correct_problem_table.c.count + p_count)

    # 업데이트 문 실행
    await db.execute(stmt)
    await db.commit()

async def increment_incorrect_problem_count(study_info_id: int, problem_id: int, p_count: int, isGroup:int, db: db_dependency):
    # 업데이트 문 생성
    stmt = update(incorrect_problem_table).\
        where(
            incorrect_problem_table.c.study_info_id == study_info_id,
            incorrect_problem_table.c.problem_id == problem_id,
            incorrect_problem_table.c.isGroup == isGroup
        ).\
        values(count=incorrect_problem_table.c.count + p_count)

    # 업데이트 문 실행
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


# check if the response is correct and mark why it is wrong.
# wrong types are 5 categories: 
# 1. Is it case-sensitive?
# 2. Are the punctuations right?
# 3. Are the blocks right?
# 4. Are the words right?
# 5. Are the words in correct order?
async def calculate_wrongs(problem_parse:list, response_parse:list, db=db_dependency):
    problem = combine_sentence(problem_parse)

    # initate wrong types
    letter_wrong = 0
    punc_wrong = 0
    block_wrong = 0
    word_wrong = 0
    order_wrong = 0

    # 0. response의 단어들이 블록에 있는 단어인지 검사
    popList = []
    for item in response_parse:
        result = await db.execute(select(Words).filter(Words.words == item))
        word_model = result.scalars().first()

        if word_model is None:
            popList.append(item)
        
    for item in popList:
        response_parse.remove(item)
        
    if not response_parse:
        return 0,0,0,0,0
    response = combine_sentence(response_parse)
    
    # response_v1: 대소문자 filter 거친 문장 --> 대소문자 맞는 걸로 바뀜
    # response_v2: 구두점 filter 거친 문장   --> 구두점 사라짐
    # response_v3: 블록 filter 거친 문장     --> 틀린 블록은 삭제됨

    # 1. 대소문자 판단
    letter_wrong, response_v1 = lettercase_filter(problem, response)

    # 2. 구두점 판단
    punc_wrong, problem_v2, response_v2 = punctuation_filter(problem, response_v1)

    # 3. 블록이 맞는지
    response_v2_split = response_v2.split(' ')
    problem_v2_split = problem_v2.split(' ')
    r_len_v2 = len(response_v2_split)
    p_len_v2 = len(problem_v2_split)

    # problem 블록 id 리스트
    problem_block = []
    for item in problem_v2_split:
        result = await db.execute(select(Words).filter(Words.words == item))
        word_model = result.scalars().first()
        problem_block.append(word_model.block_id)

    # response 블록 id 리스트
    response_block = []
    for item in response_v2_split:
        result = await db.execute(select(Words).filter(Words.words == item))
        word_model = result.scalars().first()
        response_block.append(word_model.block_id)

    # add if the length of problem and response is different
    block_wrong += max(r_len_v2 - p_len_v2, p_len_v2-r_len_v2)
    response_v3_split = response_v2_split.copy()

    # check if each block is 'in' the problem(correct answer), regardless of the order.
    for i in range(r_len_v2):
        id = response_block[i]
        if id in problem_block:
            problem_block.remove(id)
        else:
            block_wrong += 1
            response_v3_split.remove(response_v2_split[i])

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
    # return {"problem_v1":problem, "response_v1":response_v1, "problem_v2":problem_v2, "r_v2":response_v2, "r_v3":response_v3_split, "letter":letter_wrong, "punc":punc_wrong, "block":block_wrong, "word":word_wrong, "order":order_wrong}


async def read_problem_block_colors(stepinfo_model,db):
    problem = []
    # 1. 모든 단어를 한 번에 추출
    all_words = set()
    for p in stepinfo_model:
        p_str = p.englishProblem
        p_list = parse_sentence(p_str)
        all_words.update(p_list)

    # 2. 한 번의 쿼리로 모든 word와 block 정보 가져오기
    result = await db.execute(
        select(Words, Blocks).join(Blocks, Words.block_id == Blocks.id).filter(Words.words.in_(all_words))
    )

    # 3. 필요한 데이터를 딕셔너리로 매핑
    word_to_color = {word_model.words: block_model.color for word_model, block_model in result.fetchall()}

    # 4. 필요한 색상을 가져오기
    for p in stepinfo_model:
        p_str = p.englishProblem
        p_list = parse_sentence(p_str)
        p_list.pop(-1)
        p_colors = [word_to_color[word] for word in p_list]
        problem.append({'id': p.id, 'question': p.koreaProblem, 'answer': p_list, 'blockColors':p_colors})
        # problem.append({'id': p.id, 'englishProblem': p.englishProblem, 'koreaProblem': p.koreaProblem, 'blockColors':p_colors})
    return problem

async def clear_incorrect_problem_count(study_info_id: int, problem_id: int, isGroup:int, db: db_dependency):
    # 업데이트 문 생성
    stmt = update(incorrect_problem_table).\
        where(
            incorrect_problem_table.c.study_info_id == study_info_id,
            incorrect_problem_table.c.problem_id == problem_id,
            incorrect_problem_table.c.isGroup == isGroup
        ).\
        values(count=0)

    # 업데이트 문 실행
    await db.execute(stmt)
    await db.commit()


# 공통 로직: 문제 집합을 가져오는 함수 service. 
async def fetch_problem_set(season: int, level: int, step: int, problem_type: str, db: db_dependency):
    result = await db.execute(select(Problems)
                              .filter(Problems.level == level, Problems.season == season)
                              .filter(Problems.step == step, Problems.type == problem_type))
    stepinfo_model = result.scalars().all()
    
    return stepinfo_model

# 공통 로직: 문제 레벨과 스텝 정보 가져오는 함수 . service
async def get_steps_info(season: int, problem_type: str, db: db_dependency):
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

# Helper function to fetch user data . service.
async def fetch_user_releasedSeason(user, season, db):
    result = await db.execute(select(Released)
                              .filter(Released.owner_id == user.get("id"))
                              .filter(Released.released_season == season))
    return result.scalars().first()