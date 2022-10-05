from tkinter import *
from tkinter import ttk

root=Tk()
root.title('test_tkinter')

frame1=ttk.Frame(root,padding=200)
frame1.grid()

textv=''
label1=ttk.Label(frame1,text=textv)
label1.grid()

def showtext():
    global textv

    if textv=='':
        textv='test'
    else:
        textv=''
    
    label1.configure(text=textv)

menubar=Menu(root)
root.config(menu=menubar)

filemenu=Menu(menubar)
menubar.add_cascade(label='File',menu=filemenu)

filemenu.add_command(label='close',command=root.destroy)

showmenu=Menu(menubar)
menubar.add_cascade(label='Show',menu=showmenu)

showmenu.add_command(label='show_text',command=showtext)

root.mainloop()