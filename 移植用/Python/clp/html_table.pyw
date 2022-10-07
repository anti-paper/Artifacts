from audioop import add
import pyperclip as clp
a=clp.paste().split('\r\n')
for i in range(len(a)):
    if i==0:
        addstr='th'
    else:
        addstr='td'
    b=a[i].split(',')
    d=[]
    for c in b:
        d.append('        <{}>{}</{}>'.format(addstr,c,addstr))
    a[i]='    <tr>\n{}\n    </tr>'.format('\n'.join(d))
text='<table border=1>\n{}\n</table>'.format('\n'.join(a))
clp.copy(text)