from typing import Annotated, List, Optional, Dict
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload
from fastapi import APIRouter, Depends, HTTPException, Path
from starlette import status
from models import Users, StudyInfo, Groups, Problems, CustomProblemSet
import models
from database import engine, SessionLocal
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from routers.auth import get_current_user, get_user_exception
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import random
from fastapi import FastAPI, File, Form, UploadFile, WebSocket, WebSocketDisconnect, HTTPException
import json


router = APIRouter(
    prefix="/game",
    tags=["game"],
    responses={404: {"description": "Not found"}}
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

models.Base.metadata.create_all(bind=engine)

templates = Jinja2Templates(directory="templates")

db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]    


# 방 객체 ?
class Room:
    def __init__(self, room_id: str, host_id: str):
        self.room_id = room_id 
        self.host_id = host_id
        self.participants: List[str] = [] # 참여자 리스트
        self.host_websocket: WebSocket = None # 웹소켓

rooms: Dict[str, Room] = {}

# 호스트가 방 생성할 때 쓰는 객체 
class CreateRoomRequest(BaseModel):
    host_id: str
    cproblem_id: int

# 참여자가 방 참가할 때 쓰는 객체
class JoinRoomRequest(BaseModel):
    room_id: str
    participant_id: str

class ParticipantSolveRequest(BaseModel):
    room_id: str
    participant_id: str
    pnum: int # 0~9
# ?
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {} # 활성화된 연결 딕셔너리

    async def connect(self, room_id: str, client_id: str, websocket: WebSocket):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        self.active_connections[room_id][client_id] = websocket

    def disconnect(self, room_id: str, client_id: str):
        self.active_connections[room_id].pop(client_id, None)

    async def send_personal_message(self, message: str, websocket: WebSocket): # 
        await websocket.send_text(message)

manager = ConnectionManager()

def create_pin_number():
    min = 0
    max = 999999
    return '{:06d}'.format(random.randint(min, max))

# 테스트용 임시 딕셔너리
custom_problem = { 
    "312321": ["I am pretty.", "I am cow.", "I am pig."],
    "543533": ["I am pretty.", "I am pretty.", "I am pretty."],
    "123232": ["I am pretty.", "I am pretty.", "I am pretty."]
}

# 게임에서 학생이 정답을 제출할 때
@router.post("/student_solve")
async def participant_action(room_id: str = Form(...),
        participant_id: str = Form(...),
        pnum: int = Form(...), # 0~9,
        file: UploadFile = File(...)):
    
    room = rooms.get(room_id)
    if not room:  # 방이 없으면
        raise HTTPException(status_code=404, detail="Room not found")
    if participant_id not in room.participants:  # 방에 참여자가 없으면
        raise HTTPException(status_code=400, detail="Participant not in the room")
    
    if room.host_websocket:  # 호스트 웹소켓이 존재하고 (= 호스트가 방을 만들고, 웹소켓으로 연결된 상태이면)
        # 여기서는 받은 이미지를 OCR 돌리고, 돌린 결과 값 가지고 단순 비교를 통해 정오답 판단.
        # 새로운 딕셔너리를 만들고, 키-값으로 저장하는데, 키는 room_id, 값은 그 방에서 선택한 커스텀 문제 "리스트"를 저장.
        # 몇번 문제인지는 어떻게 암? 프론트에서 전달할 수 있나
        # # 학생이 제출한 답변을 OCR을 돌리고 있는 GPU 환경으로 전송 및 단어를 순서대로 배열로 받음.
        
        # GPU_SERVER_URL = "http://146.148.75.252:8000/ocr/" 

        # img_binary = await file.read()
        # file.filename = "img.png"
        # files = {"file": (file.filename, img_binary)}
        # user_word_list = requests.post(GPU_SERVER_URL, files=files)
        # # 단어리스트를 문장으로 변환
        # user_string = " ".join(user_word_list.json())
        # answer은 키 값으로 값(리스트)를 찾은 다음에 문제 순서에 맞는 값 출력.
        answer = custom_problem["312321"][pnum]
        user_string = "I am pretty."

        if user_string == answer: # 정답이면 
            await manager.send_personal_message("True", room.host_websocket) # True 라는 메세지를 보냄.
        else: # 오답이면
            await manager.send_personal_message("False", room.host_websocket) # True 라는 메세지를 보냄.
        return {"detail": "Action sent to host"}
    else:
        raise HTTPException(status_code=400, detail="Host is not connected")

