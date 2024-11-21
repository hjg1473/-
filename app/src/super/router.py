from fastapi import APIRouter, HTTPException
import sys, os
from sqlalchemy import delete, select
from sqlalchemy.orm import joinedload
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from super.dependencies import db_dependency, user_dependency
from super.service import *
from super.schemas import AddGroup, GroupName, UserStep, UserStep2, GroupId
from super.utils import *
from app.src.models import StudyInfo, Groups, WrongType, Released, Users, ReleasedGroup
from app.src.auth.utils import create_pin_number
import aioredis
from super.exceptions import *
from starlette import status

router = APIRouter(
    prefix="/super",
    tags=["super"],
    responses={404: {"description": "Not found"}}
)

# Request pin number (for parent connection)
@router.get("/parent/get_pin", status_code=status.HTTP_200_OK)
async def request_pin(user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # Create pin number.
    pin = await create_pin_number()
    await redis_client.setex(f"{pin}", 180, user.get('id')) # 180 seconds
    redis_client.close()
    await redis_client.wait_closed()
    return {'parent_pinNumber': pin}

# Request pin number (for group connection)
@router.post("/get_pin", status_code=status.HTTP_200_OK)
async def request_pin(group: GroupId, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group.group_id, db)
    redis_client = await aioredis.create_redis_pool('redis://localhost')
    # Create pin number
    pin = await create_pin_number()
    # Combine GroupID and UserID with ','. 
    await redis_client.setex(f"{pin}", 180, str(group.group_id) + "," + str(user.get('id'))) # 180 seconds
    redis_client.close()
    await redis_client.wait_closed()
    return {'group_pinNumber': pin}

# Get children managed by the parent.
@router.get("/parent/get_child", status_code = status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    result = await db.execute(select(Users).options(joinedload(Users.student_teachers)).filter(Users.id == user.get('id')))
    students = result.scalars().first()
    return {"children": [{"id": students.id, "name": students.name} for students in students.student_teachers]}


# Get group managed by the teacher.
@router.get("/group", status_code=status.HTTP_200_OK)
async def read_group_info(user: user_dependency, db: db_dependency):
    validate_super_user_role(user)

    # Fetch all groups managed by the teacher
    group_list = await fetch_group_list(user.get("id"), db)

    # Fetch user counts for all groups in a single query
    group_ids = [group.id for group in group_list]
    group_user_counts = await db.execute(
        select(Users.team_id, func.count(Users.id).label("user_count"))
        .where(Users.team_id.in_(group_ids))
        .group_by(Users.team_id)
    )

    # Map group_id to user counts
    user_count_map = {row.team_id: row.user_count for row in group_user_counts}

    # Build the result
    result = {
        'groups': [
            {'id': group.id, 'name': group.name, 'detail': group.detail, 'count': user_count_map.get(group.id, 0)}
            for group in group_list
        ]
    }
    return result

# Create group managed by the teacher.
@router.post("/create/group", status_code = status.HTTP_200_OK)
async def create_group(addgroup: AddGroup, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    # Group name exist?
    await existing_name_exception(addgroup.name, user.get('id'), db)
    newGroup = await update_new_group(addgroup, user.get('id'), db)
    # defalut released group: season1, level0, step0
    await create_group_released(newGroup.id, 1, db)
    return {'detail':'Success'}

# Search for students in group.
@router.get("/student_in_group/{group_id}", status_code = status.HTTP_200_OK)
async def read_group_student_info(group_id: int, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group_id, db)
    user_group = await fetch_user_group(group_id, db)
    result = { 'groups': [{'id': u.id, 'name': u.name} for u in user_group] }
    return result

# Update group id, name, detail ...
@router.put("/group_update", status_code = status.HTTP_200_OK)
async def group_update(group: GroupName, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    await existing_name_exception(group.group_name, user.get('id'), db)
    await validate_group_access(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)
    await update_group_name(group.group_id, group.group_name, group.group_detail, db)
    return {'detail' : 'Success'}

# Delete group
@router.delete("/group/remove_group/{group_id}", status_code = status.HTTP_200_OK)
async def delete_group(group_id: int, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    # To delete a group, it must have 0 members.
    if await fetch_user_group_count(group_id, db) != 0:
        raise group_remove_exception()
    await db.execute(delete(Groups).filter(Groups.id == group_id))
    await db.commit()
    return {'detail': '성공적으로 삭제되었습니다.'}

# teacher removes the student from the class.
@router.put("/group/remove_student/{user_id}", status_code = status.HTTP_200_OK)
async def update_user_team(user_id: int, user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    await find_student_exception(user_id, db)
    std_team_id = await fetch_user_teamId(user_id, db)
    group_list = await fetch_group_list(user.get("id"), db)
    validate_student_group_access(group_list, std_team_id)
    await update_student_group(None, user_id, db)
    return {'detail' : 'Success'}

# Check group info
@router.get("/group/{group_id}/info", status_code=status.HTTP_200_OK)
async def read_group_info(group_id:int, user:user_dependency, db:db_dependency):
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    # group_model = await fetch_group_id(group_id, db)
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id).filter(ReleasedGroup.released_type == "normal"))
    target_season = result.scalars().first()

    # Remove `id` and `owner_id` from each dictionary
    filtered_data = {}
    if target_season:
        filtered_data = {
            "released_level": target_season.released_level,
            "released_season": target_season.released_season,
            "released_step": target_season.released_step,
            "released_type": "normal"
        }

    return filtered_data

# Unlock group level, step.
@router.put("/group/{group_id}/problems/unlock", status_code= status.HTTP_200_OK)
async def unlock_step_level(group_id: int, season:int, level:int, step:int, user:user_dependency, db:db_dependency):
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group_id, db)
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id, ReleasedGroup.released_season == season))
    target_season = result.scalars().all()
    # Check Group's season.
    if not target_season:
        target_season = await create_group_released(group_id, season, db)

    # Repeat
    for target in target_season:
        if target.released_type == "normal":
            current_type = "normal"
            current_level = target.released_level
            current_step = target.released_step
            # If the level you are trying to unlock is lower than your current level, an error will occur.
            if (level < current_level):
                raise released_step_exception()
            # If the step you are trying to unlock is lower than your current step, an error will occur.
            elif (level == current_level) and (step <= current_step):
                raise released_step_exception()   

    await update_group_level_and_step(group_id, season, level, current_type, step, db)

    return {'detail' : 'success'}

# User info
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_super_info(user: user_dependency, db: db_dependency):
    validate_super_user_role(user)
    user_model_json = await fetch_super_info(user, db)
    return user_model_json



# Read user monitoring info. (weakest, studytime, day ...)
@router.post("/user_monitoring_summary", status_code = status.HTTP_200_OK)
async def read_user_monitoring_summary(userStep: UserStep2, user: user_dependency, db: db_dependency):

    # Check if user has access
    await process_user_access(user, userStep.user_id, db)
        
    # BEGIN_CHECKING_WEAK_PART
    study_info = await fetch_studyInfo(userStep.user_id, db)
    wrongType_model = await fetch_wrongType_id_season(study_info.id, userStep.season, db)
    divided_data_list = calculate_wrongType_percentage(wrongType_model)

    # END_CHECKING_WEAK_PART

    # BEGIN_CALCULATE_STUDY_RATE
    result = await db.execute(select(Released).filter(Released.owner_id == userStep.user_id).filter(Released.released_season == userStep.season))
    released_models = result.scalars().all()

    study_info = await fetch_user_problems(userStep.user_id, db)
    if study_info is None:
        raise http_exception()
    
    # Get studyinfo data. ( incorrect / correct problem id, count )
    ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_count_data(study_info.id , db)
    # TableData 객체 생성
    correct_data = TableData(c_table_id, c_table_count, study_info.correct_problems)
    incorrect_data = TableData(ic_table_id, ic_table_count, study_info.incorrect_problems)

    information = []
    for released_model in released_models:
        normal_rate, ai_rate = calculate_accuracy_rates(correct_data, incorrect_data, released_model)
        information.append({"season":released_model.released_season,
                                       "correct_rate_normal":normal_rate,
                                       "correct_rate_ai":ai_rate,
                                       "released_level":released_model.released_level,
                                       "released_step":released_model.released_step
                                       })
        
    # END_CALCULATE_STUDY_RATE

    # Read user Studyinfo.
    studyinfo_model = await fetch_studyInfo(userStep.user_id, db)

    return  {"weak_parts":divided_data_list, "rates": information, "totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}


# Read user monitoring info. (problem correct rate)
@router.post("/user_monitoring_study/rate", status_code = status.HTTP_200_OK)
async def read_user_studyinfo(userStep: UserStep2, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    result = await db.execute(select(Released).filter(Released.owner_id == userStep.user_id).filter(Released.released_season == userStep.season))
    released_models = result.scalars().all()

    study_info = await fetch_user_problems(userStep.user_id, db)
    if study_info is None:
        raise http_exception()
    
    # Get studyinfo data. ( incorrect / correct problem id, count )
    ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_count_data(study_info.id , db)
    # TableData 객체 생성
    correct_data = TableData(c_table_id, c_table_count, study_info.correct_problems)
    incorrect_data = TableData(ic_table_id, ic_table_count, study_info.incorrect_problems)

    information = []
    for released_model in released_models:
        normal_rate, ai_rate = calculate_accuracy_rates(correct_data, incorrect_data, released_model)
        information.append({"season":released_model.released_season,
                                       "correct_rate_normal":normal_rate,
                                       "correct_rate_ai":ai_rate,
                                       "released_level":released_model.released_level,
                                       "released_step":released_model.released_step
                                       })

    return {'detail': information}

# Read user monitoring info. (recent problem info, weak parts ... )
@router.post("/user_monitoring_incorrect", status_code = status.HTTP_200_OK)
async def read_user_weak_parts_top3(userStep: UserStep2, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    study_info = await fetch_studyInfo(userStep.user_id, db)
    wrongType_model = await fetch_wrongType_id_season(study_info.id, userStep.season, db)
    divided_data_list = calculate_wrongType_percentage(wrongType_model)
    # Get recently solved problems
    recent_problem_model = await get_latest_log(userStep.user_id)
    
    # If there are no recently solved problems, return the default value.
    if recent_problem_model is None:
        return {
            'weak_parts':divided_data_list, 'weakest': await find_weakest_type(userStep.user_id, db),
            'recent_detail':'최근 푼 문제 없음' 
        }
    elif recent_problem_model.problem == "" or recent_problem_model.answer == "":
        return {
            'weak_parts':divided_data_list, 'weakest': await find_weakest_type(userStep.user_id, db),
            'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer 
        }
    # elif recent_problem_model.answer == "":
    #     return {'weak_parts':divided_data_list, 'weakest': await find_weakest_type(userStep.user_id, db),'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer }


    from app.src.problem.service import calculate_wrongs
    from app.src.problem.utils import parse_sentence
    problem_parse = parse_sentence(recent_problem_model.problem) 
    response_parse = parse_sentence(recent_problem_model.answer)
    letter_wrong, punc_wrong, block_wrong, word_wrong, order_wrong = await calculate_wrongs(problem_parse, response_parse, db)
    values = {
        'letter_wrong': letter_wrong,
        'punc_wrong': punc_wrong,
        'block_wrong': block_wrong,
        'word_wrong': word_wrong,
        'order_wrong': order_wrong
    }
    max_variable = max(values, key=values.get)
    # If there are no maxValue, return the default value.
    if max_variable == 0:
        return {
            'weak_parts':divided_data_list, 'weakest': await find_weakest_type(userStep.user_id, db),
            'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 
            'recent_detail':'정보 없음' 
        }

    return {
        'weak_parts':divided_data_list, 'weakest': await find_weakest_type(userStep.user_id, db),
        'recent_problem':recent_problem_model.problem, 'recent_answer':recent_problem_model.answer, 
        'recent_detail':max_variable 
    }

# Read user monitoring info. ( StudyTime )
@router.post("/user_monitoring_etc", status_code = status.HTTP_200_OK)
async def read_user_id(userStep: UserStep, user: user_dependency, db: db_dependency):
    # Check if user has access
    await process_user_access(user, userStep.user_id, db)

    studyinfo_model = await fetch_studyInfo(userStep.user_id, db)
    return  {"totalStudyTime": studyinfo_model.totalStudyTime, 'streamStudyDay': studyinfo_model.streamStudyDay}


# Group monitoring info ( weakest, studytime, day, recent problem info, weak parts ... )
@router.post("/group_monitoring", status_code=status.HTTP_200_OK)
async def read_group_monitoring(group: GroupId, user: user_dependency, db: db_dependency):
    # Validate user and group access
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group.group_id, db)
    await find_group_exception(group.group_id, db)

    # Fetch group and student data
    groups = await fetch_groups(group.group_id, db)
    student_ids = [
        student.id
        for group_data in groups
        for student in await fetch_user_teamId_group(group_data.id, db)
    ]

    # Prepare study information data
    study_information = []
    for user_id in student_ids:
        released_models = await fetch_released_user(user_id, db)
        study_info = await fetch_user_problems(user_id, db)

        if study_info:
            ic_table_count, ic_table_id, c_table_count, c_table_id = await fetch_count_data(study_info.id, db)

            correct_data = TableData(c_table_id, c_table_count, study_info.correct_problems)
            incorrect_data = TableData(ic_table_id, ic_table_count, study_info.incorrect_problems)

            for released_model in released_models:
                normal_rate, ai_rate = calculate_accuracy_rates(correct_data, incorrect_data, released_model)
                study_information.append({
                    "season": released_model.released_season,
                    "correct_rate_normal": normal_rate,
                    "correct_rate_ai": ai_rate,
                    "released_level": released_model.released_level,
                    "released_step": released_model.released_step,
                    "levels": await get_level_steps_info(released_model.released_season, "normal", db),
                })

    # Merge duplicated seasons
    merged_information = {}
    for item in study_information:
        season = item["season"]
        if season not in merged_information:
            merged_information[season] = {
                "season": season,
                "correct_rate_normal": item["correct_rate_normal"],
                "correct_rate_ai": item["correct_rate_ai"],
                "released_level": item["released_level"],
                "released_step": item["released_step"],
                "levels": item["levels"],
                "count": 1,
            }
        else:
            merged = merged_information[season]
            # Sum up rates
            merged["correct_rate_normal"] = [
                x + y for x, y in zip(merged["correct_rate_normal"], item["correct_rate_normal"])
            ]
            merged["correct_rate_ai"] = [
                x + y for x, y in zip(merged["correct_rate_ai"], item["correct_rate_ai"])
            ]
            merged["count"] += 1

    # Calculate averages
    for key, value in merged_information.items():
        value["correct_rate_normal"] = [
            x / value["count"] for x in value["correct_rate_normal"]
        ]
        value["correct_rate_ai"] = [
            x / value["count"] for x in value["correct_rate_ai"]
        ]
        value.pop("count")  # Remove the count key after averaging

    # Final result
    merged_information_list = list(merged_information.values())

    # Weakest part calculation
    values = {'wrong_punctuation': 0, 'wrong_order': 0, 'wrong_letter': 0, 'wrong_block': 0, 'wrong_word': 0}
    for student in student_ids:
        value = await find_weakest_type(student, db)
        if value in values:
            values[value] += 1
    largest_variable = max(values, key=values.get)
    if len(set(values.values())) == 1:
        largest_variable = ''

    # Group metadata
    result2 = await db.execute(select(Groups).filter(Groups.id == group.group_id))
    groups_create = result2.scalars().first()

    return {
        "detail": merged_information_list,
        "weakest": f"{largest_variable}",
        "created": groups_create.created,
        "peoples": await fetch_user_group_count(group.group_id, db),
    }
