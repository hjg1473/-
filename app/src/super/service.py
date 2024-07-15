from dependencies import db_dependency, user_dependency
from schemas import CustomProblem, ProblemSet, AddGroup
from app.src.models import Users, StudyInfo, Groups, Problems, CustomProblemSet
from sqlalchemy import select


async def get_problemset(problemset, db: db_dependency):
    custom_problem_set = await db.execute(select(CustomProblemSet).filter(CustomProblemSet.name == problemset.name)).scalar_one
    return custom_problem_set

async def update_cproblem(probelmset, db: )