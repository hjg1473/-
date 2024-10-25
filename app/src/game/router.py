import asyncio
from fastapi import APIRouter, HTTPException
import os
import sys
import json
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from fastapi import File, Form, UploadFile, WebSocket, WebSocketDisconnect
from game.schemas import Room, CreateRoomRequest, JoinRoomRequest, GetStudentScoreRequest, GetGameAgainRequest, ConnectionManager, rooms, roomProblem, ProblemSelectionCriteria, room_settings
from game.utils import create_pin_number
from game.exceptions import check_room_exception, check_participant_in_room, check_host_single_room, check_room_existence, check_duplicate_participant, check_room_capacity, check_unregistered_participant, check_room_in_progress, room_exception2
from game.dependencies import db_dependency, user_dependency
from game.service import select_random_problems, clear_used_problems_in_room
from game.constants import GAME_POINT, MAX_STUDENT
from app.src.models import ReleasedGroup
from sqlalchemy import select
from starlette.websockets import WebSocketState

router = APIRouter(
    prefix="/game",
    tags=["game"],
    responses={404: {"description": "Not found"}}
)

manager = ConnectionManager()

@router.post("/socket_close")
async def socket_close():

    for room_id in list(rooms.keys()): 
        room = rooms[room_id]

        if room.host_websocket:
            try:
                if room.host_websocket.client_state != WebSocketState.DISCONNECTED:
                    await room.host_websocket.close()
            except RuntimeError as e:
                print(f"Host Websocket close error: {e}")
        
        del rooms[room_id]

    return {"detail": "모든 소켓 삭제됨"}

def reset_room(room: Room) -> None:
    for participant in room.participants:
        room.participants[participant] = 0 # Reset score
        room.participants_bonus[participant] = []
    room.InGame = False 

# Get group managed by the teacher.
@router.get("/group")
async def read_group_info(user: user_dependency, db: db_dependency):
    from super.exceptions import validate_super_user_role
    validate_super_user_role(user)
    from super.service import fetch_group_list
    group_list = await fetch_group_list(user.get("id"), db)
    result = {'groups': [{'id': u.id, 'name': u.name} for u in group_list]}
    return result

# Check group info
@router.get("/group/{group_id}/info")
async def read_group_info(group_id:int, user:user_dependency, db:db_dependency):
    from super.exceptions import validate_super_user_role, validate_group_access, find_group_exception
    validate_super_user_role(user)
    await validate_group_access(user.get("id"), group_id, db)
    await find_group_exception(group_id, db)
    
    result = await db.execute(select(ReleasedGroup).filter(ReleasedGroup.owner_id == group_id))
    target_season = result.scalars().all()
    # Remove id, owner_id 
    for item in target_season:
        del item.id
        del item.owner_id

    return target_season

# Continue the game with the same number of people and the same pin number.
@router.post("/super/game_again")
async def get_student_score(db: db_dependency, request: GetGameAgainRequest):
    room = rooms.get(request.room_id)
    check_room_exception(room)
    reset_room(room)
    if room.room_max <= request.room_max: # 같거나 늘리기만 가능
        room.room_max = request.room_max 
    else:
        raise room_exception2()
    
    return {"pin_number": request.room_id} 

# Requests all scores of participants (sorted in descending order)
@router.post("/super/student_score")
async def get_student_score(request: GetStudentScoreRequest):
    room = rooms.get(request.room_id)
    check_room_exception(room)
    sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True))
    return sorted_rank

# When a student submits the correct answer in the game
@router.post("/student_solve")
async def participant_action(room_id: str = Form(...),
        participant_id: str = Form(...),
        pnum: int = Form(...), # What number is the problem? (ex. 0, 1, 2 ...)
        file: UploadFile = File(...)):
    
    room = rooms.get(room_id)
    check_room_exception(room)
    check_participant_in_room(participant_id, room.participants)
    participant_websocket = room.participants_websockets.get(participant_id)

    if room.host_websocket:
        answer = roomProblem[room_id][pnum]
        from app.src.problem.router import ocr
        word_list = await ocr(file)
        user_string = ' '.join(word_list)

        if user_string == answer:
            room.participants[participant_id] += GAME_POINT
            room.participants_bonus[participant_id].append(1) 
            if pnum >= 2: # If you answer correctly 3 times in a row, GAME_POINT points are added.
                if room.participants_bonus[participant_id][pnum] == 1\
                and room.participants_bonus[participant_id][pnum-1] == 1\
                and room.participants_bonus[participant_id][pnum-2] == 1:
                    room.participants[participant_id] += GAME_POINT

            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "correct", 
                                                "score": room.participants[participant_id]}, participant_websocket)
            return {"detail": "정답입니다."}
        else: # If you get it wrong, you get no points.
            room.participants_bonus[participant_id].append(0) 
            await manager.send_personal_message({"participant_id": participant_id, "isAnswer": "incorrect",
                                                "score": room.participants[participant_id]}, participant_websocket)
            return {"detail": "오답입니다."}
    else:
        raise check_room_exception(room)


