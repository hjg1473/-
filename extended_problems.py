import google.generativeai as genai
import os
from dotenv import load_dotenv
import pandas as pd
import numpy as np

load_dotenv(verbose=True)

GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=GOOGLE_API_KEY)

model = genai.GenerativeModel('gemini-1.5-flash')
words = pd.read_csv('data/Vicdream_words_season1.csv')
exist_problems = pd.read_csv('data/Vicdream_problems_season1.csv')
exist_problems = str(exist_problems['Eng'].to_numpy().tolist)
words = str(words['words'].to_numpy().tolist())
print(words)

message={
    "role":"user",
    "parts":["Let's think step by step. You are a english teacher, and I am five-year-old student. Generate 20 short sentences only using words in this list.", words, "Check again if there are words not in this list, and if there are, regenarte the detected sentence.", "Put a space in front of every punctuation in generated sentences. Response should be only generated senteces."]
}

response = model.generate_content(message)
raw_problems = response.text.split('\n')
if '' in raw_problems:
    raw_problems.remove('')

print(raw_problems)

problems = []

for i in raw_problems:
    single_sentence = i.split(' ')
    while '' in single_sentence:
        single_sentence.remove('')
    isWordsOK = True
    for word in single_sentence:
        if word not in words:
            isWordsOK = False
            break
    if isWordsOK:
        sentence = ''
        for word in single_sentence:
            sentence += word + ' '
        
        problems.append(sentence)

print(len(problems))
print(problems)