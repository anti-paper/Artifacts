# coding: utf-8
import requests
from bs4 import BeautifulSoup

uri = 'https://www.javadrive.jp/'
try:
    html = requests.get(uri)
except Exception as e:
    print(e)
finally:
    # print(html.text)
    
    soup = BeautifulSoup(html.text, 'html.parser')
    links = soup.find('div', class_ = 'container')
    # print(links)
    
    for item in links.find_all('a'):
        print(item['href'], item.text)