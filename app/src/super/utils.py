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

# AFTER
def calculate_accuracy_rates(correct_data: TableData, incorrect_data: TableData, released_model):
    normal_corrects, ai_corrects = [0, 0, 0], [0, 0, 0]
    normal_incorrects, ai_incorrects = [0, 0, 0], [0, 0, 0]

    calculate_correct_answers(correct_data.table_id, ai_corrects, normal_corrects, correct_data.table_count, released_model, correct_data.problems)
    calculate_correct_answers(incorrect_data.table_id, ai_incorrects, normal_incorrects, incorrect_data.table_count, released_model, incorrect_data.problems)

    # Calculate totals
    normal_all = [normal_corrects[i] + normal_incorrects[i] for i in range(3)]
    ai_all = [ai_corrects[i] + ai_incorrects[i] for i in range(3)]

    # Calculate rates
    normal_rate = [(normal_corrects[i] / float(normal_all[i]) * 100 if normal_all[i] != 0 else 0) for i in range(3)]
    ai_rate = [(ai_corrects[i] / float(ai_all[i]) * 100 if ai_all[i] != 0 else 0) for i in range(3)]

    return normal_rate, ai_rate

# Calculate "normal" & "ai" correct answers 
def calculate_correct_answers(problem_table_id, ai_corrects ,normal_corrects, answer_count, released_model, Studyinfo):
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
    divided_data_list = []

    for wrongTypes in wrongType_model:
        total_wrongType = (
            wrongTypes.wrong_punctuation
            + wrongTypes.wrong_order
            + wrongTypes.wrong_letter
            + wrongTypes.wrong_block
            + wrongTypes.wrong_word
        )
        
        # Sort wrongTypes in descending order
        wrong_data = {k: v for k, v in vars(wrongTypes).items() if k.startswith("wrong")}
        sorted_wrong_data = dict(sorted(wrong_data.items(), key=lambda item: item[1], reverse=True)) 
                    # dict(sorted(wrong_data.items(), key=lambda item: item[1], reverse=True)[:3])

        if total_wrongType != 0:
            divided_data = {k: f"{v / total_wrongType:.2f}" for k, v in sorted_wrong_data.items()}
        else:
            divided_data = {k: f"{0:.2f}" for k, v in sorted_wrong_data.items()}

        # Add season, level info.
        divided_data["season"] = wrongTypes.season
        divided_data["level"] = wrongTypes.level
        divided_data_list.append(divided_data)

    return divided_data_list

async def find_weakest_type(user_id, db):
    released_model = await fetch_released_user(user_id, db)
    seasons = [item.released_season for item in released_model]

    study_info = await fetch_studyInfo(user_id, db)
    result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season.in_(seasons)))
    wrongType_model = result.scalars().all()
    
    total_wrong_punctuation, total_wrong_order, total_wrong_letter, total_wrong_block, total_wrong_word = 0, 0, 0, 0, 0

    for wrongTypes in wrongType_model:
        # 총 wrong 타입 합계 계산
        total_wrong_punctuation += wrongTypes.wrong_punctuation
        total_wrong_order += wrongTypes.wrong_order
        total_wrong_letter += wrongTypes.wrong_letter
        total_wrong_block += wrongTypes.wrong_block
        total_wrong_word += wrongTypes.wrong_word
    
    values = {
        'wrong_punctuation': total_wrong_punctuation, 'wrong_order': total_wrong_order, 
        'wrong_letter': total_wrong_letter, 'wrong_block': total_wrong_block, 
        'wrong_word': total_wrong_word
    }

    largest_variable = max(values, key=values.get)
    if (total_wrong_punctuation + total_wrong_order + total_wrong_letter + total_wrong_block + total_wrong_word) == 0:
        return "정보 없음"

    return f"{largest_variable}"


async def process_user_access(user, user_id, db):
    validate_super_user_role(user)
    await find_student_exception(user_id, db)
    result = await db.execute(select(Users).filter(Users.id == user_id))
    user_team_id = result.scalars().first()

    std_team_id = user_team_id.team_id
    group_list = await fetch_group_list(user.get("id"), db)
    
    if group_list:
        validate_student_group_access(group_list, std_team_id)
    else:
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

    # Elasticsearch에서 비동기 쿼리 실행
    from app.src.problem.router import es
    return await es.search(index="logstash-logs-*", body=query)

