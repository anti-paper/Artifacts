import requests
import datetime
import pyperclip as pc
from tkinter import *
from tkinter.ttk import *

uri = 'https://holidays-jp.github.io/api/v1/date.json'
text = '今年の祝日を取得しました'
try:
    # raise BaseException('test')
    response = requests.get(uri)
    # print(response.json())

    date = datetime.date.today()
    year = str(date.year)
    res = ''
    for k,v in response.json().items():
        if k[:4] == year:
            res += f'{k}\t{v}\n'
    pc.copy(res.rstrip())
except Exception as e:
    text = '祝日の取得に失敗しました'
except BaseException as e:
    text = '祝日の取得に失敗しました'
finally:
    def qt(e):
        root.quit()

    root = Tk()
    root.title('今年の祝日')
    frame = Frame(root, padding = 16)
    label = Label(frame, text = text, width = 32)
    button = Button(frame, text = 'OK', command = lambda: root.quit())
    root.bind('<Return>', qt)
    frame.pack()
    label.pack()
    button.pack()
    root.mainloop()