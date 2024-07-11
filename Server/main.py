from fastapi import FastAPI
from app.src.student import student
from app.src.user import users
import models
from database import engine
from routers import auth, super, problem, server, game

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(super.router)
app.include_router(student.router)
app.include_router(problem.router)
app.include_router(server.router)
app.include_router(game.router)