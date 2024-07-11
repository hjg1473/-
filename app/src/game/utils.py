import random


def create_pin_number():
    min = 0
    max = 999999
    return '{:06d}'.format(random.randint(min, max))
