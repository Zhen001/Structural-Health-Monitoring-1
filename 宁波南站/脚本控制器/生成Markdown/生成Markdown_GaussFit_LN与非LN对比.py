# -*-coding:utf-8-*-
# author:ZhuHaitao

import sys
import pandas as pd

project = sys.argv[1]
position = sys.argv[2]
date_start = sys.argv[3]
date_end = sys.argv[4]
if_log = int(sys.argv[5])

data_type= project.split('-')[2]
project2 = project + '(LN)' if if_log==1 else project
main_path = r'E:\【论文】\【小论文】\宁波南站\Pictures\Pictures_' + project + '\\' + position
content = ['# ',project + '与' + project2 + '对比','\n']

for i in range(1,24):
    mark = '%02d' % i
    content.append('## ' + mark + ':00:00' + '\n')
    pic1 = date_start + ' to ' + date_end + '  ' + data_type + '-' + mark + '.png'
    pic2 = date_start + ' to ' + date_end + '  ' + data_type + '(LN)-' + mark + '.png'
    content.append('<div align="center"> <img src="' + pic1 + '" width="40%" alt=""/><img src="' + pic2 + '" width="40%" alt=""/>' + '\n\n')
    
with open(r'E:\【论文】\【小论文】\宁波南站\Pictures\Pictures_' + project + '\\' + position + '\\' + project + '-LN与非LN对比.md','w') as f:
    f.writelines(content)
