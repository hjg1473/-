from fastapi import HTTPException

def http_exception():
    return HTTPException(status_code=404, detail="Not found")