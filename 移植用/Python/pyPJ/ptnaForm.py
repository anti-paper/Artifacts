from ptna import *
from datetime import datetime
import tkinter as tk
import tkinter.messagebox

entry=None
response_area=None
lb=None
action=None
ptna=Ptna("ptna")
on_canvas=None
ptyna_images=[]
log=[]

def putlog(str):
    lb.insert(tk.END,str)
    log.append(str+'\n')

def prompt():
    p=ptna.name
    if (action.get())==0:
        p+=':'+ptna.responder.name
    return p+'> '

def chagImg(img):
    canvas.itemconfig(
        on_canvas,
        image=ptyna_images[img]
    )

def change_looks():
    em=ptna.emotion.mood
    if -5<=em<=5:
        chagImg(0)
    elif -10<=em<-5:
        chagImg(1)
    elif -15<=em<-10:
        chagImg(2)
    elif 5<=em<=15:
        chagImg(3)

def talk():
    value=entry.get()
    if not value:
        response_area.configure(text='なんぞ？')
    else:
        response=ptna.dialogue(value)
        response_area.configure(text=response)
        putlog('> '+value)
        putlog(prompt()+response)
        entry.delete(0,tk.END)
    change_looks()

def writeLog():
    now='Ptna System Dialogue Log: '+datetime.now().strftime(
        '%Y-%m-%d %H:%m:%S'+'\n'
    )
    log.insert(0,now)
    with open('log.txt','a',encoding='utf_8') as f:
        f.writelines(log)

def run():
    global entry,response_area,lb,action,canvas,on_canvas,ptyna_images
    root=tk.Tk()
    root.geometry('880x560')
    root.title('Intelligent Agent : ')
    font=('Helevetica',14)
    font_log=('Helevetica',11)

    def callback():
        if tkinter.messagebox.askyesno(
            'Quit?','ランダム辞書を更新しますか？'
        ):
            ptna.save()
            writeLog()
            root.destroy()
        else:
            root.destroy()
    root.protocol('WM_DELETE_WINDOW',callback)
    menubar=tk.Menu(root)
    root.config(menu=menubar)
    filemenu=tk.Menu(menubar)
    menubar.add_cascade(label='ファイル',menu=filemenu)
    filemenu.add_command(label='閉じる',command=callback)
    action=tk.IntVar()
    optionmenu=tk.Menu(menubar)
    menubar.add_cascade(label='オプション',menu=optionmenu)
    optionmenu.add_radiobutton(
        label='Responderを表示',
        variable=action,
        value=0
    )
    optionmenu.add_radiobutton(
        label='Responderを表示しない',
        variable=action,
        value=1
    )
    canvas=tk.Canvas(
        root,
        width=500,
        height=300,
        relief=tk.RIDGE,
        bd=2
    )
    canvas.place(x=370,y=0)
    ptyna_images.append(tk.PhotoImage(file='pic/talk.gif'))
    ptyna_images.append(tk.PhotoImage(file='pic/empty.gif'))
    ptyna_images.append(tk.PhotoImage(file='pic/angry.png'))
    ptyna_images.append(tk.PhotoImage(file='pic/happy.png'))
    on_canvas=canvas.create_image(
        0,
        0,
        image=ptyna_images[0],
        anchor=tk.NW
    )
    response_area=tk.Label(
        root,
        width=50,
        height=10,
        bg='yellow',
        font=font,
        relief=tk.RIDGE,
        bd=2
    )
    response_area.place(x=370,y=305)
    frame=tk.Frame(
        root,
        relief=tk.RIDGE,
        borderwidth=4
    )
    entry=tk.Entry(
        frame,
        width=70,
        font=font
    )
    entry.pack(side=tk.LEFT)
    entry.focus_set()
    button=tk.Button(
        frame,
        width=15,
        text='話す',
        command=talk
    )
    button.pack(side=tk.LEFT)
    frame.place(x=30,y=520)
    lb=tk.Listbox(
        root,
        width=42,
        height=30,
        font=font_log
    )
    sb1=tk.Scrollbar(
        root,
        orient=tk.VERTICAL,
        command=lb.yview
    )
    sb2=tk.Scrollbar(
        root,
        orient=tk.HORIZONTAL,
        command=lb.xview
    )
    lb.configure(yscrollcommand=sb1.set)
    lb.configure(xscrollcommand=sb2.set)
    lb.grid(row=0,column=0)
    sb1.grid(row=0,column=1,sticky=tk.NS)
    sb2.grid(row=1,column=0,sticky=tk.EW)

    root.mainloop()

if __name__=="__main__":
    run()