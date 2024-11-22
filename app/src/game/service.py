import asyncio
import random
import os
import sys
from sqlalchemy import func, select
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))
from app.src.models import Problems
from game.constants import PROBLEM_OFFSET, PROBLEM_COUNT, GAME_POINT
from game.schemas import rooms, roomProblem, ProblemSelectionCriteria, room_settings, ConnectionManager
from game.exceptions import check_room_capacity, check_unregistered_participant
from game.utils import release_pin_number

manager = ConnectionManager()

# A dictionary that stores the ID of the question already asked for each room
used_problem_ids = {}  # {room_id: set(problem_ids)}

def initialize_used_problems_in_room(room_id: str):
    if room_id not in used_problem_ids:
        used_problem_ids[room_id] = set()

def clear_used_problems_in_room(room_id: str):
    if room_id in used_problem_ids:
        del used_problem_ids[room_id]

async def select_random_problems(criteria: ProblemSelectionCriteria, db, room_id: str):
    initialize_used_problems_in_room(room_id)

    # Count, except for the question ID that has already been asked
    total_count = await db.scalar(
        select(func.count()).select_from(Problems)
        .filter(Problems.level == criteria.level)
        .filter(Problems.season == criteria.season)
        .filter(Problems.difficulty == criteria.difficulty)
        .filter(Problems.type == "ai")
        .filter(~Problems.id.in_(used_problem_ids[room_id]))  # Avoid duplication
    )

    # Return error if no problem exists
    if total_count == 0:
        return []

    # Random offset setting (set to import as much as PROBLEM_OFFSET)
    random_offset = random.randint(0, max(0, total_count - PROBLEM_OFFSET))

    result = await db.execute(
        select(Problems)
        .filter(Problems.level == criteria.level)
        .filter(Problems.season == criteria.season)
        .filter(Problems.difficulty == criteria.difficulty)
        .filter(Problems.type == "ai")
        .filter(~Problems.id.in_(used_problem_ids[room_id]))  # Avoid duplication
        .offset(random_offset)
        .limit(PROBLEM_OFFSET)
    )

    random_problems = result.scalars().all()

    # Choose n problems at random (MAX - PROBLEM_COUNT)
    final_problems = random.sample(random_problems, min(PROBLEM_COUNT, len(random_problems)))

    # Add the selected problem ID to the room's history
    used_problem_ids[room_id].update(problem.id for problem in final_problems)

    return final_problems


async def check_answer(room, participant_id, pnum, user_string, answer):
    if user_string == answer:
        room.participants[participant_id] += GAME_POINT
        room.participants_bonus[participant_id].append(1)  # Add a record of correct answers
        
        # Add bonus points for 3 consecutive correct answers
        if pnum >= 2 and all(room.participants_bonus[participant_id][i] == 1 for i in range(pnum-2, pnum+1)):
            room.participants[participant_id] += GAME_POINT

        return "correct"
    else:
        room.participants_bonus[participant_id].append(0)  # Add a record of incorrect answers
        return "incorrect"

async def check_non_ack_participants_after_delay(room_id):
    room = rooms.get(room_id)
    isMissing_key = False
    # Execute after waiting 10 seconds
    await asyncio.sleep(10)

    missing_keys = set(room.participants.keys()) - set(room.participants_ack.keys())
    if missing_keys:
        isMissing_key = True 

    # Remove participants who did not receive ack.
    for client_id in missing_keys:
        websocket = room.participants_websockets.get(client_id)
        manager.disconnect(room_id, client_id)
        if websocket:
            await websocket.close(code=1000) 
        room.participants.pop(client_id, None)
        room.participants_ack.pop(client_id, None)
        room.participants_bonus.pop(client_id, None)
        room.participants_nickname.pop(client_id, None)
        # del room.participants_bonus[client_id]
        # del room.participants_nickname[client_id]

    # Send message to all participants
    if isMissing_key:
        for participant_id, participant_ws in manager.active_connections[room_id].items():
            if participant_id != room.host_id:  # Do not send to host.
                await manager.send_personal_message({
                    "message": "startCountDown"
                }, participant_ws)
    return

async def send_problems_all_participants(message, start_index, final_problems, room_id, duration):
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
        # if participant_id != room.host_id:  # Do not send to host.
        if message == "GameStart":
            await manager.send_personal_message({
                "message": message,
                "duration": duration,
                "problems": problems
                # "problems": json.dumps(problems, ensure_ascii=False) # 한글 디코딩
            }, participant_ws)
        else:
            await manager.send_personal_message({
                "message": message,
                "problems": problems
                # "problems": json.dumps(problems, ensure_ascii=False) # 한글 디코딩
            }, participant_ws)

            
