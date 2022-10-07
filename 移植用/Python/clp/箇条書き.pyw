import pyperclip as clp
a=clp.paste().split('\n')
a.remove('')
a=['・'+b for b in a]
clp.copy('\n'.join(a))