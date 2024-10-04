from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import models
# import easyocr
from paddleocr import PaddleOCR
from src import models, database
from src.exceptions import add_exception_handler
from auth import router as auth_router
from problem import router as problem_router
from game import router as game_router
from student import router as student_router
from user import router as user_router
from super import router as super_router
# from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins={"*"},
#     allow_credentials=True,
#     allow_methods={"OPTIONS", "GET", "POST"},
#     allow_headers={"*"},
# )

add_exception_handler(app)
# 데이터베이스 초기화 함수
async def init_db():
    async with database.engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)

# reader = easyocr.Reader(['en'], model_storage_directory='/root/.EasyOCR/model/')

ocr = PaddleOCR(det_model_dir= "/root/OCR_models/det",rec_model_dir = "/root/OCR_models/rec",\
                det_db_thresh=0.1, det_db_box_thresh = 0.1,det_db_score_mode = "fast",det_db_unclip_ratio = 1.7, lang='en',\
                rec_char_dict_path = "/root/OCR_models/block_en_dict.txt",dorp_box=0.3)
@app.on_event("startup")
async def on_startup():
    await init_db()

app.include_router(auth_router.router)
app.include_router(problem_router.router)
app.include_router(game_router.router)
app.include_router(student_router.router)
app.include_router(user_router.router)
app.include_router(super_router.router)
