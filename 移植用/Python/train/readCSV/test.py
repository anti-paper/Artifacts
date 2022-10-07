import openpyxl,csv

with open('test.csv') as f:
    Lines=csv.reader(f)
    wb=openpyxl.load_workbook('test.xlsm',keep_vba=True)
    ws=wb.active
    i=1

    for Line in Lines:
        j=1
        
        for data in Line:
            ws.cell(i,j).value=data
            j+=1
        
        i+=1

wb.save('test.xlsm')