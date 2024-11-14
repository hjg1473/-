import json
from typing import Dict, List
from fastapi import WebSocket
from pydantic import BaseModel

class Room:
    def __init__(self, room_id: str, host_id: str, room_max: int):
        self.room_id = room_id
        self.host_id = host_id
        self.room_max = room_max
        self.participants_ack: Dict[str, bool] = {} # Check participants' responses before the game starts
        self.InGame = False
        self.InitCountDown = True
        self.participants: Dict[str, int] = {} # For calculating personal scores
        self.participants_bonus: Dict[str, List] = {} # For bonus points calculation
        self.participants_nickname: Dict[str, str] = {} # Nickname is the name shown to the host
        self.participants_websockets = {}  # WebSocket by participants
        self.host_websocket: WebSocket = None 

rooms: Dict[str, Room] = {}

roomProblem: Dict[str, List] = {}

room_settings: Dict = {}

class ProblemSelectionCriteria:
    def __init__(self, season, level, difficulty):
        self.season = season
        self.level = level
        self.difficulty = difficulty

class CreateRoomRequest(BaseModel):
    host_id: str

class JoinRoomRequest(BaseModel):
    room_id: str
    participant_id: str
    participant_name: str

class GetStudentScoreRequest(BaseModel):
    room_id: str
    
class GetGameAgainRequest(BaseModel):
    room_id: str

class ParticipantSolveRequest(BaseModel):
    room_id: str
    participant_id: str
    pnum: int # 0~9

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {} # Active connection dictionary

    async def connect(self, room_id: str, client_id: str, websocket: WebSocket):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        self.active_connections[room_id][client_id] = websocket

    def disconnect(self, room_id: str, client_id: str):
        self.active_connections[room_id].pop(client_id, None)

    async def send_personal_message(self, message: str, websocket: WebSocket): 
        await websocket.send_text(json.dumps(message))
