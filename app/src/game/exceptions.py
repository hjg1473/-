from fastapi import HTTPException


def room_exception(room):
    if not room:  # 방이 없으면
        raise HTTPException(status_code=404, detail="Not found")

def participant_exception(participant_id, room_participants):
    if participant_id not in room_participants:  # 방에 참여자가 없으면
        raise HTTPException(status_code=404, detail="Participant not in the room")

def participant_exception1(participant_id, participants):
    if participant_id in participants: # 이미 중복된 참여이면
        raise HTTPException(status_code=404, detail="이미 방에 참가하였습니다.")

def participant_exception2(participants_len, room_max):
    if participants_len > room_max: 
        raise HTTPException(status_code=404, detail="방 인원이 초과되었습니다.")

def participant_exception3():
    return HTTPException(status_code=400, detail="미등록된 참여자입니다.")

def participant_exception4():
    return HTTPException(status_code=404, detail="Room is full!")

def host_exception():
    return HTTPException(status_code=404, detail="host not in the room")

def host_exception1(room_list, host_id):
    for room in room_list:
        if room.host_id == host_id:
            raise HTTPException(status_code=400, detail="호스트는 하나의 방만 가질 수 있습니다.")

def host_exception2(room_list, pin_number):
    for room in room_list:
        if room.room_id == pin_number:
            return True
        else:
            return False