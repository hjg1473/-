from fastapi import APIRouter, HTTPException
import sys, os
import re
from sqlalchemy import func, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import ProblemSet, AddGroup, GroupStep, LogResponse
from super.exceptions import *
from starlette import status
from app.src.models import Users, StudyInfo, Problems, correct_problem_table, Groups, Released, WrongType
from app.src.problem.service import get_correct_problem_count, get_incorrect_problem_count
from sqlalchemy.orm import joinedload

def calculate_corrects(table_id, ai_corrects ,normal_corrects ,table_count, rm, study_info):
    for item in study_info:
        if item.season == rm.released_season:
            count = table_count[table_id.index(item.id)]
            if item.type == "normal":
                normal_corrects[item.level] += count
            else:
                ai_corrects[item.level] += count

def weak_parts_top3(wrongType_model):
    divided_data_list = []

    for wrongTypes in wrongType_model:
        total_wrongType = (
            wrongTypes.wrong_punctuation
            + wrongTypes.wrong_order
            + wrongTypes.wrong_letter
            + wrongTypes.wrong_block
            + wrongTypes.wrong_word
        )
        
        wrong_data = {k: v for k, v in vars(wrongTypes).items() if k.startswith("wrong")}
        
        top3_wrong = dict(sorted(wrong_data.items(), key=lambda item: item[1], reverse=True)[:3])
        
        if total_wrongType != 0:
            divided_data = {k: f"{v / total_wrongType:.2f}" for k, v in top3_wrong.items()}
        else:
            divided_data = {k: f"{0:.2f}" for k, v in top3_wrong.items()}
        divided_data["season"] = wrongTypes.season
        divided_data["level"] = wrongTypes.level
        divided_data_list.append(divided_data)

    return divided_data_list

async def user_weakest_info(user_id, db):
    # 학생이 해금한 시즌 정보
    result2 = await db.execute(select(Released).filter(Released.owner_id == user_id))
    released_model = result2.scalars().all()
    seasons = [item.released_season for item in released_model]

    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
    study_info = result.scalars().first()
    temp_result = await db.execute(select(WrongType).filter(WrongType.info_id == study_info.id).filter(WrongType.season.in_(seasons)))
    wrongType_model = temp_result.scalars().all()
    # return wrongType_model
    total_wrong_punctuation=0
    total_wrong_order=0
    total_wrong_letter=0
    total_wrong_block=0
    total_wrong_word=0
    for wrongTypes in wrongType_model:
        # 총 wrong 타입 합계 계산
        total_wrong_punctuation += wrongTypes.wrong_punctuation
        total_wrong_order += wrongTypes.wrong_order
        total_wrong_letter += wrongTypes.wrong_letter
        total_wrong_block += wrongTypes.wrong_block
        total_wrong_word += wrongTypes.wrong_word
    
    values = {'wrong_punctuation': total_wrong_punctuation, 'wrong_order': total_wrong_order, 'wrong_letter': total_wrong_letter, 'wrong_block': total_wrong_block, 'wrong_word': total_wrong_word}
    largest_variable = max(values, key=values.get)
    if (total_wrong_punctuation+total_wrong_order+total_wrong_letter+total_wrong_block+total_wrong_word) == 0:
        return "정보 없음"

    return f"{largest_variable}"

async def user_step_problem_count(user_id, season, level, attribute_name, db):

    result2 = await db.execute(select(Users).filter(Users.id == user_id))
    students = result2.scalars().all()

    # return students # 특정 학생의 모든 정보
    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은+틀린 문제들 저장. 

    # if study_info is None:
    #     raise http_exception()
    
    result = []
    # return studyinfo # 특정 학생의 학습 정보
    for item in studyinfo:
        # correct_problem_ids = [{"id": problem.id} for problem in item.correct_problems if problem.type == step]
        correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name) if problem.season == season and problem.level == level]
        result_item = {
            "id": item.id,
            attribute_name: correct_problem_ids
        }
        result.append(result_item)

    # return result # 학습정보 id -> 맞은 문제 id .json
    count = 0
    for item in result:
        if item[attribute_name]:
            for p in item[attribute_name]:
                if attribute_name == "correct_problems":
                    count += await get_correct_problem_count(item["id"], p["id"], db)
                else:
                    count += await get_incorrect_problem_count(item["id"], p["id"], db)
    
    # db.add(study_info)
    # await db.commit()

    return count # 문제개수의 누적합 

