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
    prefix="/super",
    tags=["super"],
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
async def read_info(user: user_dependency, db: db_dependency):
    if user is None:
        raise get_user_exception()

    user_model = db.query(Users.id, Users.username, Users.email, Users.phone_number).filter(Users.id == user.get('id')).first()
    user_model_json = { "id": user_model[0], "username": user_model[1], "email": user_model[2], "phone_number": user_model[3] }
    return user_model_json
    # 필터 사용. 학습 정보의 owner_id 와 '유저'의 id가 같으면, 해당 학습 정보 반환.
    # 사용자의 id, username, email, phone_number 반환

@router.get("/dashboard/{class_number}")
async def read_dashboard(class_number: int,
                    user: dict = Depends(get_current_user),
                    db: Session = Depends(get_db)):
    
    if user is None or user.get('user_role') != 'super': # super 인 경우만 
        raise HTTPException(status_code=401, detail='Authentication Failed')
    
    user_group = db.query(Users)\
        .filter(Users.group == class_number)\
        .all()
    if user_group is not None:
        return user_group
    raise http_exception()

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")
