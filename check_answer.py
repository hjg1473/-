def check(problem, response):
    pLen = len(problem)
    rLen = len(response)

    expResponse = response.copy()
    if rLen < pLen:
        expResponse += [''] * (pLen - rLen)
    
    erLen = len(expResponse)
    problem_copy = problem.copy()

    # starts with all Red.
    false_check = ['Red'] * erLen

    # check green -- correct answer. If one word is already checked, than it will never be checked again.
    for i in range(pLen):
        if problem[i] == expResponse[i]:
            false_check[i] = 'Green'
            problem_copy[i] = 0
    
    # check yellow -- 
    for i in expResponse:
        if i in problem_copy:
            false_check[expResponse.index(i)] = 'Yellow'
            problem_copy[problem_copy.index(i)] = 0

    
    print(response)
    print(false_check)
    return false_check
    


if __name__ == "__main__":
    testP1 = ['I', 'am', 'pretty', '.']
    
    # 개수가 맞는 경우
    # 정답인 경우
    testR0 = ['I', 'am', 'pretty', '.']

    # 순서가 일부 틀린 경우
    testR1 = ['I', 'pretty', 'am', '.']

    # 순서가 모두 틀린 경우
    testR2 = ['pretty', 'I', '.', 'am']

    # 같은 단어가 여러번 나올 경우
    testR3 = ['am', 'I', 'am', '.']
    testR3p = ['am', 'am', 'am', 'am']

    # 일부 순서가 틀리고 어떤건 아예 틀렸을 경우
    testR4 = ['am', 'I', '?', 'pretty']

    # 틀린거 2개 이상
    # 전부 틀린 경우
    testR5 = ['Is', 'this', 'work', '?']
    # 전부는 아닌 경우
    testR6 = ['I', 'is', 'good', ',']
    testR7 = ['I', 'is', 'king', '.']
    check(testP1, testR0)
    check(testP1, testR1)
    check(testP1, testR2)
    check(testP1, testR3)
    check(testP1, testR4)
    check(testP1, testR5)
    check(testP1, testR6)
    check(testP1, testR7)
    check(testP1, testR3p)

    # 개수가 틀린 경우
    testR0 = ['I', 'pretty', '.']
    testR1 = ['I', 'am', 'is', 'pretty', '.']
    testR2 = ['this', 'I', 'am', 'pretty', '.']
    check(testP1, testR0)
    check(testP1, testR1)
    check(testP1, testR2)