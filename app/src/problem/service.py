import sys, os
from sqlalchemy.dialects.mysql import insert
from sqlalchemy import select, update
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems, correct_problem_table
from problem.schemas import Problem
from problem.dependencies import db_dependency

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

async def increment_correct_problem_count(study_info_id: int, problem_id: int, db: db_dependency):
    # 업데이트 문 생성
    stmt = update(correct_problem_table).\
        where(
            correct_problem_table.c.study_info_id == study_info_id,
            correct_problem_table.c.problem_id == problem_id
        ).\
        values(count=correct_problem_table.c.count + 1)

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