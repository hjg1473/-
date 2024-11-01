import random


def create_pin_number():
    min = 0
    max = 999999
    return '{:06d}'.format(random.randint(min, max))

# Example for list_problems_correct_cnt 
"""
test_ox_dict = {
    "Alice": [1, 0, 1, 1, 0],
    "Bob": [1, 1, 0, 1, 0],
    "Charlie": [0, 1, 1, 1, 0],
    "David": [1, 0, 0, 1, 0]
}

The correct answer for each question is as follows:

    First question: Alice, Bob and David (three correct)
    Second question: Bob, Charlie (2 correct)
    Third question: Alice, Charlie (2 correct)
    Fourth question: Alice, Bob, Charlie, David (four correct)
    fifth question: No one got it right (0 people got it right)

    The result is [3, 2, 2, 4, 0].

"""
def list_problems_correct_cnt(test_ox_dict):
    first_key = next(iter(test_ox_dict))
    result = [0]*len(test_ox_dict[first_key]) 
    # Counting the number of correct questions
    for key in test_ox_dict:
        temp = 0
        for value in range(0,len(test_ox_dict[first_key])):
            print(key, test_ox_dict[key][value])
            if test_ox_dict[key][value] == 1:
                result[temp] += 1
            temp +=1
        
    return result