async def user_worst_problem(user_id, attribute_name, db):

    result2 = await db.execute(select(Users).filter(Users.id == user_id))
    students = result2.scalars().all()

    # return students # 특정 학생 개인의 정보
    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은+틀린 문제들 저장. 

    # if study_info is None:
    #     raise http_exception()
    
    result = []
    # return studyinfo # 특정 학생 개인의 학습 정보
    for item in studyinfo:
        # correct_problem_ids = [{"id": problem.id} for problem in item.correct_problems if problem.type == step]
        correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name)]
        result_item = {
            "id": item.id,
            attribute_name: correct_problem_ids
        }
        result.append(result_item)

    # return result # 학습정보 id -> 맞은 문제 id .json
    countProblem = []
    for item in result:
        if item[attribute_name]:
            for p in item[attribute_name]:
                count = await get_correct_problem_count(item["id"], p["id"], db)
                countProblem.append({'problem_id': p["id"], f"{attribute_name}"+'_count': count})
    
    # return countProblem # 맞은 문제별 카운트 
    max_correct_count = 0
    for problem in countProblem:
        correct_count = problem.get('correct_problems_count', 0)
        if correct_count > max_correct_count:
            max_correct_count = correct_count
            max_problem_id = problem["problem_id"]
            
    if max_correct_count == 0:
        return get_studyInfo_exception(0, 0)
    # return max_problem_id # 가장 횟수가 많은 문제 아이디

    result3 = await db.execute(select(Problems).filter(Problems.id == max_problem_id))
    highProblem = result3.scalars().first()

    return {'level': highProblem.level, 'step': highProblem.step, 'id(temp)': highProblem.id} # 정보. 다만 번호는 어떻게 구현할지..

async def group_step_problem_count(group_id, season, level, attribute_name, db):

    result2 = await db.execute(select(Groups).filter(Groups.id == group_id))
    groups = result2.scalars().all()
    # return groups # 그룹 정보
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students = result3.scalars().all()

    # return students # 그룹에 속한 모든 학생 정보
    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은+틀린 문제들만 저장. 

    # if study_info is None:
    #     raise http_exception()
    
    result = []
    # return studyinfo # 특정 그룹에 해당하는 모든 학생들의 학습 정보
    for item in studyinfo:
        correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name) if problem.season == season and problem.level == level]
        result_item = {
            "id": item.id,
            attribute_name: correct_problem_ids
        }
        result.append(result_item)

    # return result # 학습정보 id -> 맞은 문제 id .json
    count = 0
    for item in result:
        if item[attribute_name]:
            for p in item[attribute_name]:
                if attribute_name == "correct_problems":
                    count += await get_correct_problem_count(item["id"], p["id"], db)
                else:
                    count += await get_incorrect_problem_count(item["id"], p["id"], db)
    
    # db.add(study_info)
    # await db.commit()

    return count

