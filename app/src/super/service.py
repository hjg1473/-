from super.dependencies import db_dependency, user_dependency
from super.schemas import CustomProblem, ProblemSet, AddGroup
from app.src.models import Users, StudyInfo, Groups, Problems, CustomProblemSet
from sqlalchemy import select, delete


async def get_problemset(problemset, db: db_dependency):
    custom_problem_set = await db.execute(select(CustomProblemSet)\
                                .where(CustomProblemSet.name == problemset.name))\
                                .scalar_one
    return custom_problem_set


async def update_cproblem(problemset, db: db_dependency):
    # 뭔가 잘못된거겉은데 일단 넘어가.. 
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
    cproblem_list = await db.execute(select(Problems.name)).all()
    return cproblem_list


async def get_cproblems(set_name, db: db_dependency):
    custom_problem_set = await db.execute(select(CustomProblemSet).where(CustomProblemSet.name == set_name)).first()
    custom_problems = await db.execute(select(custom_problem_set.id == Problems.cproblem_id)).all()
    
    return custom_problems


async def delete_cproblem(set_name, db: db_dependency):
    custom_problem_set = await db.execute(select(CustomProblemSet.name == set_name)).scalar_one()
    await db.execute(delete(CustomProblemSet).where(CustomProblemSet.name == set_name))
    await db.execute(delete(Problems).where(Problems.cproblem_id == custom_problem_set.id))
    await db.commit()


async def get_group_list(admin_id, db: db_dependency):
    group_list = await db.execute(select(Groups).where(Groups.admin_id == admin_id)).all()

    return group_list


async def get_group_name(name, admin_id, db: db_dependency):
    group_name = db.execute(select(Groups).where(Groups.name == name, Groups.admin_id == admin_id)).first()

    return group_name


async def update_new_group(addgroup, user, db: db_dependency):
    group_model = Groups()
    group_model.name = addgroup.name
    group_model.admin_id = user.get("id")

    db.add(group_model)
    await db.commit()


async def get_std_info(group_id, db: db_dependency):
    user_group = await db.execute(select(Users).where(Users.team_id == group_id)).all()

    return user_group


async def update_std_group(group_id, user_id, db: db_dependency):
    student_model = await db.execute(select(Users).where(Users.id == user_id)).first()
    student_model.team_id = group_id

    db.add(student_model)
    await db.commit()


async def get_super_info(user, db: db_dependency):
    user_model = db.execute(select(Users).where(user.get('id') == Users.id)).first()

    return { "name": user_model[0] }