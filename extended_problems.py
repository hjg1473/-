import google.generativeai as genai
import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np
from random import shuffle

load_dotenv(verbose=True)

GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=GOOGLE_API_KEY)

model = genai.GenerativeModel('gemini-1.5-flash')


def parse_sentence(sentence:str):
    punctuations = ['.', ',', '?', '!']
    sentnece_split = sentence.split(' ')
    print(sentnece_split)
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
    
    print(parsed)
    return parsed


def combine_sentence(sentence:list):
    punctuations = ['.', ',', '?', '!']
    combined = sentence[0]
    sentence.pop(0)
    for word in sentence:
        if word in punctuations:
            combined += word
        else:
            combined += ' ' + word
    
    print(combined)
    return combined

def generate_problems(num:int):
    

    words = pd.read_csv('data/Vicdream_words_season1.csv')
    exist_problems = pd.read_csv('data/all_problems.csv', encoding='UTF8')
    exist_problems_list =exist_problems['Eng'].to_numpy().tolist() 
    exist_problems = str(exist_problems_list)
    words = str(words['words'].to_numpy().tolist())
    message={
        "role":"user",
        "parts":["Let's think step by step. You are a english teacher, and I am five-year-old student. Generate 50 short sentences, and only using words in this list: ", words, "Check again if there are words not in this list, and if there are, regenarte the detected sentence.", "Response should be only generated senteces."]
    }

    response = model.generate_content(message)
    raw_problems = response.text.split('\n')
    if '' in raw_problems:
        raw_problems.remove('')
    print(len(raw_problems), end=', ')
    # print(raw_problems)

    problems = []

    for i in raw_problems:
        single_sentence = i.split(' ')
        while '' in single_sentence:
            single_sentence.remove('')
        isWordsOK = True
        for word in single_sentence:
            listword = list(word)
            if listword[-1] in punctuations:
                listword.remove(listword[-1])
            
            theword = ''
            for ch in listword:
                theword += ch
            # print(theword)
            word = theword
            if word not in words:
                isWordsOK = False
                break
        
        if isWordsOK:
            sentence = ''
            for word in single_sentence:
                sentence += word + ' '
            
            problems.append(sentence)


    punctuations = ['.', ',', '?', '!']
    truproblems = [''] * len(problems)
    cnt = -1
    for sentence in problems:
        cnt += 1
        ls = list(sentence)
        lenls = len(ls)
        i = 1
        # print(lenls, end=',')
        while i < lenls:
            if (ls[i] in punctuations) and ls[i-1] == ' ':
                
                ls.pop(i-1)
                i -= 1
                lenls -= 1
                if (i >= lenls) or (i <= 0) or (lenls <= 0):
                    break
            
            i += 1
        # for i in range(lenls):
        lenls = len(ls)
        
        while (lenls >= 1) and ls[lenls-1] == ' ':
            ls.pop(lenls-1)
            lenls -= 1
        
        for ch in ls:
            truproblems[cnt] += ch

    # print(len(truproblems))
    
    print('original len(tp):', len(truproblems))
    truproblems = set(truproblems)
    # truproblems = list(truproblems)
    # shuffle(truproblems)
    print('setted len(tf):', len(truproblems))
    print(truproblems)
    removeList = []
    for sentence in truproblems:
        print(sentence, end='')
        if (sentence in exist_problems_list):
            print('--', end='')
            removeList.append(sentence)
        print()

    for removeSentence in removeList:
        truproblems.remove(removeSentence)
    
    print(len(truproblems))
    print(truproblems)
    truproblems = list(truproblems)
    final_problem_list = exist_problems_list + truproblems
    # exist_problems_list += truproblems
    # print(exist_problems_list)

    df = pd.DataFrame(final_problem_list, columns=['Eng'])
    df.to_csv('data/all_problems.csv')

if __name__ == '__main__':
    ITERNUM = 1
    GENNUM = 100
    parsed = parse_sentence('I am pretty.')
    combine_sentence(parsed)
    # for i in range(ITERNUM):
    #     generate_problems(GENNUM)