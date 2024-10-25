from super.dependencies import db_dependency
from app.src.models import Users, Groups, Problems, teacher_group_table, ReleasedGroup, correct_problem_table, incorrect_problem_table, StudyInfo, Released, WrongType
from sqlalchemy import select, delete, insert, func
from sqlalchemy.orm import joinedload


### CREATE

async def create_group_released(group_id:int, season:int, db:db_dependency):
    new_released_group_normal = ReleasedGroup(
        owner_id = group_id,
        released_season=season,
        released_type="normal",
        released_level=0,
        released_step=0
    )
    db.add(new_released_group_normal)
    new_released_group_ai = ReleasedGroup(
        owner_id = group_id,
        released_season=season,
        released_type="ai",
        released_level=0,
        released_step=0
    )
    db.add(new_released_group_ai)
    await db.commit()
    return [new_released_group_normal, new_released_group_ai]


### FETCH

async def fetch_problems(level, step, db: db_dependency):
    result = await db.execute(select(func.count()).select_from(Problems).filter(Problems.level == level, Problems.step == step))
    return result.scalar()

async def fetch_user_correct_problems(user_id, db: db_dependency):
    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_groups(group_id, db: db_dependency):
    result = await db.execute(select(Groups).filter(Groups.id == group_id))
    return result.scalars().all()

async def fetch_released_user(user_id, db: db_dependency):
    result = await db.execute(select(Released).filter(Released.owner_id == user_id))
    return result.scalars().all()

async def fetch_wrongType_id_season(id, season, db: db_dependency):
    result = await db.execute(select(WrongType).filter(WrongType.info_id == id).filter(WrongType.season == season))
    return result.scalars().all()

async def fetch_user_problems(user_id, db: db_dependency):
    result = await db.execute(select(StudyInfo).options(joinedload(StudyInfo.correct_problems)).options(joinedload(StudyInfo.incorrect_problems)).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_user_teamId_group(group_id, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.team_id == group_id))
    return result.scalars().all()

async def fetch_user_id_all(user_id, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.id == user_id))
    return result.scalars().all()

async def fetch_problem_count(user_id, db: db_dependency):
    result = await db.execute(select(StudyInfo)
                              .options(joinedload(StudyInfo.correct_problems))
                              .options(joinedload(StudyInfo.incorrect_problems))
                              .filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_studyInfo(user_id, db: db_dependency):
    result = await db.execute(select(StudyInfo).filter(StudyInfo.owner_id == user_id))
    return result.scalars().first()

async def fetch_group_list(admin_id, db: db_dependency):
    result = await db.execute(select(teacher_group_table).where(teacher_group_table.c.teacher_id == admin_id))
    groups = result.fetchall()
    group_ids = []
    for row in groups:
        print(f"teacher_id: {row[0]}, group_id: {row[1]}")
        group_ids.append(row[1])
    result2 = await db.execute(select(Groups).where(Groups.id.in_(group_ids)))
    group_list = result2.scalars().all()
    return group_list

async def fetch_group_name(name, admin_id, db: db_dependency):
    stmt = (
        select(Groups)
        .join(teacher_group_table, teacher_group_table.c.group_id == Groups.id)
        .where(Groups.name == name, teacher_group_table.c.teacher_id == admin_id)
    )
    result = await db.execute(stmt)
    group_name = result.scalars().first()
    return group_name

async def fetch_user_group(group_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.team_id == group_id))
    user_group = result.scalars().all()
    return user_group

async def fetch_user_group_count(group_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.team_id == group_id))
    user_group = result.scalars().all()
    user_count = len(user_group)
    return user_count

async def fetch_super_info(user, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    return { "name": user_model.name, 'id': user_model.id }

async def fetch_user_id(user_id, db: db_dependency):
    result = await db.execute(select(Users).filter(Users.id == user_id))
    return result.scalars().first()

async def fetch_group_id(group_id, db: db_dependency):
    result = await db.execute(select(Groups).filter(Groups.id == group_id))
    return result.scalars().first()

async def fetch_user_teamId(user_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.id == user_id))
    user_group = result.scalars().first()
    return user_group.team_id

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


### UPDATE

async def update_student_group(group_id, user_id, db: db_dependency):
    result = await db.execute(select(Users).where(Users.id == user_id))
    student_model = result.scalars().first()
    student_model.team_id = group_id

    db.add(student_model)
    await db.commit()

async def update_new_group(addgroup, admin_id, db: db_dependency):
    group_model = Groups()
    group_model.name = addgroup.name
    group_model.detail = addgroup.detail
    from datetime import datetime
    group_model.created = datetime.today().strftime("%y.%m.%d")
    
    db.add(group_model)
    await db.commit()
    await db.refresh(group_model)
    stmt = insert(teacher_group_table).values({'teacher_id': admin_id, 'group_id': group_model.id})
    await db.execute(stmt)
    await db.commit()
    return group_model

async def update_group_name(group_id, name, detail, db: db_dependency):
    result = await db.execute(select(Groups).filter(Groups.id == group_id))
    group_model = result.scalars().first()
    group_model.name = name
    group_model.detail = detail

    db.add(group_model)
    await db.commit()

async def update_group_level_and_step(group_id, season, level, type, step, db):
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id, ReleasedGroup.released_type == type, ReleasedGroup.released_season == season))
    releasedGroup_model = result.scalars().first()
    releasedGroup_model.released_level = level
    releasedGroup_model.released_step = step
    db.add(releasedGroup_model)
    await db.commit()