def extract_problem_and_answer_from_message(message: str):
    if not message:
        return
        # raise HTTPException(status_code=404, detail="Message field not found in the log")
    
    # 정규 표현식을 사용하여 problem과 answer 추출
    match = re.search(r'problem=(.*?),answer=(.*?)(?: - |\])', message)
    if not match:
        return
        # raise HTTPException(status_code=404, detail="Problem and answer fields not found in the message")

    problem = match.group(1).strip()
    answer = match.group(2).strip()
    return problem, answer

async def get_latest_log(user_id: int):
    response = await fetch_logs_from_elasticsearch(user_id)

    if response["hits"]["total"]["value"] == 0:
        raise HTTPException(status_code=404, detail="Log not found")

    # 가장 최근의 로그 추출
    latest_log = response["hits"]["hits"][0]["_source"]
    
    # message 필드를 파싱하여 problem과 answer 추출
    message = latest_log.get("message")
    problem, answer = extract_problem_and_answer_from_message(message)

    return LogResponse(problem=problem, answer=answer)
# *No test*

# BEFORE
# async def get_latest_log(user_id: int):
#     query = {
#         "query": {
#             "bool": {
#                 "must": [
#                     {"match": {"userid": user_id}}
#                 ],
#                 "filter": [
#                     {"exists": {"field": "problem"}}
#                 ]
#             }
#         },
#         "sort": [
#             {"@timestamp": {"order": "desc"}}
#         ],
#         "size": 1
#     }
    
#     # Elasticsearch에서 비동기 쿼리 실행
#     from app.src.problem.router import es
#     response = await es.search(index="logstash-logs-*", body=query)
    
#     if response["hits"]["total"]["value"] == 0:
#         return
#         # raise HTTPException(status_code=404, detail="Log not found")
    
#     # 가장 최근의 로그 추출
#     latest_log = response["hits"]["hits"][0]["_source"]
    
#     # message 필드를 파싱하여 problem과 answer 추출
#     message = latest_log.get("message")
#     if not message:
#         return
#         # raise HTTPException(status_code=404, detail="Message field not found in the log")
    
#     # 정규 표현식을 사용하여 problem과 answer 추출
#     match = re.search(r'problem=(.*?),answer=(.*?)(?: - |\])', message)
#     if not match:
#         return
#         # raise HTTPException(status_code=404, detail="Problem and answer fields not found in the message")
    
#     problem = match.group(1).strip()
#     answer = match.group(2).strip()
    
#     return LogResponse(problem=problem, answer=answer)



# no use
# async def user_step_problem_count(user_id, season, level, attribute_name, db):
#     students = await fetch_user_id_all(user_id, db)

#     # return students # 특정 학생의 모든 정보
#     studyinfo = []
#     for s in students:
#         study_info = await fetch_problem_count(s.id, db)
#         studyinfo.append(study_info) # 맞은+틀린 문제들 저장. 

#     # if study_info is None:
#     #     raise http_exception()
    
#     result = []
#     # return studyinfo # 특정 학생의 학습 정보
#     for item in studyinfo:
#         # correct_problem_ids = [{"id": problem.id} for problem in item.correct_problems if problem.type == step]
#         correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name) if problem.season == season and problem.level == level]
#         result_item = {
#             "id": item.id,
#             attribute_name: correct_problem_ids
#         }
#         result.append(result_item)

#     # return result # 학습정보 id -> 맞은 문제 id .json
#     count = 0
#     for item in result:
#         if item[attribute_name]:
#             for p in item[attribute_name]:
#                 if attribute_name == "correct_problems":
#                     count += await get_correct_problem_count(item["id"], p["id"], db)
#                 else:
#                     count += await get_incorrect_problem_count(item["id"], p["id"], db)
    
#     # db.add(study_info)
#     # await db.commit()

