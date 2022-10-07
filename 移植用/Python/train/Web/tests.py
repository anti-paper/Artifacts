import requests,bs4,csv
import xlwings as xw

def main():
    url='https://tonari-it.com/'
    res=requests.get(url)
    res.raise_for_status()
    soup=bs4.BeautifulSoup(res.text,'html.parser')
    list=soup.select('#list a')

    wb=xw.Book.caller()
    ws=wb.sheets('Sheet2')
    ws.range('a2:b'+str(ws.cells.last_cell.end('up').row)).clear
    i=2

    for data in list:
        ws.range('a{}'.format(i)).value=data.get('title')
        ws.range('b{}'.format(i)).value=data.get('href')
        i+=1