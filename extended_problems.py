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
words = words['words'].to_numpy().tolist()
print(words)

message={
    "role":"user",
    "parts":{"texts":["Let's think step by step. You are a english teacher, and I am five-year-old student. Generate 20 short sentences only using words in this list.", words, "Put a space in front of every punctuation in generated sentences. Response should be only generated senteces."]}
}

response = model.generate_content(message)

print(response.text)