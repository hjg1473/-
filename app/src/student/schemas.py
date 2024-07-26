from pydantic import BaseModel


class PinNumber(BaseModel):
    pin_number: int