# Create Game Room
@router.post("/create_room")
async def create_room(request: CreateRoomRequest):
    check_host_single_room(rooms.values(), request.host_id)
    pin_number = create_pin_number()
    # Check if there is a room created with that pin number
    if check_room_existence(rooms.values(), pin_number):
        pin_number = create_pin_number()
    rooms[pin_number] = Room(pin_number, request.host_id, MAX_STUDENT) 

    return {"pin_number": pin_number}


# Join Game Room
@router.post("/join_room")
async def join_room(request: JoinRoomRequest):
    room = rooms.get(request.room_id)
    # exception
    check_room_exception(room)
    check_duplicate_participant(request.participant_id, room.participants)
    check_room_capacity(len(room.participants), room.room_max) 
    check_room_in_progress(room.InGame)
    # init
    room.participants[request.participant_id] = 0 
    room.participants_bonus[request.participant_id] = []
    room.participants_nickname[request.participant_id] = request.participant_name

    # It's not actually included, but since it's difficult to pass it through a websocket, 
    # it's replaced in the corresponding function.
    if room.host_websocket:
        await manager.send_personal_message({"participant_id": request.participant_id, 
                                             "participant_name" : request.participant_name,
                                            "joined_room_id": request.room_id}, room.host_websocket)
        
    return {"detail": "Joined room successfully"}


async def send_problems_all_participants(message, start_index, final_problems, room_id):
    # No more problem
    if isinstance(final_problems, str):
        for participant_id, participant_ws in manager.active_connections[room_id].items():
            await manager.send_personal_message({
                "message": final_problems
            }, participant_ws)
        return
    room = rooms.get(room_id)
    problems = []
    for pnum, problem in enumerate(final_problems, start=start_index):
        problems.append({"problem_id": problem.id, "koreaProblem": problem.koreaProblem})
        roomProblem[room_id][pnum] = problem.englishProblem 
    # Send message to all participants
    for participant_id, participant_ws in manager.active_connections[room_id].items():
        if participant_id != room.host_id:  # Do not send to host.
            await manager.send_personal_message({
                "message": message,
                "problems": problems
                # "problems": json.dumps(problems, ensure_ascii=False) # 한글 디코딩이 포스트맨에서 안되서
            }, participant_ws)

# Websocket
@router.websocket("/ws/{room_id}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str, db: db_dependency):
    room = rooms.get(room_id)  
    if not room:
        await websocket.close(code=1000) 
        return

    check_room_capacity(len(room.participants), room.room_max)

    if client_id == room.host_id: 
        room.host_websocket = websocket
    else:
        # Check if the client is a participant in any room
        if not any(client_id in r.participants for r in rooms.values()):
            await websocket.close(code=1000)
            raise check_unregistered_participant()
        room.participants_websockets[client_id] = websocket

    await manager.connect(room_id, client_id, websocket) 
    name = room.participants_nickname.get(client_id, "Unknown")

    try:
        while True: 
            data = await websocket.receive_text()
            # JSON Parsing 
            message_data = json.loads(data) 
            message_text = message_data.get("message") 
            level = message_data.get("level") 
            difficulty = message_data.get("difficulty")
            season = message_data.get("season") 
            problemNumber = message_data.get("problemNumber")
            
            # When sending a "GameStart" message, problem data is sent to students.
            if message_text == "GameStart" and client_id == room.host_id:  
                room_settings[room_id] = {
                    "level": level,
                    "difficulty": difficulty,
                    "season": season
                }
                
                criteria = ProblemSelectionCriteria(
                    room_settings[room_id]["season"],
                    room_settings[room_id]["level"],
                    room_settings[room_id]["difficulty"]
                )
                final_problems = await select_random_problems(criteria, db, room_id)
                
                roomProblem[room_id] = {}
                await send_problems_all_participants("GameStart", 0, final_problems, room_id)
            # Add problem (When 5 problems remain)
            elif message_text == "MoreProblems":
                criteria = ProblemSelectionCriteria(
                    room_settings[room_id]["season"],
                    room_settings[room_id]["level"],
                    room_settings[room_id]["difficulty"]
                )
                final_problems = await select_random_problems(criteria, db, room_id)

                if room_id not in roomProblem:
                    roomProblem[room_id] = {}   
                # Check the number of problems already saved
                start_index = len(roomProblem[room_id]) 

                lock = asyncio.Lock()
                async with lock:
                    if start_index - (problemNumber or 0) <= 5: # Not Null
                        await send_problems_all_participants("MoreProblems", start_index, final_problems, room_id)
            else:
                for participant_id, participant_ws in manager.active_connections[room_id].items():
                    if participant_id != client_id: 
                        await manager.send_personal_message({"client_id": client_id, "message": message_text, "name": name}, participant_ws)

    except WebSocketDisconnect: # Disconnect == Delete 
        if client_id != room.host_id:
            await manager.send_personal_message({"disconnect_room": room_id, "client_id": client_id, "name": name}, room.host_websocket)
        manager.disconnect(room_id, client_id)
        if client_id in room.participants: 
            room.participants.pop(client_id) 
            del room.participants_bonus[client_id]
            del room.participants_nickname[client_id]
        if client_id == room.host_id:
            del rooms[room_id] 
            clear_used_problems_in_room(room_id) 
