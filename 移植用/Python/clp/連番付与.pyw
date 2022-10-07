from operator import le
import pyperclip as pc
a=pc.paste().split('\n')
a.remove('')
a=['{:d}\t{}'.format(i+1,a[i]) for i in range(len(a))]
pc.copy('\n'.join(a))