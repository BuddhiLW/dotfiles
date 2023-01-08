#!/usr/bin/python
import sys
import urllib.parse

search=str(sys.stdin.read())
encoded_search = urllib.parse.quote_plus(search)
BASE_URL = "https://youtube.com"
url = f"{BASE_URL}/results?search_query={encoded_search}"
print(url)
