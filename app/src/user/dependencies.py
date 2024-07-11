from typing import Annotated
from sqlalchemy.orm import Session
from fastapi import Depends
from database import SessionLocal

from Server.routers.auth import get_current_user

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]