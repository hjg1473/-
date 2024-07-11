from fastapi import HTTPException


def room_exception():
    return HTTPException(status_code=404, detail="Not found")

def participant_exception():
    return HTTPException(status_code=404, detail="Participant not in the room")

def participant_exception1():
    return HTTPException(status_code=404, detail="이미 방에 참가하였습니다.")

def participant_exception2():
    return HTTPException(status_code=404, detail="방 인원이 초과되었습니다.")

def participant_exception3():
    return HTTPException(status_code=400, detail="미등록된 참여자입니다.")

def host_exception():
    return HTTPException(status_code=404, detail="host not in the room")

def host_exception1():
    HTTPException(status_code=400, detail="호스트는 하나의 방만 가질 수 있습니다.")
