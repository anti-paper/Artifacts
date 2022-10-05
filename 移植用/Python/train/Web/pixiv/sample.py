import requests,bs4
import xlwings as xw

def test():
    wb=xw.Book.caller()
    ws=wb.sheets.active
    test=[]

    for i in range(10000):
        test.append([i])

    ws.range('a7').value=test