async def validate_room(room, websocket):
    if not room:
        await websocket.close(code=1000)
        return False
    return True

async def validate_client(client_id, room, websocket):
    if client_id == room.host_id:
        room.host_websocket = websocket
    else:
        if not any(client_id in r.participants for r in rooms.values()):
            await websocket.close(code=1000)
            raise check_unregistered_participant()
        room.participants_websockets[client_id] = websocket
    return True


async def setup_connection(client_id, room, room_id, websocket):
    check_room_capacity(len(room.participants), room.room_max)
    await manager.connect(room_id, client_id, websocket)


async def handle_message(message_data, client_id, room_id, name, db):
    message_text = message_data.get("message")
    level, difficulty, season, problemNumber, duration = (
        message_data.get("level"),
        message_data.get("difficulty"),
        message_data.get("season"),
        message_data.get("problemNumber"),
        message_data.get("duration")
    )

    room = rooms[room_id]

    if message_text == "Ack":
        """The purpose of the host sending the problem 
            and responding that students received it well 
            when they received it"""
        room.participants_ack[client_id] = True
        await manager.send_personal_message({"client_id": client_id, "message": message_text, "name": name}, room.host_websocket)
    elif message_text == "ResetAck": # Temp Action
        reset_ack(room)
    elif message_text == "GameStart" and client_id == room.host_id:
        """Send questions to students"""
        await start_game(room_id, level, difficulty, season, duration, db)
    elif message_text == "MoreProblems":
        """If one of the students has solved all the sent questions with 5 left, 
            the teacher asks for additional questions."""
        await add_more_problems(room_id, problemNumber, db)
    else:
        await broadcast_message(room_id, client_id, message_text, name)

    # 로컬에선 되는데 ?
    if all_ack_received(room) and room.InitCountDown:
        await trigger_countdown(room_id)
        room.InitCountDown = False


async def start_game(room_id, level, difficulty, season, duration, db):
    room_settings[room_id] = {"level": level, "difficulty": difficulty, "season": season}
    criteria = ProblemSelectionCriteria(season, level, difficulty)
    problems = await select_random_problems(criteria, db, room_id)

    roomProblem[room_id] = {}
    # Block participation in Game 
    room = rooms.get(room_id)
    room.InGame = True 
    await send_problems_all_participants("GameStart", 0, problems, room_id, duration)
    asyncio.create_task(check_non_ack_participants_after_delay(room_id))


async def add_more_problems(room_id, problemNumber, db):
    criteria = ProblemSelectionCriteria(
        room_settings[room_id]["season"],
        room_settings[room_id]["level"],
        room_settings[room_id]["difficulty"]
    )
    problems = await select_random_problems(criteria, db, room_id)

    if room_id not in roomProblem:
        roomProblem[room_id] = {}
    
    start_index = len(roomProblem[room_id])

    if start_index - (problemNumber or 0) <= 5:
        await send_problems_all_participants("MoreProblems", start_index, problems, room_id, -1)


async def broadcast_message(room_id, client_id, message_text, name):
    for participant_id, participant_ws in manager.active_connections[room_id].items():
        if participant_id != client_id:
            await manager.send_personal_message(
                {"client_id": client_id, "message": message_text, "name": name},
                participant_ws
            )

async def trigger_countdown(room_id):
    room = rooms[room_id]
    for participant_id, participant_ws in manager.active_connections[room_id].items():
        if participant_id != room.host_id:
            # Students who receive this message will start counting down before the game starts.
            await manager.send_personal_message({"message": "startCountDown"}, participant_ws)


async def handle_disconnect(client_id, room_id, room, name):
    if client_id != room.host_id:
        await manager.send_personal_message({"disconnect_room": room_id, "client_id": client_id, "name": name}, room.host_websocket)
    
    manager.disconnect(room_id, client_id)
    
    if client_id in room.participants:
        room.participants.pop(client_id)
        del room.participants_bonus[client_id]
        del room.participants_nickname[client_id]
    
    if client_id == room.host_id:
        release_pin_number(room_id)
        del rooms[room_id]
        clear_used_problems_in_room(room_id)

def reset_ack(room):
    room.participants_ack.clear()


def all_ack_received(room):
    return len(room.participants) == len(room.participants_ack)
