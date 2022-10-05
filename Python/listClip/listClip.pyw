import pyperclip as pc
s = pc.paste().rstrip().split('\n')
for i in range(len(s)):
    s[i] = '・' + s[i]
pc.copy('\n'.join(s))
