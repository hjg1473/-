import random
from fastapi import APIRouter
import os
import sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from fastapi import File, Form, UploadFile, WebSocket, WebSocketDisconnect
import json
from game.schemas import Room, CreateRoomRequest, JoinRoomRequest, GetStudentScoreRequest, GetGameAgainRequest, ConnectionManager, rooms, roomProblem
from game.utils import create_pin_number, list_problems_correct_cnt
from game.exceptions import room_exception, participant_exception, host_exception, host_exception1, host_exception2, participant_exception1, participant_exception2, participant_exception3, participant_exception4, room_exception2
from game.dependencies import db_dependency
from game.service import select_random_problems

router = APIRouter(
    prefix="/game",
    tags=["game"],
    responses={404: {"description": "Not found"}}
)

manager = ConnectionManager()

# @router.post("/result")
# async def participant_action(room_id: str, client_id: str):
#     room = rooms.get(room_id)
#     room_exception(room)
#     cnt = 0
#     rank_cnt = 0
#     if client_id == room.host_id: # 호스트일 때
#         return {'result':list_problems_correct_cnt(room.participants_bonus)}
#     else: # 학생 개인의 결과
#         participant_exception(client_id, room.participants)
#         for value in room.participants_bonus[client_id]:
#             if value == 1: # 맞은 문제 수
#                 cnt += 1 

#         sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True)) # 
#         for key in sorted_rank:
#             rank_cnt += 1
#             if key == client_id:
#                 self_rank = rank_cnt
#                 break

#         return {"rank": self_rank, "score": room.participants[client_id], "correct_problems": cnt}


def reset_room(room: Room) -> None:
    for participant in room.participants:
        room.participants[participant] = 0 # 참여자 리스트의 값만 0으로 초기화
        room.participants_bonus[participant] = [] # 참여자 문제 정답 배열 초기화
    room.InGame = False #인게임 아님

# 같은 인원, 같은 핀번호로 게임 이어서 하기 + 추가 입장도 되도록
@router.post("/super/game_again")
async def get_student_score(db: db_dependency, request: GetGameAgainRequest):
    room = rooms.get(request.room_id)
    room_exception(room)
    reset_room(room)
    if room.room_max <= request.room_max: # 인원 같거나 늘리기만 가능
        room.room_max = request.room_max 
    else:
        raise room_exception2()
    
    final_problems = await select_random_problems(request.choiceLevel,request.problemsCount, db)

    problems = []
    pnum = 0
    roomProblem[request.room_id] = {}
    for problem in final_problems:
        problems.append({"problem_id": problem.id, "koreaProblem": problem.koreaProblem})
        roomProblem[request.room_id][pnum] = problem.englishProblem
        pnum += 1
    return {"pin_number": request.room_id, "problems": problems} 

# 게임방 호스트가 참여자의 모든 누적 점수 요청 (내림차순 정렬)
@router.post("/super/student_score")
async def get_student_score(request: GetStudentScoreRequest):
    room = rooms.get(request.room_id)
    room_exception(room)
    sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True))
    return sorted_rank

# Top3 유저 이름 출력
# @router.post("/super/ranking_top3")
# async def get_student_score(request: GetStudentScoreRequest):
#     room = rooms.get(request.room_id)
#     room_exception(room)
#     sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True))
#     sorted_rank_list = list(sorted_rank.keys())
#     result = {}
#     if len(sorted_rank_list) >= 1:
#         result["1등"] = sorted_rank_list[0]
#     if len(sorted_rank_list) >= 2:
#         result["2등"] = sorted_rank_list[1] 
#     if len(sorted_rank_list) >= 3:
#         result["3등"] = sorted_rank_list[2]
#     return result

# 선생님이 게임 시작할 때, 시작 후 참여 방어 안됨
@router.post("/super/game_start")
async def participant_action(request: GetStudentScoreRequest):
    room = rooms.get(request.room_id)
    room_exception(room)
    if room.host_websocket:
        room.InGame = True
        for participant_id, participant_ws in manager.active_connections[request.room_id].items(): # 이렇게 써도 되는지 모르겠네 gpt는 된다는데
                await manager.send_personal_message({"client_id": participant_id, "message": "GameStart"}, participant_ws)
    else:
        raise host_exception()

# 게임에서 학생이 정답을 제출할 때
@router.post("/student_solve")
async def participant_action(room_id: str = Form(...),
        participant_id: str = Form(...),
        pnum: int = Form(...), # 몇번째 문제인지? 0부터 시작. 이 부분 조금 보완
        file: UploadFile = File(...)):
    
    room = rooms.get(room_id)
    room_exception(room)
    participant_exception(participant_id, room.participants)
    if room.host_websocket:
        answer = roomProblem[room_id][pnum]
        from app.src.problem.router import ocr
        word_list = await ocr(file)
        user_string = ' '.join(word_list)

        if user_string != answer: # 정답이면 == 으로 고치기.
            # await manager.send_personal_message(f"Participant {participant_id} is right", room.host_websocket) # True 라는 메세지를 보냄.
            room.participants[participant_id] += 100 # 정답이니까 +100 점
            room.participants_bonus[participant_id].append(1) # 정답이면 1
            if pnum >= 2:
                if room.participants_bonus[participant_id][pnum] == 1\
                and room.participants_bonus[participant_id][pnum-1] == 1\
                and room.participants_bonus[participant_id][pnum-2] == 1:
                    room.participants[participant_id] += 100 # 100점 추가 

            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "correct", "score": room.participants[participant_id]}, room.host_websocket) # True 라는 메세지를 보냄.
            return {"detail": "정답입니다."}
        else: # 오답이면
            room.participants_bonus[participant_id].append(0) # 오답이면 0
            # await manager.send_personal_message(f"Participant {participant_id} is wrong", room.host_websocket) # False 라는 메세지를 보냄.
            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "incorrect", "score": room.participants[participant_id]}, room.host_websocket) # True 라는 메세지를 보냄.
            return {"detail": "오답입니다."}
    else:
        raise room_exception(room)

