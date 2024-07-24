punctuations = ['.', ',', '?', '!']

def parse_sentence(sentence:str):
    sentnece_split = sentence.split(' ')
    parsed = []
    for word in sentnece_split:
        word_list = list(word)
        if word_list[-1] in punctuations:
            punc = word_list[-1]
            word_list.remove(punc)
            parsed.append('')
            for ch in word_list:
                parsed[-1] += ch
            parsed.append(str(punc))

        else:
            parsed.append(word)
    return parsed


def combine_sentence(sentence:list):
    combined = sentence[0]
    sentence.pop(0)
    for word in sentence:
        if word in punctuations:
            combined += word
        else:
            combined += ' ' + word
    
    print(combined)
    return combined


def check_answer(problem:list, response:list):
    isAnswer = False
    if problem == response:
        isAnswer = True

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
    return isAnswer, false_check


def search_log_timestamp(res, action, user_id):
    import re
    from datetime import datetime
    for hit in res['hits']['hits']:
        message = hit['_source']['message']
        timestamp = hit['_source']['@timestamp']
        
        # 정규 표현식을 사용하여 필요한 정보 추출
        match = re.search(f'- --- {action} --- - \[user: {user_id}\]', message)
        if match:
            return datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
            break  # 최신 로그만 필요하므로 루프를 종료합니다.
        else:
            return None

