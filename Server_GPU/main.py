from fastapi import FastAPI
from OCR import ocr


app=FastAPI()

app.include_router(ocr.router)
