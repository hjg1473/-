from fastapi import Depends
from typing import Annotated
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.database import async_session

async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session

db_dependency = Annotated[Session, Depends(get_session)]
