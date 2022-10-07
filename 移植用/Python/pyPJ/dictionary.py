import random
import re
from analyzer import *

class Dictionary:
    def __init__(self):
        rfile=open('dics/random.txt','r',encoding='utf_8')
        r_lines=rfile.readlines()
        rfile.close()
        self.random=[]
        for line in r_lines:
            str=line.rstrip('\n')
            if (str!=''):
                self.random.append(str)
        pfile=open('dics/pattern.txt','r',encoding='utf_8')
        p_lines=pfile.readlines()
        pfile.close()
        self.new_lines=[]
        for line in p_lines:
            str=line.rstrip('\n')
            if (str!=''):
                self.new_lines.append(str)
        self.pattern=[]
        for line in self.new_lines:
            ptn,prs=line.split('\t')
            self.pattern.append(ParseItem(ptn,prs))
    
    def study(self,input,parts):
        input=input.rstrip('\n')
        self.study_random(input)
        self.study_pattern(input,parts)
    
    def study_random(self,input):
        if not input in self.random:
            self.random.append(input)
    
    def study_pattern(self,input,parts):
        for word,part in parts:
            if keyword_check(part):
                depend=False
                for ptn_item in self.pattern:
                    m=re.search(ptn_item.pattern,word)
                    if re.search(ptn_item.pattern,word):
                        depend=ptn_item
                        break
                if depend:
                    depend.add_phrase(input)
                else:
                    self.pattern.append(ParseItem(word,input))
    
    def save(self):
        for index,element in enumerate(self.random):
            self.random[index]=element+'\n'
        with open('dics/random.txt','w',encoding='utf_8') as f:
            f.writelines(self.random)
        pattern=[]
        for ptn_item in self.pattern:
            pattern.append(ptn_item.make_line()+'\n')
        with open('dics/pattern.txt','w',encoding='utf_8') as f:
            f.writelines(pattern)

class ParseItem:
    SEPARATOR='^((-?\d+)##)?(.*)$'

    def __init__(self,pattern,phrases):
        m=re.findall(ParseItem.SEPARATOR,pattern)
        self.modify=0
        if m[0][1]:
            self.modify=int(m[0][1])
        self.pattern=m[0][2]
        self.phrases=[]
        self.dic={}
        for phrase in phrases.split('|'):
            m=re.findall(ParseItem.SEPARATOR,phrase)
            self.dic['need']=0
            if m[0][1]:
                self.dic['need']=int(m[0][1])
            self.dic['phrase']=m[0][2]
            self.phrases.append(self.dic.copy())
    
    def match(self,str):
        return re.search(self.pattern,str)
    
    def choice(self,mood):
        choices=[]
        for p in self.phrases:
            if (self.suitable(p['need'],mood)):
                choices.append(p['phrase'])
        if (len(choices)==0):
            return None
        return random.choice(choices)
    
    def suitable(self,need,mood):
        if (need==0):
            return True
        elif (need>0):
            return (mood>need)
        else:
            return (mood<need)