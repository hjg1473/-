from fastapi import FastAPI
import models
from database import engine
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List

from Refactor.app.src import models, exceptions, database
from auth import router as auth_router
from problem import router as problem_router
from game import router as game_router
from student import router as student_router
from user import router as user_router
from super import router as super_router

app = FastAPI()

# 데이터베이스 초기화 함수
async def init_db():
    async with database.engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)

@app.on_event("startup")
async def on_startup():
    await init_db()

app.include_router(auth_router.router)
# app.include_router(problem_router.router)
# app.include_router(game_router.router)
app.include_router(student_router.router)
app.include_router(user_router.router)
# app.include_router(super_router.router)


# @app.post("/users/", response_model=exceptions.User)
# async def create_user(user: exceptions.UserCreate, session: AsyncSession = Depends(database.get_session)):
#     db_user = models.User(name=user.name, email=user.email)
#     session.add(db_user)
#     await session.commit()
#     await session.refresh(db_user)
#     return db_user

# @app.get("/users/", response_model=List[exceptions.User])
# async def read_users(skip: int = 0, limit: int = 10, session: AsyncSession = Depends(database.get_session)):
#     result = await session.execute(select(models.User).offset(skip).limit(limit))
#     users = result.scalars().all()
#     return users

# @app.get("/users/{user_id}", response_model=exceptions.User)
# async def read_user(user_id: int, session: AsyncSession = Depends(database.get_session)):
#     result = await session.execute(select(models.User).filter(models.User.id == user_id))
#     user = result.scalar_one_or_none()
#     if user is None:
#         raise HTTPException(status_code=404, detail="User not found")
#     return user