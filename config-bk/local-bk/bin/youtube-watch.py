#!/usr/bin/python
import sys
from youtube_search import YoutubeSearch

# results = YoutubeSearch('search terms', max_results=10).to_json()

# print(results)

# # returns a json string

# ########################################

search=str(sys.stdin.read())

results = YoutubeSearch(search, max_results=1).to_dict()
print(results[0]['url_suffix'])
# returns a dictionary
