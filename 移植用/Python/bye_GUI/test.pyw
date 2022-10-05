from tkinter import *
from tkinter import ttk

def click():
    if t.get()=='bye':
        root.quit()
    s.set(t.get())
    t.set('')

root=Tk()
root.title('test_title')

frame1=ttk.Frame(root,padding=16)
s=StringVar()
label1=ttk.Label(frame1,textvariable=s)
t=StringVar()
entry1=ttk.Entry(frame1,textvariable=t)
button1=ttk.Button(frame1,text='OK',command=click)

frame1.pack()
label1.pack(side=BOTTOM)
entry1.pack(side=LEFT)
button1.pack(side=LEFT)

root.mainloop()