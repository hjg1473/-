from typing import Annotated, Optional
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo, Problems
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from routers.auth import get_current_user, get_user_exception

from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter(
    prefix="/server",
    tags=["server"],
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

class stdlevelOutput(BaseModel):
    type1level: int
    type2level: int
    type3level: int

# GPU 서버 -> 메인 서버로 업데이트된 학생의 유형별 수준 전달.
@router.put("/update_student_level/{user_id}")
async def update_user_level(user_id: int,
                    stdlevel: stdlevelOutput,
                    db: db_dependency):

    # 학습 정보 반환
    study_info = db.query(StudyInfo).filter(StudyInfo.owner_id == user_id).first()

    if study_info is None:
        raise http_exception()

    study_info.type1Level = stdlevel.type1level
    study_info.type2Level = stdlevel.type2level
    study_info.type3Level = stdlevel.type3level

    db.add(study_info)
    db.commit()

    return successful_response(200)

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
