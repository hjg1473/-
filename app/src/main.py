
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import models
# import easyocr
from paddleocr import PaddleOCR
import models, database
# from src.cache import load_word_to_color
from exceptions import add_exception_handler
from auth import router as auth_router
from problem import router as problem_router
from game import router as game_router
from student import router as student_router
from user import router as user_router
from super import router as super_router
# from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.src.models import Words, Blocks

app = FastAPI()

add_exception_handler(app)
# 데이터베이스 초기화 함수
async def init_db():
    async with database.engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)

ocr = PaddleOCR(det_model_dir= "/home/martinjgk/OCR_models/det",rec_model_dir = "/home/martinjgk/OCR_models/rec",\
                det_db_thresh=0.1, det_db_box_thresh = 0.1,det_db_score_mode = "fast",det_db_unclip_ratio = 1.7, lang='en',\
                rec_char_dict_path = "/home/martinjgk/OCR_models/block_en_dict.txt",dorp_box=0.3)

# 데이터베이스에서 데이터를 가져와 캐시에 저장하는 함수
async def fetch_initial_data():
    async with AsyncSession(database.engine) as session:
        result = await session.execute(select(Words, Blocks).join(Blocks, Words.block_id == Blocks.id)) 
        app.state.word_to_color_cache = {word_model.words: block_model.color for word_model, block_model in result.fetchall()}

@app.on_event("startup")
async def on_startup():
    await init_db()
    await fetch_initial_data()

app.include_router(auth_router.router)
app.include_router(problem_router.router)
app.include_router(game_router.router)
app.include_router(student_router.router)
app.include_router(user_router.router)
app.include_router(super_router.router)
