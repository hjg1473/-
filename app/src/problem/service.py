from sqlalchemy import select
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems
from problem.schemas import Problem
from problem.dependencies import db_dependency

async def create_problem_in_db(db: db_dependency, problem: Problem) -> Problems:
    new_problem = Problems(
        season = problem.season,
        type = problem.type,
        problemLevel = problem.problemLevel,
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