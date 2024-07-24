from fastapi import APIRouter
import sys, os

from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import ProblemSet, AddGroup, GroupStep
from super.exceptions import *
from starlette import status
from app.src.models import Users, StudyInfo, Problems, correct_problem_table, Groups
from app.src.problem.service import get_correct_problem_count
from sqlalchemy.orm import joinedload

async def group_step_problem_count(group_id, step, attribute_name, db):

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

    for item in studyinfo:
        # correct_problem_ids = [{"id": problem.id} for problem in item.correct_problems if problem.type == step]
        correct_problem_ids = [{"id": problem.id} for problem in getattr(item, attribute_name) if problem.step == step]
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
                count += await get_correct_problem_count(item["id"], p["id"], db)
    
    # db.add(study_info)
    # await db.commit()

    return count