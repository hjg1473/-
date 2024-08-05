from sqlalchemy import delete, select
from fastapi import APIRouter
from starlette import status
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from app.src.models import Users
from user.dependencies import user_dependency, db_dependency
from user.schemas import UserQuitVerification, UserVerification, User_info, User_season
from user.utils import *
from user.exceptions import successful_response, http_exception, email_exception, password_exception, user_exception, group_exception

router = APIRouter(
    prefix='/users', 
    tags=['users']
)

@router.put("/password", status_code=status.HTTP_200_OK)
async def change_password(user: user_dependency, db: db_dependency,
                          user_verification: UserVerification):
    user_exception(user)
    
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    password_exception(user_verification.password, user_model.hashed_password)
    
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    db.add(user_model)
    await db.commit()

    return {'detail': '비밀번호가 변경되었습니다.'}

@router.put("/update", status_code=status.HTTP_200_OK)
async def update_user_info(user: user_dependency, db: db_dependency, user_info: User_info):
    user_exception(user)

    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    http_exception(user_model)
    
    await email_exception(user_info.email, db)

    user_model.name=user_info.name
    user_model.email=user_info.email
    user_model.phone_number=user_info.phone_number

    db.add(user_model)
    await db.commit()
    return successful_response(200)

@router.put("/update_season", status_code=status.HTTP_200_OK)
async def update_user_season(user: user_dependency, db: db_dependency, user_info: User_season):
    user_exception(user)

    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()

    http_exception(user_model)

    if user_model.released_season is None:
        user_model.released_season = '{"seasons":[]}'
    season_json = get_string_to_json(user_model.released_season)
    if dict(season_json).get("seasons") != None:
        if user_info.season not in season_json["seasons"]:
            season_json["seasons"].append(user_info.season)
        else:
            season_json["seasons"].remove(user_info.season)
    else:
        season_json["seasons"] = [user_info.season]
    user_model.released_season = get_json_to_string(season_json)
    # if user_model:
    #     user_model.released_season = user_info.season

    db.add(user_model)
    await db.commit()
    return successful_response(200)

@router.delete("/quit/", status_code=status.HTTP_200_OK)
async def delete_user(user: user_dependency, db: db_dependency, user_verification: UserQuitVerification):

    user_exception(user)
    
    result = await db.execute(select(Users).filter(Users.id == user.get('id')))
    user_model = result.scalars().first()
    http_exception(user_model)
    from app.src.super.service import get_group_list
    if user_model.role == 'super':
        group_list = await get_group_list(user.get("id"), db)
        group_exception(group_list)

    password_exception(user_verification.password, user_model.hashed_password)
    
    result = await db.execute(delete(Users).filter(Users.id == user.get('id')))
    await db.commit()

    return {'detail': '성공적으로 탈퇴되었습니다.'}