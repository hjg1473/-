from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from auth.utils import CustomResponseException

def add_exception_handler(app: FastAPI):
    @app.exception_handler(CustomResponseException)
    async def custom_response_exception_handler(request: Request, exc: CustomResponseException):
        return JSONResponse(
            status_code=exc.code,  # HTTP 상태 코드를 200으로 설정
            content=exc.content
        )