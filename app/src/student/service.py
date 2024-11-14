import sys, os
from sqlalchemy import select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from student.dependencies import db_dependency
from app.src.models import Released, StudyInfo
from app.src.models import Users, Groups, Problems, teacher_group_table, ReleasedGroup, correct_problem_table, incorrect_problem_table, StudyInfo, Released, WrongType


async def fetch_user_released(user_id, db):
    result = await db.execute(select(Released).filter(Released.owner_id == user_id))
    return result.scalars().all() 

async def fetch_user_studyInfo(user_id, db):
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_wrongType_id_season(id, season, db: db_dependency):
    result = await db.execute(select(WrongType).filter(WrongType.info_id == id).filter(WrongType.season == season))
    return result.scalars().all()

async def fetch_studyInfo(user_id, db: db_dependency):
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_count_data(study_info_id, db):
    incorrect_count_query = select(incorrect_problem_table.c.count).filter(incorrect_problem_table.c.study_info_id == study_info_id)
    incorrect_id_query = select(incorrect_problem_table.c.problem_id).filter(incorrect_problem_table.c.study_info_id == study_info_id)
    correct_count_query = select(correct_problem_table.c.count).filter(correct_problem_table.c.study_info_id == study_info_id)
    correct_id_query = select(correct_problem_table.c.problem_id).filter(correct_problem_table.c.study_info_id == study_info_id)
    
    # Run all queries at once
    import asyncio
    results = await asyncio.gather(
        db.execute(incorrect_count_query),
        db.execute(incorrect_id_query),
        db.execute(correct_count_query),
        db.execute(correct_id_query)
    )
    
    incorrect_table_count = results[0].scalars().all()
    incorrect_table_id = results[1].scalars().all()
    correct_table_count = results[2].scalars().all()
    correct_table_id = results[3].scalars().all()
    
    return incorrect_table_count, incorrect_table_id, correct_table_count, correct_table_id