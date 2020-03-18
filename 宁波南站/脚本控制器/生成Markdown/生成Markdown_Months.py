# -*-coding:utf-8-*-
# author:ZhuHaitao

import sys
import pandas as pd

project = sys.argv[1]
position = sys.argv[2]
date_start = sys.argv[3]
date_end = sys.argv[4]
if_log = int(sys.argv[5])

project2 = project + '(LN)' if if_log else project
content = ['# ',project2,'\n']

for i in range(1,24):
    mark = '%02d' % i
    content.append('## ' + date_start + ' to ' + date_end + '  ' + project2.split('-')[-1] + '-' + mark + '\n')
    content.append('![](' + date_start + ' to ' + date_end + '  ' + project2.split('-')[-1] + '-' + mark + '.png)' + '\n')

with open(r'E:\【论文】\【小论文】\宁波南站\Pictures\Pictures_' + project + '\\' + position + '\\' + project2 + '.md','w') as f:
    f.writelines(content)
