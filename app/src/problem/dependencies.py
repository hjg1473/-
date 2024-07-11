from fastapi import Depends
from typing import Annotated
from sqlalchemy.orm import Session
from database import SessionLocal
from Refactor.app.src.auth.router import get_current_user

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]