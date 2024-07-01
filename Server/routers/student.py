from typing import Annotated
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from routers.auth import get_current_user, get_user_exception

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter( 
    prefix="/student",
    tags=["student"],
    responses={404: {"description": "Not found"}}
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]
    
@router.get("/info", status_code = status.HTTP_200_OK)
async def read_user_all(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    return db.query(Users).filter(Users.id == user.get('id')).first()
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면,
    # 사용자의 모든 정보 반환.

    # Join 해서 학습 정보를 반환해야됨. + 노출되는 정보 필터링

@router.get("/id", status_code = status.HTTP_200_OK)
async def read_user_id(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()
    
    user_id = db.query(Users.id).filter(Users.id == user.get('id')).first()[0]
    user_id_json = { "id": user_id }
    return user_id_json
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면,
    # 사용자의 id 반환.

@router.get("/{user_id}", status_code = status.HTTP_200_OK)
async def read_user_studyInfo_all(user: user_dependency, db: db_dependency, user_id : int):
    if user is None:
        raise get_user_exception()
    
    studyinfo_model = db.query(StudyInfo)\
        .filter(StudyInfo.owner_id == user_id)\
        .first()
    if studyinfo_model is not None:
        return studyinfo_model
    raise http_exception()
    # 학습 정보의 owner_id 와 요청한 '유저'의 id가 같으면, 해당 학습 정보 반환.
    # 아직 문제 id만 갖는 상태(Join 안됨)
    # 자신의 학습 기록을 요청하는 API

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