#     return count # 문제개수의 누적합 

# no use
# async def user_worst_problem(user_id, attribute_name, db):

#     students = await fetch_user_id_all(user_id, db)

#     # return students # 특정 학생 개인의 정보
#     studyinfo = []
#     for s in students:
#         study_info = await fetch_problem_count(s.id, db)
#         studyinfo.append(study_info) # 맞은+틀린 문제들 저장. 

#     # if study_info is None:
#     #     raise http_exception()


#     result = []
#     # return studyinfo # 특정 학생 개인의 학습 정보
#     for item in studyinfo:
#         # correct_problem_ids = [{"id": problem.id} for problem in item.correct_problems if problem.type == step]
#         correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name)]
#         result_item = {
#             "id": item.id,
#             attribute_name: correct_problem_ids
#         }
#         result.append(result_item)

#     # return result # 학습정보 id -> 맞은 문제 id .json
#     countProblem = []
#     for item in result:
#         if item[attribute_name]:
#             for p in item[attribute_name]:
#                 count = await get_correct_problem_count(item["id"], p["id"], db)
#                 countProblem.append({'problem_id': p["id"], f"{attribute_name}"+'_count': count})
    
#     # return countProblem # 맞은 문제별 카운트 
#     max_correct_count = 0
#     for problem in countProblem:
#         correct_count = problem.get('correct_problems_count', 0)
#         if correct_count > max_correct_count:
#             max_correct_count = correct_count
#             max_problem_id = problem["problem_id"]
            
#     if max_correct_count == 0:
#         return get_studyInfo_exception(0, 0)
#     # return max_problem_id # 가장 횟수가 많은 문제 아이디

#     result3 = await db.execute(select(Problems).filter(Problems.id == max_problem_id))
#     highProblem = result3.scalars().first()

#     return {'level': highProblem.level, 'step': highProblem.step, 'id(temp)': highProblem.id} # 정보. 다만 번호는 어떻게 구현할지..


# no use
# async def group_step_problem_count(group_id, season, level, attribute_name, db):

#     groups = await fetch_groups(group_id, db)
    
#     students = []
#     for g in groups:
#         students = await fetch_user_teamId(g.id, db)

#     studyinfo = []
#     for s in students:
#         study_info = await fetch_problem_count(s.id, db)
#         studyinfo.append(study_info) # 맞은+틀린 문제들만 저장. 

#     # if study_info is None:
#     #     raise http_exception()
    
#     result = []
#     for item in studyinfo:
#         correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name) if problem.season == season and problem.level == level]
#         result_item = {
#             "id": item.id,
#             attribute_name: correct_problem_ids
#         }
#         result.append(result_item)

#     # return result # 학습정보 id -> 맞은 문제 id .json
#     count = 0
#     for item in result:
#         if item[attribute_name]:
#             for p in item[attribute_name]:
#                 if attribute_name == "correct_problems":
#                     count += await get_correct_problem_count(item["id"], p["id"], db)
#                 else:
#                     count += await get_incorrect_problem_count(item["id"], p["id"], db)

#     return count


# no use
# async def group_avg_time(group_id, db):

#     groups = await fetch_groups(group_id, db)
#     # return groups # 그룹 정보
#     students = []
#     for g in groups:
#         students = await fetch_user_teamId(g.id, db)

#     # return students # 그룹에 속한 모든 학생 정보
#     group_total_time = 0
#     cnt = 0
#     for s in students:
#         study_info = await fetch_studyInfo(s.id, db)
#         group_total_time += study_info.totalStudyTime
#         cnt += 1
#         # studyinfo.append(study_info) 
    
#     group_count_exception(cnt)
#     return {"group_avg_time(minutes)": group_total_time // cnt }

# no use
# async def group_student_problem(group_id, step, level, db):

#     count_problem = await fetch_problems(level, step, db)
#     if count_problem == 0:
#         return {'detail' : '입력한 레벨, 스텝에 해당하는 문제가 없습니다.'}

#     groups = await fetch_groups(group_id, db)
#     students = []
#     for g in groups:
#         students = await fetch_user_teamId(g.id, db)

