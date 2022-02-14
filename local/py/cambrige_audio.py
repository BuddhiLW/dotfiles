#!/usr/bin/env python3

# Importing BeautifulSoup class from the bs4 module
from bs4 import BeautifulSoup
# import urllib.request
import sys

# Get the original webpage html content
tmp_file = sys.argv[1]
# print(tmp_file)

# Opening the html file
HTMLFile = open(tmp_file, "r")
index = HTMLFile.read()
S = BeautifulSoup(index, 'lxml')

audio_src = S.select_one('source:nth-of-type(1)')
audio_url = "https://dictionary.cambridge.org" + audio_src['src']
sys.stdout.write(audio_url)
