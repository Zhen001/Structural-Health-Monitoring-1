# -*-coding:utf-8-*-
# author:ZhuHaitao

import time
import datetime
time_start = time.time()


def time_convert(timedate1):
    timedate1 = float(timedate1) / 1000
    haomiao = round(timedate1 - int(timedate1), 2)
    haomiao = '%.2f' % haomiao
    haomiao = haomiao.split('.')[-1]
    timeArray = time.localtime(timedate1)  # 1970秒数
    otherStyleTime = time.strftime("%Y-%m-%d %H:%M:%S", timeArray)
    timedate2 = otherStyleTime + '.' + haomiao
    return timedate2


def solve_split(line):
    lines = line.split('}{', 1)
    lines[0] = lines[0]+'}'
    lines[1] = '{'+lines[1]
    if '}{' in lines[1]:
        liness = lines[1]
        extend_lines = solve_split(liness)
        del lines[1]
        lines.extend(extend_lines)
        return lines
    else:
        return lines


def solve_error(line, filename, dic):
    lines = solve_split(line)
    for line in lines:
        to_dict(line, filename, dic)


def to_dict(line, filename, dic):
    line = eval(line)
    subkeys = ['position', 'datetime', 'value']
    line = [line[key] for key in subkeys]
    if line[0] != filename:
        filename = line[0]
    line[1] = str(line[1]).split(' ')[-1].replace('}', '')
    line[1] = time_convert(line[1])
    line[2] = '%.6f' % line[2] + '\n'
    line = '   '.join(line)
    if filename in dic:
        dic[filename].append(line)
    else:
        dic[filename] = [line]


filename = ''

for i in range(1, 101):
    dic = {}
    number = str(i).zfill(3)
    filepath = 'G:/宁波站 张老师/nbnz-acceleration分割数据/nbnz-acceleration原始数据_'+number+'.txt'
    for line in open(filepath, 'r', encoding='gbk'):
        print(line)
        try:
            to_dict(line, filename, dic)
        except SyntaxError:
            try:
                solve_error(line, filename, dic)
            except SyntaxError:
                print('File error')
                print(line)
                continue

    for filename in dic.keys():
        filename_path = 'G:/宁波站 张老师/nbnz-acceleration提取后数据/nbnz-' + filename + '.txt'
        f2 = open(filename_path, 'a', encoding='utf8')
        f2.writelines(dic[filename])
        f2.close()
    time_end = time.time()
    print('第%i份完成！已运行' % i, (time_end - time_start)/3600, '小时')
