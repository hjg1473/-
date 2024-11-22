import asyncio
from fastapi import APIRouter, HTTPException
import os
import sys
import json
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from fastapi import File, Form, UploadFile, WebSocket, WebSocketDisconnect
from game.schemas import Room, CreateRoomRequest, JoinRoomRequest, GetStudentScoreRequest, GetGameAgainRequest, ConnectionManager, rooms, roomProblem, ProblemSelectionCriteria, room_settings, ParticipantResultRequest
from game.utils import create_pin_number
from game.exceptions import check_room_exception, check_participant_in_room, check_host_single_room, check_room_existence, check_duplicate_participant, check_room_capacity, check_unregistered_participant, check_room_in_progress
from game.dependencies import db_dependency, user_dependency
from game.service import *
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
    # if room.room_max <= request.room_max: # 같거나 늘리기만 가능
    #     room.room_max = request.room_max 
    # else:
    #     raise room_exception2()
    
    return {"pin_number": request.room_id} 

# Requests all scores of participants (sorted in descending order)
@router.post("/super/student_score")
async def get_student_score(request: GetStudentScoreRequest):
    room = rooms.get(request.room_id)
    check_room_exception(room)
    sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True))
    return sorted_rank

# Requests all scores of participants (sorted in descending order)
@router.post("/student_score")
async def get_student_score(request: ParticipantResultRequest):
    room = rooms.get(request.room_id)
    # check_room_exception(room)
    sorted_rank = dict(sorted(room.participants.items(), key=lambda item: item[1], reverse=True))
    participant_answer_list = room.participants_bonus[request.participant_id]
    count_of_ones = participant_answer_list.count(1)
    return { "rank": sorted_rank, "count": count_of_ones }

# When a student solves a problem
@router.post("/student_solve")
async def participant_action(
        room_id: str = Form(...),
        participant_id: str = Form(...),
        pnum: int = Form(...),  # Problem Number
        file: UploadFile = File(...)):
    
    room = rooms.get(room_id)
    check_room_exception(room)  
    check_participant_in_room(participant_id, room.participants) 
    participant_websocket = room.participants_websockets.get(participant_id)

    if not room.host_websocket:
        check_room_exception(room)
    
    answer = roomProblem[room_id][pnum]
    from app.src.problem.router import ocr
    word_list = await ocr(file)
    user_string = ' '.join(word_list)

    # Check the correct answer and set the result message
    answer_status = await check_answer(room, participant_id, pnum, user_string, answer)
    response_message = {"participant_id": participant_id, "isAnswer": answer_status, 
                        "score": room.participants[participant_id]}

    await manager.send_personal_message(response_message, participant_websocket)
    return {"ocr_result": user_string}


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

@router.websocket("/ws/{room_id}/{client_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, client_id: str, db: db_dependency):
    room = rooms.get(room_id)
    
    if not await validate_room(room, websocket):
        return

    if not await validate_client(client_id, room, websocket):
        return

    await setup_connection(client_id, room, room_id, websocket)

    name = room.participants_nickname.get(client_id, "Unknown")

    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            await handle_message(message_data, client_id, room_id, name, db)
    except WebSocketDisconnect:
        await handle_disconnect(client_id, room_id, room, name)