# 게임방 생성 api
# 호스트 1인당 하나의 방만
@router.post("/create_room")
async def create_room(request: CreateRoomRequest):
    for room in rooms.values():
        if room.host_id == request.host_id:
            raise HTTPException(status_code=400, detail="호스트는 하나의 방만 가질 수 있습니다.")
    pin_number = create_pin_number()
    rooms[pin_number] = Room(pin_number, request.host_id) # 방 생성

    # custom_problem_set = db.query(CustomProblemSet)\
    # .filter(CustomProblemSet.name == set_name)\
    # .first()

    # custom_problem_sets = db.query(Problems)\
    # .filter(custom_problem_set.id == Problems.cproblem_id)\
    # .all()  

    # result = custom_problem_sets

    return {"detail": "Room created successfully","pin_number": pin_number} # 메세지

# 게임방 참가 api
@router.post("/join_room")
async def join_room(request: JoinRoomRequest):
    room = rooms.get(request.room_id)
    if not room: # 방이 없으면
        raise HTTPException(status_code=404, detail="Room not found")
    if request.participant_id in room.participants: # 이미 중복된 참여이면
        raise HTTPException(status_code=400, detail="Participant already in the room")
    
    room.participants.append(request.participant_id) # 방 리스트에 추가. 
    # Notify the host if the host is connected
    if room.host_websocket: # 호스트 웹소켓이 존재하고 (= 호스트가 방을 만들고, 웹소켓으로 연결된 상태이면)
        # await ? 뒤의 작업이 완료될 때 까지 대기함. 
        await manager.send_personal_message(f"Participant {request.participant_id} has joined the room: {request.room_id}", room.host_websocket)
    return {"message": "Joined room successfully"}

# 웹소켓 : 이미 생성된 room_id 에 클라이언트를 연결 
# join_room 을 안하고, 연결을 바로 해도 연결이 되는 문제 발견
@router.websocket("/ws/{room_id}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str):
    
    room = rooms.get(room_id) # 입력한 room_id 를 가지고 rooms 리스트에서 값을 가져온다. 
    if not room: # 만약 없으면
        await websocket.close(code=1000) # code=1000 ? 을 호출하고 닫음 ?
        return

    if client_id == room.host_id: # 만약 클라이언트가 호스트면, 호스트 웹소켓 ? 에 추가.
        room.host_websocket = websocket
    else: # 호스트가 아니면
        for room in rooms.values(): # 참여자가 허용된 참여자인지 검사
            if client_id in room.participants:
                break
        else:
            await websocket.close(code=1000)
            raise HTTPException(status_code=400, detail="미등록된 참여자입니다.")

    await manager.connect(room_id, client_id, websocket) # await : 연결될 때까지 대기

    try:
        while True: # 무한 루프
            data = await websocket.receive_text() # receive_text() ? 할 때까지 대기 
            message_data = json.loads(data) # 받은 데이터를 json 형태로 ?
            message_text = message_data["message"] # { "message" : 받은 데이터 } ?

            for participant_id, participant_ws in manager.active_connections[room_id].items(): # 연결된 게임방의 아이템 ? 만큼 반복 ?
                if participant_id != client_id: # 참여자 id 와 클라이언트 id가 같지 않으면 (= 자기 자신한테는 메세지 안 보내게 하려고 ? )
                    await manager.send_personal_message(f"Message from {client_id}: {message_text}", participant_ws) #
    except WebSocketDisconnect:
        manager.disconnect(room_id, client_id)
        if client_id == room.host_id:
            room.host_websocket = None