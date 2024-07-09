from fastapi import APIRouter, File, UploadFile
import easyocr


router = APIRouter(
    prefix="/ocr",
    tags=["ocr"],
    responses={401: {"user": "no image"}} # 뭐 써야되지?
)
reader = easyocr.Reader(['en'], gpu=True, allowlist='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', text_threshold=0.4,low_text=0.4)

@router.post("/")
async def ocr(file:UploadFile=File(...)):
    contents = await file.read()   # 사진 바이너리데이타

    result = reader.readtext(contents, detail=0)
    return result