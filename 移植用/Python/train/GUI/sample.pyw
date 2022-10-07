from tkinter import *
from tkinter import ttk
import pandas as pd

#https://python.keicode.com/advanced/tkinter.php


def setV(event):
    l=list(dict.fromkeys(df[v1.get()]))
    combo2['values']=l
    combo2.set(l[0])

def setFilt():
    s.set(df[df[v1.get()]==v2.get()])

df=pd.read_csv(r'data\testData.csv',encoding='shift_JIS')
df.index=range(1,df['Name'].count()+1)

for sl in list(df.columns):
    df[sl]=df[sl].astype(str)

root=Tk()
root.title('test')

frame1=ttk.Frame(root,padding=50)
frame1.grid()

v1=StringVar()
combo1=ttk.Combobox(frame1,textvariable=v1,values=list(\
    df.columns),width=10,state='readonly')
combo1.set(list(df.columns)[0])
combo1.grid(row=0,column=0)

v2=StringVar()
combo2=ttk.Combobox(frame1,textvariable=v2,\
    values=list(df[v1.get()]),width=10,state='readonly')
combo2.set(list(df[v1.get()])[0])
combo2.grid(row=0,column=1)

combo1.bind('<<ComboboxSelected>>',setV)

s=StringVar()
label1=ttk.Label(frame1,textvariable=s)
s.set(df)
label1.grid(row=1,columnspan=3)

button1=ttk.Button(frame1,text='フィルターを実行',command=setFilt)
button1.grid(row=0,column=2)

root.mainloop()