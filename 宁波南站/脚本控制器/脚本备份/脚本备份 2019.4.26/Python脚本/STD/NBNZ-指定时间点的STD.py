# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import sys
import numpy as np
import pandas as pd
from itertools import islice
from datetime import datetime

# 参数输入
main_path = sys.argv[1]
start_time = sys.argv[2]
end_time = sys.argv[3]
time_stamp = sys.argv[4]
long = int(sys.argv[5])
Fs = int(sys.argv[6])
STD_path = sys.argv[7]

# main_path = r'G:\研一下\宁波站数据\Export-x-accelerate\A-W-GGL1-2-Xx-accelerate'
# start_time = '2014-09-15'
# end_time = '2014-11-06'
# time_stamp = '20:00:00.000'
# long = 6000 # 样本长度
# Fs = 100 # 采样频率
# STD_path = main_path + '\\' + start_time + ' to ' + end_time + '-STD' + time_stamp[0:2] + '.txt'

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

## 依次处理时间段内的TXT文档，从中挑出需要的时间点，并计算STD
STD = []
skip_lines = Fs*3600*(int(time_stamp.split(':')[0]))-Fs*10
if skip_lines < 0: skip_lines = 0

# 获取日期跨度内指定时间点的STD
for file_path in files_df[start_time: end_time].iloc[:, 0]:
    time_stamp1 = file_path.split('\\')[-1].split('.txt')[0] + ' ' + time_stamp
    time_stamp1 = np.datetime64(time_stamp1)
    accelerate = []
    with open(file_path, 'r') as f:
        for line in islice(f, skip_lines, None):
            line_time_stamp = np.datetime64(line.split(' ')[0].replace('@',' '))
            if line_time_stamp < time_stamp1:
                continue
            elif line_time_stamp == time_stamp1: # 找到所需时间点
                for line in islice(f, None, long):
                    accelerate.append(float(line.split(' ')[-1]))
                STD.append(str(np.std(accelerate))+'\n')
                break
            else:
                print('数据缺失：', file_path.split('\\')[-1])
                break

# 将结果写入文件
with open(STD_path,'w') as f:
    f.writelines(STD)
print(len(STD))
