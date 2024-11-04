from fastapi import APIRouter, HTTPException
import sys, os
import re
from sqlalchemy import func, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import ProblemSet, AddGroup, GroupStep, LogResponse, TableData
from super.exceptions import *
from starlette import status
from app.src.models import Users, StudyInfo, Problems, correct_problem_table, Groups, Released, WrongType
from app.src.problem.service import get_correct_problem_count, get_incorrect_problem_count
from sqlalchemy.orm import joinedload


def calculate_accuracy_rates(correct_data: TableData, incorrect_data: TableData, released_model):
    normal_corrects, ai_corrects = [0, 0, 0], [0, 0, 0]
    normal_incorrects, ai_incorrects = [0, 0, 0], [0, 0, 0]

    Update_correct_answers(correct_data.table_id, ai_corrects, normal_corrects, correct_data.table_count, released_model, correct_data.problems)
    Update_correct_answers(incorrect_data.table_id, ai_incorrects, normal_incorrects, incorrect_data.table_count, released_model, incorrect_data.problems)

    # Calculate totals
    normal_all = calculate_totals_answer(normal_corrects, normal_incorrects)
    ai_all = calculate_totals_answer(ai_corrects, ai_incorrects)
    # normal_all = [normal_corrects[i] + normal_incorrects[i] for i in range(3)]
    # ai_all = [ai_corrects[i] + ai_incorrects[i] for i in range(3)]

    # Calculate rates
    normal_rate = calculate_answer_rates(normal_corrects, normal_all)
    ai_rate = calculate_answer_rates(ai_corrects, ai_all)
    # normal_rate = [(normal_corrects[i] / float(normal_all[i]) * 100 if normal_all[i] != 0 else 0) for i in range(3)]
    # ai_rate = [(ai_corrects[i] / float(ai_all[i]) * 100 if ai_all[i] != 0 else 0) for i in range(3)]

    return normal_rate, ai_rate

def calculate_totals_answer(correct_answer, incorrect_answer):
    total_answer = [correct_answer[i] + incorrect_answer[i] for i in range(3)]
    return total_answer

def calculate_answer_rates(correct_answer, total_answer):
    answer_rates = [(correct_answer[i] / float(total_answer[i]) * 100 if total_answer[i] != 0 else 0) for i in range(3)]
    return answer_rates

# Update "normal" & "ai" correct answers 
def Update_correct_answers(problem_table_id, ai_corrects ,normal_corrects, answer_count, released_model, Studyinfo):
    # "Studyinfo" includes the number of correct/incorrect answers to problems.
    for problem in Studyinfo:
        if problem.season == released_model.released_season:
            # Classify problems
            count = answer_count[problem_table_id.index(problem.id)]
            if problem.type == "normal":
                normal_corrects[problem.level] += count
            else:
                ai_corrects[problem.level] += count

def calculate_wrongType_percentage(wrongType_model):
    combined_data, total_wrongType, season = calculate_sum_of_wrongType(wrongType_model)

    if total_wrongType != 0:
        # ratio
        for key in combined_data:
            combined_data[key] = f"{combined_data[key] / total_wrongType:.2f}"
    else: # There is nothing wrong
        for key in combined_data:
            combined_data[key] = "0.00"

    combined_data["season"] = season

    return combined_data

def calculate_sum_of_wrongType(wrongType_model):
    combined_data = {
        "wrong_block": 0,
        "wrong_punctuation": 0,
        "wrong_word": 0,
        "wrong_order": 0,
        "wrong_letter": 0
    }

    total_wrongType = 0
    season = None

    for wrongTypes in wrongType_model:
        # Count wrong answer by type.
        combined_data["wrong_block"] += float(wrongTypes.wrong_block)
        combined_data["wrong_punctuation"] += float(wrongTypes.wrong_punctuation)
        combined_data["wrong_word"] += float(wrongTypes.wrong_word)
        combined_data["wrong_order"] += float(wrongTypes.wrong_order)
        combined_data["wrong_letter"] += float(wrongTypes.wrong_letter)

        total_wrongType += (
            float(wrongTypes.wrong_block) +
            float(wrongTypes.wrong_punctuation) +
            float(wrongTypes.wrong_word) +
            float(wrongTypes.wrong_order) +
            float(wrongTypes.wrong_letter)
        )

        # Assume that the wrongType_model is same season.
        if season is None:
            season = wrongTypes.season

    return combined_data, total_wrongType, season


