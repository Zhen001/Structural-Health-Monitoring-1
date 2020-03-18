# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import sys
import numpy as np
import pandas as pd
from datetime import datetime

# Function-读取固定行
def readlines(f,number_of_lines):
    lines = []
    for ii in range(number_of_lines):
        lines.append(f.readline())
    return lines

# Function-提取该行数据里的时间戳(str)
def get_line_time_stamp(line):
    line_time_stamp = line.split(' ')[0].replace('@', ' ')
    return line_time_stamp

# Function-找到起始时间行00.000(start)
def find_start(f):
    while 1:
        line = f.readline()
        if get_line_time_stamp(line).split(':')[-1]=='00.000':
            start = line
            return start

# Function-将时间索引(str)转换成自然数索引(1:1440)
def transfer_time_to_number(line_time_stamp):
    time_stamp = line_time_stamp.split(' ')[-1].split(':')
    time_stamp = [float(i) for i in time_stamp]
    number = int(time_stamp[0]*60 + time_stamp[1])
    return number

# Function-转成待写入行(str)
def transfer_to_prepared_line(start, STD):
    line_time_stamp = get_line_time_stamp(start)
    prepared_line = str(transfer_time_to_number(line_time_stamp)) + ' ' +  str(STD) + '\n'
    return prepared_line

# 参数输入
main_path = sys.argv[1]
start_time = sys.argv[2]
end_time = sys.argv[3]
long = int(sys.argv[4])
Fs = int(sys.argv[5])
STD_path = sys.argv[6]

# main_path = r'G:\研一下\宁波站数据\Export-x-accelerate\A-W-GGL1-2-Xx-accelerate'
# start_time = '2014-09-15'
# end_time = '2014-12-11'
# long = 6000 # 样本长度
# Fs = 100 # 采样频率
# STD_path = main_path + '\\' + start_time + ' to ' + end_time + '的所有STD.txt'

# 更改文件名及排除非数据项
file_list = os.listdir(main_path)
for temp in file_list:
    if temp.split('-')[-1] == '0.txt':
        new_name = temp.split('-')[0] + '-' + temp.split('-')[1].zfill(2) + '-' + temp.split('-')[2].zfill(2) + '.txt'
        os.rename(main_path + '\\' + temp, main_path + '\\' + new_name)
file_list = [i for i in file_list if 'STD' not in i and 'RMS' not in i and 'Original' not in i and 'errorTime' not in i]

# 把文件夹内的TXT按时间顺序排列好，方便索引
files_df = []
for i in range(len(file_list)):
    file_time = datetime.strptime(file_list[i].split('.')[0], '%Y-%m-%d')
    files_df.append([file_time, main_path + '\\' + file_list[i]])
files_df = sorted(files_df, key=lambda x:x[0])
files_df = pd.DataFrame(files_df)
files_df.set_index(0, inplace=True) # 按索引升序

# 循环读取TXT数据，并记录下所有STD及对应的时间索引
STD_Months = []
for file_path in files_df[start_time: end_time].iloc[:, 0]:
    with open(file_path, 'r') as f:
        while True:
            start = f.readline()
            if get_line_time_stamp(start).split(':')[-1] != '00.000':
                start = find_start(f)
            accelerate = [float(start.split(' ')[-1])]
            lines = readlines(f, long-1) # start已经占用了一个
            if lines[-1]=='':
                print(file_path.split('\\')[-1]+':'+str(len(STD_Months)))
                break
            for line in lines:
                accelerate.append(float(line.split(' ')[-1]))
            STD = np.std(accelerate)
            prepared_line = transfer_to_prepared_line(start, STD)
            STD_Months.append(prepared_line)

# 将结果写入文件
with open(STD_path,'w') as f:
    f.writelines(STD_Months)