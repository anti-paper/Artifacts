from ptna import *

def prompt(obj):
    return obj.get_name()+":"+obj.get_responder_name()+"> "

print("Ptna System prototype : ptna")
ptna=Ptna("ptna")

while True:
    inputs=input(" > ")
    if not inputs:
        print("ほなさいなら")
        input()
        break
    response=ptna.dialogue(inputs)
    print(prompt(ptna),response)