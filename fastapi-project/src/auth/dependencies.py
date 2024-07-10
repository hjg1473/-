from fastapi import Depends
from typing import Annotated
from sqlalchemy.orm import Session
from database import SessionLocal

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]
