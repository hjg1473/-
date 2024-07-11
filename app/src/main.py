from fastapi import FastAPI
import models
from database import engine
from auth import router as auth_router
from problem import router as problem_router
from game import router as game_router

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth_router.router)
app.include_router(problem_router.router)
app.include_router(game_router.router)