import random
import os
import sys
from sqlalchemy import func, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems
from game.constants import PROBLEM_OFFSET, PROBLEM_COUNT
from game.schemas import ProblemSelectionCriteria


async def select_random_problems(criteria: ProblemSelectionCriteria, db):
    total_count = await db.scalar(select(func.count()).select_from(Problems)
                                  .filter(Problems.level == criteria.level)
                                  .filter(Problems.season == criteria.season)
                                  .filter(Problems.difficulty == criteria.difficulty)
                                  .filter(Problems.type == "ai"))
    random_offset = random.randint(0, max(0, total_count - PROBLEM_OFFSET))

    if total_count == 0:
        return "error"
    # PROBLEM_OFFSET개의 데이터 가져오기
    result = await db.execute(
        select(Problems)
        .filter(Problems.level == criteria.level)
        .filter(Problems.season == criteria.season)
        .filter(Problems.difficulty == criteria.difficulty)
        .filter(Problems.type == "ai")
        .offset(random_offset)
        .limit(PROBLEM_OFFSET)
    )

    # 무작위로 n개 선택 > 10개
    random_problems = result.scalars().all()
    final_problems = random.sample(random_problems, min(PROBLEM_COUNT, len(random_problems)))
    return final_problems