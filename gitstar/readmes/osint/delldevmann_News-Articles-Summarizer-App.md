# News Article Summarizer Web-App

## Overview
The News Article Summarizer and Categorizer is a project aimed at addressing the information overload experienced by users in today's fast-paced world. This project provides a streamlined platform for accessing and summarizing news articles across five main domains: India, World, Business, Technology, and Sports. Additionally, it offers the functionality to convert summarized news articles into audio format, enhancing accessibility and convenience for users who prefer auditory consumption of information.

## Features and working
- **News article scraping**: Collects news articles from [Times of India website](https://timesofindia.indiatimes.com/) across various domains.
- **Text Summarization**: Provides concise summaries of news articles using advanced NLP techniques.
- **Text-to-Audio Conversion**: Converts summarized news articles into audio format for auditory consumption.

## Technologies Used
- **Libraries**:
  - `os.path`: For filesystem path operations.
  - `csv`: For reading and writing CSV files.
  - `requests`: For sending HTTP requests to fetch web pages.
  - `pandas`: For data manipulation and analysis.
  - `nltk.corpus`: For accessing natural language corpora and lexical resources.
  - `gtts`: For converting text to speech.
  - `streamlit`: For creating interactive web applications.
  - `bs4 (BeautifulSoup)`: For web scraping HTML and XML documents.
  - `newspaper`: For web scraping news articles from various sources.


## Methodology
1. **Web Scraping**: Automatically extracts information from websites to retrieve news articles.
2. **Text Summarization**: Uses models like BART from the transformer library to generate concise summaries of articles.
3. **Text-to-Audio Conversion**: Utilizes the gTTS (Google Text-to-Speech) module to generate audio summaries from the provided text.

## Frontend
![image](https://github.com/akanksha1131/News-Articles-Summarizer-App/assets/115597711/52cfd4c6-4aaf-4c7c-9fb6-22a052fd414b)

![image](https://github.com/akanksha1131/News-Articles-Summarizer-App/assets/115597711/dacaf544-d657-45eb-9526-bc474abd8577)

![image](https://github.com/akanksha1131/News-Articles-Summarizer-App/assets/115597711/83fc9c47-2d64-4c00-9733-734d34719b68)

![image](https://github.com/akanksha1131/News-Articles-Summarizer-App/assets/115597711/0009eb89-2b86-4a34-91de-382e32bd69cc)



Deployed version on Streamlit cloud: https://2minutenews.streamlit.app/

