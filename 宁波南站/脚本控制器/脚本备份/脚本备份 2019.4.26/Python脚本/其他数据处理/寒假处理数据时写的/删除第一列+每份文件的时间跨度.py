# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import time
time_start = time.time()

path = 'G:\\宁波站 张老师\\nbnz-acceleration提取后数据'
file_list = os.listdir(path)
print('一共有%i个文件' % len(file_list))
n = 0
for file in file_list:
    n += 1
    date_mark = ''
    period = []
    line_list = []
    lines = []
    file_path = 'G:\\宁波站 张老师\\nbnz-acceleration提取后数据\\' + file
    for line in open(file_path, 'r', encoding='utf8'):
        line_list = line.split('   ')
        del line_list[0]
        date = line_list[0].split(':', 1)[0]
        if date != date_mark:
            date_mark = date
            period.append(line_list[0]+'\n')
        line = ' '.join(line_list)
        lines.append(line)
    with open('G:\\宁波站 张老师\\nbnz-acceleration提取后数据2\\'+file, 'w', encoding='utf8') as f:
        f.writelines(lines)
    file = file.split('.')[0] + '-时间跨度.txt'
    with open('G:\\宁波站 张老师\\nbnz-acceleration提取后数据2\\'+file, 'w', encoding='utf8') as f:
        f.writelines(period)
    time_end = time.time()
    print('第%i份完成！已运行' % n, (time_end - time_start) / 60, '分钟')