#     studyinfo = []
#     for s in students:
#         study_info = await fetch_user_correct_problems(s.id, db)
#         studyinfo.append(study_info) # 맞은 문제들만 저장. 

#     # if study_info is None:
#     #     raise http_exception()

#     # 데이터를 순회하며 필터링된 correct_problems의 개수를 셈
#     resultm = count_filtered_problems(studyinfo, level, step)

#     pass_step_students = 0
#     total_students = 0
#     # 데이터를 순회하며 cnt가 count_problem인 항목을 카운트
#     for item in resultm:
#         total_students += 1
#         if item["cnt"] == count_problem:
#             pass_step_students += 1

#     return {"pass_step_students": pass_step_students, "total_students": total_students}

# no use
# async def group_student_progress(group_id, step, level, db):

#     count_problem = await fetch_problems(level, step, db)
#     if count_problem == 0:
#         return 0

#     groups = await fetch_groups(group_id, db)

#     students = []
#     for g in groups:
#         students = await fetch_user_teamId(g.id, db)

#     studyinfo = []
#     for s in students:
#         study_info = await fetch_user_correct_problems(s.id, db)
#         studyinfo.append(study_info) # 맞은 문제들만 저장. 

#     resultm = count_filtered_problems(studyinfo, level, step)

#     # cnt가 2인 항목의 개수를 세기 위한 변수
#     pass_step_students = 0
#     total_students = 0
#     # 데이터를 순회하며 cnt가 2인 항목을 카운트
#     for item in resultm:
#         total_students += 1
#         if item["cnt"] == count_problem:
#             pass_step_students += 1

#     # 결과 출력
#     if total_students != 0:
#         return pass_step_students / total_students 
#     else:
#         return 0

# no use
# def filter_problems_by_level_and_step(problems, level, step):
#     return [problem for problem in problems if problem.level == level and problem.step == step]

# no use
# def count_filtered_problems(study_info, level, step):
#     result = []
    
#     for entry in study_info:
#         filtered_problems = filter_problems_by_level_and_step(entry.correct_problems, level, step)
#         result.append({"id": entry.id, "cnt": len(filtered_problems)})
    
#     return result

# no use
# async def group_avg_student_problem(group_id, step, level, db):

#     count = await fetch_problems(level, step, db)

#     # return count # 해당 스텝의 문제 개수를 가져옴.

#     groups = await fetch_groups(group_id, db)
#     # return groups # 그룹 정보
#     students = []
#     for g in groups:
#         students = await fetch_user_teamId(g.id, db)

#     # return students # 그룹에 속한 모든 학생 정보
#     studyinfo = []
#     for s in students:
#         study_info = await fetch_user_correct_problems(s.id, db)
#         studyinfo.append(study_info) # 맞은 문제들만 저장. 

#     # if study_info is None:
#     #     raise http_exception()
#     # return studyinfo # 해당 그룹에 속한 모든 학생의 모든 학습 정보를 가져옴.

#     # 결과를 저장할 딕셔너리
#     resultm = []
#     count_id = 0
#     # 데이터를 순회하며 필터링된 correct_problems의 개수를 셈
#     for entry in studyinfo:
#         id_ = entry.id
#         correct_problems = entry.correct_problems
#         filtered_problems = [
#             problem for problem in correct_problems
#             if problem.level == level and problem.step == step
#         ]
#         count += len(filtered_problems)
#         count_id += 1
#         resultm.append({"id": id_, "cnt": count})

#     # 결과 출력
#     return {"avg_study_stmt": f"{count / count_id:.2f}"} # 평균 학습 문장

# no use
# def get_max_step_in_level(data, start_level_name):
#     max_step = None
#     for level in data:
#         if level['level_name'] == start_level_name:
#             max_step = max(level['steps'])

#     if max_step is not None:
#         return max_step
#     else:
#         return 0


# no use
# def split_sentence(sentence: str) -> list:
#     # Separate words and punctuation marks.
#     return re.findall(r'\w+|[^\w\s]', sentence, re.UNICODE)