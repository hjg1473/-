from super.dependencies import db_dependency
from app.src.models import Users, Groups, Problems, CustomProblemSet
from sqlalchemy import select, delete

async def get_problemset(problemset, db: db_dependency):
    result = await db.execute(select(CustomProblemSet).where(CustomProblemSet.name == problemset.name))
    custom_problem_set = result.scalars().first()
    return custom_problem_set

async def update_cproblem(problemset, db: db_dependency):
    custom_model = CustomProblemSet()
    custom_model.name = problemset.name

    db.add(custom_model)
    await db.commit()
    await db.refresh(custom_model)

    for problem in problemset.customProblems:
        problem_model = Problems()
        problem_model.koreaProblem = problem.koreaProblem
        problem_model.englishProblem = problem.englishProblem
        problem_model.img_path = problem.img_path
        problem_model.cproblem_id = custom_model.id
        db.add(problem_model)
        await db.commit()

async def get_cproblem_list(db: db_dependency):
    result = await db.execute(select(CustomProblemSet.name))
    cproblem_list = result.scalars().all()
    return cproblem_list

async def get_cproblems(set_name, db: db_dependency):
    result = await db.execute(select(CustomProblemSet).where(CustomProblemSet.name == set_name))
    custom_problem_set = result.scalars().first()
    from super.exceptions import custom_problem_exception
    custom_problem_exception(custom_problem_set)
    result2 = await db.execute(select(Problems).where(custom_problem_set.id == Problems.cproblem_id))
    custom_problems = result2.scalars().all()
    return custom_problems

async def delete_cproblem(set_name, db: db_dependency):
    result = await db.execute(select(CustomProblemSet).where(CustomProblemSet.name == set_name))
    custom_problem_set = result.scalars().first()
    from super.exceptions import custom_problem_exception
    custom_problem_exception(custom_problem_set)
    await db.execute(delete(Problems).where(Problems.cproblem_id == custom_problem_set.id))
    await db.execute(delete(CustomProblemSet).where(CustomProblemSet.name == set_name))
    await db.commit()

async def get_group_list(admin_id, db: db_dependency):
    result = await db.execute(select(Groups).where(Groups.admin_id == admin_id))
    group_list = result.scalars().all()
    return group_list

async def get_group_name(name, admin_id, db: db_dependency):
    result = await db.execute(select(Groups).where(Groups.name == name, Groups.admin_id == admin_id))
    group_name = result.scalars().first()
    return group_name

async def update_new_group(addgroup, admin_id, db: db_dependency):
    group_model = Groups()
    group_model.name = addgroup.name
    group_model.admin_id = admin_id

    db.add(group_model)
    await db.commit()

async def get_std_info(group_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.team_id == group_id))
    user_group = result.scalars().all()
    return user_group

async def update_std_group(group_id, user_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.id == user_id))
    student_model = result.scalars().first()
    student_model.team_id = group_id

    db.add(student_model)
    await db.commit()

async def get_super_info(user, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    return { "name": user_model.name }