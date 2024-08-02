import random


def create_pin_number():
    min = 0
    max = 999999
    return '{:06d}'.format(random.randint(min, max))


def list_problems_correct_cnt(test_ox_dict):
    # for key, value in test_ox_dict.items():
    #     print(f"The length of the list for {key} is {len(value)}")
    first_key = next(iter(test_ox_dict))
    # return # 첫번째 키-값 리스트의 개수 len(test_ox_dict[first_key]) # 키의 개수 : len(test_ox_dict)

    result = [0]*len(test_ox_dict[first_key]) # 모든 사람이 푼 문제 수는 같다.
    for key in test_ox_dict:
        temp = 0
        for value in range(0,len(test_ox_dict[first_key])):
            # print(key, value)
            print(key, test_ox_dict[key][value])
            if test_ox_dict[key][value] == 1:
                result[temp] += 1
            temp +=1
        
    return result # [1, 2, 2, 4, 0]

