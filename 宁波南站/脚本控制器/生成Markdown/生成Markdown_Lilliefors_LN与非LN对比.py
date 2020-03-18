# -*-coding:utf-8-*-
# author:ZhuHaitao

import sys
import xlrd
import pandas as pd

project = sys.argv[1]
position = sys.argv[2]
date_start = sys.argv[3]
date_end = sys.argv[4]

data_type= project.split('-')[2]
main_path = r'E:\【论文】\【小论文】\宁波南站\Pictures\Pictures_' + project + '\\' + position
xlsx_path = main_path + '\\' + date_start + ' to ' + date_end + '  ' + project + '.xlsx'
book = xlrd.open_workbook(xlsx_path) # 得到Excel文件的book对象，实例化对象
sheet = book.sheet_by_index(0) # 通过sheet索引获得sheet对象
content = ['# ',project + '与' + project + '(LN)' + '对比','\n']

for i in range(1,24):
    mark = '%02d' % i
    content.append('## ' + mark + ':00:00' + '\n')
    A = str(sheet.row_values(i-1)[1])
    B = str(sheet.row_values(i-1)[2])
    content.append('| | |\n| :-: | :-: |\n|' + A +'|' + B + '|\n')
    pic1 = date_start + ' to ' + date_end + '  ' + data_type + '-' + mark + '.png'
    pic2 = date_start + ' to ' + date_end + '  ' + data_type + '(LN)-' + mark + '.png'
    content.append('<div align="center"> <img src="' + pic1 + '" width="40%" alt=""/><img src="' + pic2 + '" width="40%" alt=""/>' + '\n\n')
    
with open(r'E:\【论文】\【小论文】\宁波南站\Pictures\Pictures_' + project + '\\' + position + '\\' + project + '-LN与非LN对比.md','w') as f:
    f.writelines(content)
