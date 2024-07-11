from fastapi import APIRouter, HTTPException
from starlette import status
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from Refactor.app.src.models import Users, StudyInfo, Groups, Problems, CustomProblemSet
import Refactor.app.src.models
from fastapi import FastAPI, File, Form, UploadFile, WebSocket, WebSocketDisconnect
import json
from game.schemas import Room, CreateRoomRequest, JoinRoomRequest, GetStudentScoreRequest, ParticipantSolveRequest, ConnectionManager, rooms
from game.dependencies import user_dependency, db_dependency
from game.utils import create_pin_number
from game.exceptions import room_exception, participant_exception, host_exception1, participant_exception1, participant_exception2, participant_exception3

router = APIRouter(
    prefix="/game",
    tags=["game"],
    responses={404: {"description": "Not found"}}
)

manager = ConnectionManager()

# 테스트용 임시 딕셔너리
custom_problem = { 
    "312321": ["I am pretty.", "I am cow.", "I am pig."],
    "543533": ["I am pretty.", "I am pretty.", "I am pretty."],
    "123232": ["I am pretty.", "I am pretty.", "I am pretty."]
}

# 게임방 호스트가 참여자의 모든 누적 점수 요청
@router.post("/super/student_score")
async def create_room(request: GetStudentScoreRequest):
    room = rooms.get(request.room_id)

    return room.participants


# 게임에서 학생이 정답을 제출할 때
@router.post("/student_solve")
async def participant_action(room_id: str = Form(...),
        participant_id: str = Form(...),
        pnum: int = Form(...), # 0~9,
        file: UploadFile = File(...)):
    
    room = rooms.get(room_id)
    if not room:  # 방이 없으면
        raise room_exception()
    if participant_id not in room.participants:  # 방에 참여자가 없으면
        raise participant_exception()
    
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
            # await manager.send_personal_message(f"Participant {participant_id} is right", room.host_websocket) # True 라는 메세지를 보냄.
            room.participants[participant_id] += 100 # 정답이니까 +100 점
            # 연속 정답일 때 보너스 점수는 어떻게 구현할까.. -> 보류

            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "correct", "score": room.participants[participant_id]}, room.host_websocket) # True 라는 메세지를 보냄.
            return {"detail": "정답입니다."}
        else: # 오답이면
            # await manager.send_personal_message(f"Participant {participant_id} is wrong", room.host_websocket) # True 라는 메세지를 보냄.
            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "incorrect", "score": room.participants[participant_id]}, room.host_websocket) # True 라는 메세지를 보냄.
            return {"detail": "오답입니다."}
    else:
        raise room_exception()

# 게임방 생성 api
# 호스트 1인당 하나의 방만
@router.post("/create_room")
async def create_room(request: CreateRoomRequest):
    for room in rooms.values():
        if room.host_id == request.host_id:
            raise host_exception1()
    pin_number = create_pin_number()
    #방 생성하기 전에 핀번호가 중복되는지 검사해야할듯.
    rooms[pin_number] = Room(pin_number, request.host_id, request.room_max) # 방 생성

    # custom_problem_set = db.query(CustomProblemSet)\
    # .filter(CustomProblemSet.name == set_name)\
    # .first()

    # custom_problem_sets = db.query(Problems)\
    # .filter(custom_problem_set.id == Problems.cproblem_id)\
    # .all()  

    # result = custom_problem_sets

    return {"detail": "Room created successfully","pin_number": pin_number} # 메세지

# 게임방 참가 api
# 방에 참가한 상태로 다른 방으로 참가하는 것도 막아야됨
@router.post("/join_room")
async def join_room(request: JoinRoomRequest):
    room = rooms.get(request.room_id)
    if not room: # 방이 없으면
        raise room_exception()
    if request.participant_id in room.participants: # 이미 중복된 참여이면
        raise participant_exception1()
    
    if len(room.participants) < room.room_max:
    # room.participants.append(request.participant_id) # 방 리스트에 추가. 
        room.participants[request.participant_id] = 0 # 방 딕셔너리에 참여자 추가 및 초기값 0 설정 
    else:
        return {"message": "Room is full!"}    
    
    # Notify the host if the host is connected
    if room.host_websocket: # 호스트 웹소켓이 존재하고 (= 호스트가 방을 만들고, 웹소켓으로 연결된 상태이면)
        # await ? 뒤의 작업이 완료될 때 까지 대기함. 
        # await manager.send_personal_message(f"Participant {request.participant_id} has joined the room: {request.room_id}", room.host_websocket)
        await manager.send_personal_message({"participant_id": request.participant_id, "joined_room_id": request.room_id}, room.host_websocket)
    return {"message": "Joined room successfully"}

# 웹소켓 : 이미 생성된 room_id 에 클라이언트를 연결 
# join_room 을 안하고, 연결을 바로 해도 연결이 되는 문제 발견
@router.websocket("/ws/{room_id}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str):
    
    room = rooms.get(room_id) # 입력한 room_id 를 가지고 rooms 리스트에서 값을 가져온다. 
    if not room: # 만약 없으면
        await websocket.close(code=1000) # code=1000 ? 을 호출하고 닫음 ?
        return

    if len(room.participants) > room.room_max: # 호스트는 인원수에서 제외 ex. > 2 이면 호스트 포함 3명.
        raise participant_exception2()
    

    if client_id == room.host_id: # 만약 클라이언트가 호스트면, 호스트 웹소켓 ? 에 추가.
        room.host_websocket = websocket
    else: # 호스트가 아니면
        for room in rooms.values(): # 참여자가 허용된 참여자인지 검사
            if client_id in room.participants:
                break
        else:
            await websocket.close(code=1000)
            raise participant_exception3()

    await manager.connect(room_id, client_id, websocket) # await : 연결될 때까지 대기

    try:
        while True: # 무한 루프
            data = await websocket.receive_text() # receive_text() ? 할 때까지 대기 
            message_data = json.loads(data) # 받은 데이터를 json 형태로 ?
            message_text = message_data["message"] # { "message" : 받은 데이터 } ?

            for participant_id, participant_ws in manager.active_connections[room_id].items(): # 연결된 게임방의 아이템 ? 만큼 반복 ?
                if participant_id != client_id: # 참여자 id 와 클라이언트 id가 같지 않으면 (= 자기 자신한테는 메세지 안 보내게 하려고 ? )
                    # await manager.send_personal_message(f"Message from {client_id}: {message_text}", participant_ws) #
                    await manager.send_personal_message({"client_id": client_id, "message": message_text}, participant_ws)
    except WebSocketDisconnect:
        manager.disconnect(room_id, client_id)
        if client_id in room.participants: # 리스트에 참여자가 있다면
            room.participants.pop(client_id) # 참여자 딕셔너리에서 삭제

        if client_id == room.host_id:
            room.host_websocket = None