import random
import re

class Responder:
    def __init__(self,name,dictionary):
        self.name=name
        self.dictionary=dictionary
    
    def response(self,input,mood):
        return ''
    
    def get_name(self):
        return self.name
    
class RepeatResponder(Responder):
    def response(self,input,mood):
        return '{}ってなんぞ？'.format(input)
    
class RandomResponder(Responder):
    def response(self,input,mood):
        return random.choice(self.dictionary.random)

class PatternResponder(Responder):
    def response(self,input,mood):
        self.resp=None
        for ptn_item in self.dictionary.pattern:
            m=ptn_item.match(input)
            if m:
                self.resp=ptn_item.choice(mood)
            if self.resp !=None:
                return re.sub('%match%',m.group(),self.resp)
        return random.choice(self.dictionary.random)