async def group_avg_time(group_id, db):

    result2 = await db.execute(select(Groups).filter(Groups.id == group_id))
    groups = result2.scalars().all()
    # return groups # 그룹 정보
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students = result3.scalars().all()

    # return students # 그룹에 속한 모든 학생 정보
    group_total_time = 0
    cnt = 0
    for s in students:
        result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        group_total_time += study_info.totalStudyTime
        cnt += 1
        # studyinfo.append(study_info) 
    
    group_count_exception(cnt)
    return {"group_avg_time(minutes)": group_total_time // cnt }

async def group_student_problem(group_id, step, level, db):

    count_query = select(func.count()).select_from(Problems).filter(Problems.level == level, Problems.step == step)
    result = await db.execute(count_query)
    count_problem = result.scalar()
    if count_problem == 0:
        return {'detail' : '입력한 레벨, 스텝에 해당하는 문제가 없습니다.'}

    # return count # 해당 레벨-스텝의 문제 개수를 가져옴.

    result2 = await db.execute(select(Groups).filter(Groups.id == group_id))
    groups = result2.scalars().all()
    # return groups # 그룹 정보
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students = result3.scalars().all()

    # return students # 그룹에 속한 모든 학생 정보
    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은 문제들만 저장. 

    # if study_info is None:
    #     raise http_exception()
    # return studyinfo # 해당 그룹에 속한 모든 학생의 모든 학습 정보를 가져옴.

    # 결과를 저장할 딕셔너리
    resultm = []

    # 데이터를 순회하며 필터링된 correct_problems의 개수를 셈
    for entry in studyinfo:
        id_ = entry.id
        correct_problems = entry.correct_problems
        filtered_problems = [
            problem for problem in correct_problems
            if problem.level == level and problem.step == step
        ]
        count = len(filtered_problems)
        resultm.append({"id": id_, "cnt": count})

    # return resultm # 반에 소속된 학생(id) 별, 선택한 레벨-스텝 별 맞은 문제 개수. 

    pass_step_students = 0
    total_students = 0
    # 데이터를 순회하며 cnt가 count_problem인 항목을 카운트
    for item in resultm:
        total_students += 1
        if item["cnt"] == count_problem:
            pass_step_students += 1

    return {"pass_step_students": pass_step_students, "total_students": total_students}


async def group_student_progress(group_id, step, level, db):

    count_query = select(func.count()).select_from(Problems).filter(Problems.level == level, Problems.step == step)
    result = await db.execute(count_query)
    count_problem = result.scalar()
    if count_problem == 0:
        return 0

    result2 = await db.execute(select(Groups).filter(Groups.id == group_id))
    groups = result2.scalars().all()
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students = result3.scalars().all()

    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은 문제들만 저장. 

    resultm = []

    # 데이터를 순회하며 필터링된 correct_problems의 개수를 셈
    for entry in studyinfo:
        id_ = entry.id
        correct_problems = entry.correct_problems
        filtered_problems = [
            problem for problem in correct_problems
            if problem.level == level and problem.step == step
        ]
        count = len(filtered_problems)
        resultm.append({"id": id_, "cnt": count})

    # cnt가 2인 항목의 개수를 세기 위한 변수
    pass_step_students = 0
    total_students = 0
    # 데이터를 순회하며 cnt가 2인 항목을 카운트
    for item in resultm:
        total_students += 1
        if item["cnt"] == count_problem:
            pass_step_students += 1

    # 결과 출력
    if total_students != 0:
        return pass_step_students / total_students 
    else:
        return 0

async def group_avg_student_problem(group_id, step, level, db):

    count_query = select(func.count()).select_from(Problems).filter(Problems.level == level, Problems.step == step)
    result = await db.execute(count_query)
    count = result.scalar()

    # return count # 해당 스텝의 문제 개수를 가져옴.

    result2 = await db.execute(select(Groups).filter(Groups.id == group_id))
    groups = result2.scalars().all()
    # return groups # 그룹 정보
    students = []
    for g in groups:
        result3 = await db.execute(select(Users).filter(Users.team_id == g.id))
        students = result3.scalars().all()

    # return students # 그룹에 속한 모든 학생 정보
    studyinfo = []
    for s in students:
        result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).filter(StudyInfo.owner_id == s.id))
        study_info = result.scalars().first()
        studyinfo.append(study_info) # 맞은 문제들만 저장. 

    # if study_info is None:
    #     raise http_exception()
    # return studyinfo # 해당 그룹에 속한 모든 학생의 모든 학습 정보를 가져옴.

    # 결과를 저장할 딕셔너리
    resultm = []
    count_id = 0
    # 데이터를 순회하며 필터링된 correct_problems의 개수를 셈
    for entry in studyinfo:
        id_ = entry.id
        correct_problems = entry.correct_problems
        filtered_problems = [
            problem for problem in correct_problems
            if problem.level == level and problem.step == step
        ]
        count += len(filtered_problems)
        count_id += 1
        resultm.append({"id": id_, "cnt": count})

    # 결과 출력
    return {"avg_study_stmt": f"{count / count_id:.2f}"} # 평균 학습 문장

def get_max_step_in_level(data, start_level_name):
    max_step = None
    for level in data:
        if level['level_name'] == start_level_name:
            max_step = max(level['steps'])

    if max_step is not None:
        return max_step
    else:
        return 0
    

async def get_latest_log(user_id: int):
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
    response = await es.search(index="logstash-logs-*", body=query)
    
    if response["hits"]["total"]["value"] == 0:
        return
        # raise HTTPException(status_code=404, detail="Log not found")
    
    # 가장 최근의 로그 추출
    latest_log = response["hits"]["hits"][0]["_source"]
    
    # message 필드를 파싱하여 problem과 answer 추출
    message = latest_log.get("message")
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
    
    return LogResponse(problem=problem, answer=answer)

def split_sentence(sentence: str) -> list:
    # 정규 표현식을 사용하여 단어와 구두점을 분리
    return re.findall(r'\w+|[^\w\s]', sentence, re.UNICODE)


async def process_user_access(user, user_id, db):
    super_authenticate_exception(user)
    await find_student_exception(user_id, db)
    std_team_id = await get_std_team_id(user_id, db)
    group_list = await get_group_list(user.get("id"), db)
    
    if group_list:
        std_access_exception(group_list, std_team_id)
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