from fastapi import  HTTPException, status

def successful_response(status_code: int):
    return {
        'status': status_code,
        'transaction': 'Successful'
    }

def http_exception():
    return HTTPException(status_code=404, detail="Not found")

def get_user_exception(user):
    if user is None:
        raise HTTPException(status_code=404, detail="Could not validate credentials")

def get_studyInfo_exception(correct_count, incorrect_count):
    if correct_count + incorrect_count == 0:
        raise HTTPException(status_code=404, detail='학습 기록이 없습니다.')

def get_problem_exception(stepinfo_model):
    if stepinfo_model is None:
        raise HTTPException(status_code=404, detail='문제 데이터가 존재하지 않습니다.')
    
def get_season_exception(Released_model):
    if Released_model is None:
        raise HTTPException(status_code=404, detail='해당 시즌이 없습니다.')

def get_studyStart_exception(studyStart_timestamp):
    if studyStart_timestamp is None: #
        raise HTTPException(status_code=404, detail="학습을 시작하지 않았습니다.")
    
def get_doubleEnd_exception(studyStart_timestamp, recent_studyEnd_timestamp):
    if studyStart_timestamp < recent_studyEnd_timestamp:
        raise HTTPException(status_code=400, detail="중복된 학습 종료 호출입니다.")