async def find_weakest_type(user_id, db):
    released_model = await fetch_released_user(user_id, db)
    seasons = [item.released_season for item in released_model]

    study_info = await fetch_studyInfo(user_id, db)
    result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season.in_(seasons)))
    wrongType_model = result.scalars().all()
    
    total_wrong_types = calculate_each_type(wrongType_model)
    total_wrong_punctuation, total_wrong_order, total_wrong_letter, total_wrong_block, total_wrong_word = total_wrong_types
    # total_wrong_punctuation = total_wrong_types[0]
    # total_wrong_order = total_wrong_types[1]
    # total_wrong_letter = total_wrong_types[2]
    # total_wrong_block = total_wrong_types[3]
    # total_wrong_word = total_wrong_types[4]
    
    values = {
        'wrong_punctuation': total_wrong_punctuation, 'wrong_order': total_wrong_order, 
        'wrong_letter': total_wrong_letter, 'wrong_block': total_wrong_block, 
        'wrong_word': total_wrong_word
    }

    largest_variable = max(values, key=values.get)
    if (total_wrong_punctuation + total_wrong_order + total_wrong_letter + total_wrong_block + total_wrong_word) == 0:
        return "정보 없음"

    return f"{largest_variable}"

async def find_weak_types_in_season(user_id, season, db):
    # released_model = await fetch_released_user(user_id, db)

    study_info = await fetch_studyInfo(user_id, db)
    result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season == season))
    wrongType_model = result.scalars().all()
    
    total_wrong_types = calculate_each_type(wrongType_model)
    total_wrong_punctuation, total_wrong_order, total_wrong_letter, total_wrong_block, total_wrong_word = total_wrong_types

    values = {
        'wrong_punctuation': total_wrong_punctuation, 'wrong_order': total_wrong_order, 
        'wrong_letter': total_wrong_letter, 'wrong_block': total_wrong_block, 
        'wrong_word': total_wrong_word
    }
    
    return values


def calculate_each_type(wrongType_model):
    total_wrong_types = [0, 0, 0, 0, 0]
    
    for wrongTypes in wrongType_model:
        total_wrong_types[0] += wrongTypes.wrong_punctuation
        total_wrong_types[1] += wrongTypes.wrong_order
        total_wrong_types[2] += wrongTypes.wrong_letter
        total_wrong_types[3] += wrongTypes.wrong_block
        total_wrong_types[4] += wrongTypes.wrong_word

    return total_wrong_types

# Check that the user can access to the group
async def process_user_access(user, user_id, db):
    validate_super_user_role(user)
    await find_student_exception(user_id, db)
    # result = await db.execute(select(Users).filter(Users.id == user_id))
    # user_team_id = result.scalars().first()
    user_team_id = await fetch_user_id(user_id, db)

    std_team_id = user_team_id.team_id
    group_list = await fetch_group_list(user.get("id"), db)
    
    if group_list:
        validate_student_group_access(group_list, std_team_id)
    else: # Parent and Child relationship
        result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
        students = result.scalars().first()
        children = [{"id": students.id, "name": students.name} for students in students.student_teachers]
        isGroup = False
        for u in children:
            if u["id"] == user_id:
                isGroup = True
        if not isGroup:
            raise HTTPException(status_code=403, detail="해당 학생에 접근할 수 없습니다.")


# *No test*
"""
This query returns one document that meets the following conditions:

Document whose userid field matches user_id.
The document where the problem field exists.
One of the most recent documents, sorted in order of the latest.

"""
async def fetch_logs_from_elasticsearch(user_id: int):
    query = {
        "query": {
            "bool": {
                "must": [
                    {"match": {"userid": user_id}}
                ],
                "filter": [
                    {"exists": {"field": "problem"}}
                ]
            }
        },
        "sort": [
            {"@timestamp": {"order": "desc"}}
        ],
        "size": 1
    }

    from app.src.problem.router import es
    return await es.search(index="logstash-logs-*", body=query)

def extract_problem_and_answer_from_message(message: str):
    if not message:
        return
    
    # Use regular expressions to extract 'problem' and 'answer'
    match = re.search(r'problem=(.*?),answer=(.*?)(?: - |\])', message)
    if not match:
        return
    
    problem = match.group(1).strip()
    answer = match.group(2).strip()
    return problem, answer

async def get_latest_log(user_id: int):
    response = await fetch_logs_from_elasticsearch(user_id)

    if response["hits"]["total"]["value"] == 0:
        return  

    # extract the most recent log
    latest_log = response["hits"]["hits"][0]["_source"]
    message = latest_log.get("message")

    problem, answer = extract_problem_and_answer_from_message(message)

    return LogResponse(problem=problem, answer=answer)

# *No test*
