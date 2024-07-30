from pydantic import BaseModel


class PinNumber(BaseModel):
    pin_number: int

class SoloGroup(BaseModel):
    mode: str # solo , group