# 게임방 생성 api
# 호스트 1인당 하나의 방만
@router.post("/create_room")
async def create_room(db: db_dependency, request: CreateRoomRequest):
    host_exception1(rooms.values(), request.host_id)
    pin_number = create_pin_number()
    # 핀 번호 중복 검사
    if host_exception2(rooms.values(), pin_number):
        pin_number = create_pin_number()
    rooms[pin_number] = Room(pin_number, request.host_id, request.room_max) # 방 생성

    # final_problems = await select_random_problems(request.choiceLevel, request.problemsCount, db)

    # problems = []
    # pnum = 0
    # roomProblem[pin_number] = {}
    # for problem in final_problems:
    #     problems.append({"problem_id": problem.id, "englishProblem":problem.englishProblem ,"koreaProblem": problem.koreaProblem})
    #     roomProblem[pin_number][pnum] = problem.englishProblem
    #     pnum += 1

    return {"pin_number": pin_number}
    # return {"pin_number": pin_number, "problems": problems} 


# 게임방 참가 api
# 방에 참가한 상태로 다른 방으로 참가하는 것도 막아야됨 + 중도 참가도 막아야됨
@router.post("/join_room")
async def join_room(request: JoinRoomRequest):
    room = rooms.get(request.room_id)
    
    room_exception(room)
    participant_exception1(request.participant_id, room.participants)
    participant_exception2(len(room.participants), room.room_max)
    participant_exception4(room.InGame)

    room.participants[request.participant_id] = 0 # 방 딕셔너리에 참여자 추가 및 초기값 0 설정 
    room.participants_bonus[request.participant_id] = []
    
    if room.host_websocket:
        await manager.send_personal_message({"participant_id": request.participant_id, "joined_room_id": request.room_id}, room.host_websocket)
    return {"detail": "Joined room successfully"}

# 웹소켓 : 이미 생성된 room_id 에 클라이언트를 연결 
@router.websocket("/ws/{room_id}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str, db: db_dependency):
    room = rooms.get(room_id) # 입력한 room_id 를 가지고 rooms 리스트에서 값을 가져온다. 
    if not room: # 만약 없으면
        await websocket.close(code=1000) # code=1000 ? 을 호출하고 닫음 ?
        return

    participant_exception2(len(room.participants), room.room_max)

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
            message_data = json.loads(data) # 받은 데이터를 json 형태로 

            message_text = message_data.get("message") # { "message" : 받은 데이터 }
            choiceLevel = message_data.get("choiceLevel") # {"choiceLevel" : 2}
            problemsCount = message_data.get("problemsCount") # {"problemsCount" : 3}

            # "GameStart" 메시지를 보낼 때, 학생들에게 문제 데이터를 전송
            if message_text == "GameStart" and client_id == room.host_id:  # " GameStart" 메시지를 받았을 때
                # 학생 DB에서 문제 데이터를 가져옴
                final_problems = await select_random_problems(choiceLevel, problemsCount, db)
                problems = []
                roomProblem[room_id] = {}

                for pnum, problem in enumerate(final_problems):
                    problems.append({"problem_id": problem.id, "koreaProblem": problem.koreaProblem})
                    roomProblem[room_id][pnum] = problem.englishProblem  # 문제 저장

                # 학생들에게 문제 전송
                for participant_id, participant_ws in manager.active_connections[room_id].items():
                    if participant_id != client_id:  # 호스트 자신에게는 전송하지 않음
                        await manager.send_personal_message({
                            "message": "GameStart",
                            "problems": problems
                            # "problems": json.dumps(problems, ensure_ascii=False) # 한글 디코딩이 포스트맨에서 안되서
                        }, participant_ws)

            for participant_id, participant_ws in manager.active_connections[room_id].items(): # 연결된 게임방의 아이템 ? 만큼 반복 ?
                if participant_id != client_id: # 참여자 id 와 클라이언트 id가 같지 않으면 (= 자기 자신한테는 메세지 안 보내게 하려고 ? )
                    # await manager.send_personal_message(f"Message from {client_id}: {message_text}", participant_ws)
                    await manager.send_personal_message({"client_id": client_id, "message": message_text}, participant_ws)

    except WebSocketDisconnect:
        manager.disconnect(room_id, client_id)
        await manager.send_personal_message({"disconnect_room": room_id, "client_id": client_id}, room.host_websocket)
        if client_id in room.participants: # 리스트에 참여자가 있다면
            room.participants.pop(client_id) # 참여자 딕셔너리에서 삭제
            del room.participants_bonus[client_id] # 보너스 점수도 삭제d
        if client_id == room.host_id:
            room.host_websocket = None