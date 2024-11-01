import random
import os
import sys
from sqlalchemy import func, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems
from game.constants import PROBLEM_OFFSET, PROBLEM_COUNT
from game.schemas import ProblemSelectionCriteria


# Store the ID of the problem that is already out for each room
# To prevent overlapping questions
used_problem_ids = {}

def initialize_used_problems_in_room(room_id: str):
    if room_id not in used_problem_ids:
        used_problem_ids[room_id] = set()

def clear_used_problems_in_room(room_id: str):
    if room_id in used_problem_ids:
        del used_problem_ids[room_id]
        

async def select_random_problems(criteria: ProblemSelectionCriteria, db, room_id: str):

    initialize_used_problems_in_room(room_id)
    total_count = await db.scalar(
        select(func.count()).select_from(Problems)
        .filter(Problems.level == criteria.level)
        .filter(Problems.season == criteria.season)
        .filter(Problems.difficulty == criteria.difficulty)
        .filter(Problems.type == "ai")
        .filter(~Problems.id.in_(used_problem_ids[room_id])) 
    )

    if total_count == 0:
        return "No more Problem"

    random_offset = random.randint(0, max(0, total_count - PROBLEM_OFFSET))

    result = await db.execute(
        select(Problems)
        .filter(Problems.level == criteria.level)
        .filter(Problems.season == criteria.season)
        .filter(Problems.difficulty == criteria.difficulty)
        .filter(Problems.type == "ai")
        .filter(~Problems.id.in_(used_problem_ids[room_id]))  # Avoid duplication
        .offset(random_offset)
        .limit(PROBLEM_OFFSET)
    )

    random_problems = result.scalars().all()
    final_problems = random.sample(random_problems, min(PROBLEM_COUNT, len(random_problems)))
    used_problem_ids[room_id].update(problem.id for problem in final_problems)

    return final_problems
