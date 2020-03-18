# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import numpy as np
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt

# 参数输入
main_path = r'G:\研一下\宁波站数据\Export-windspeed\05501LMwind-speed'
long = 60000 # 样本长度

# Function-读取固定行
def readlines(f,number_of_lines):
    lines = []
    for ii in range(number_of_lines):
        lines.append(f.readline())
    return lines

# 更改文件名及排除非数据项
file_list = os.listdir(main_path)
for temp in file_list:
    if temp.split('-')[-1] == '0.txt':
        new_name = temp.split('-')[0] + '-' + temp.split('-')[1].zfill(2) + '-' + temp.split('-')[2].zfill(2) + '.txt'
        os.rename(main_path + '\\' + temp, main_path + '\\' + new_name)
file_list = [i for i in file_list if 'STD' not in i and 'RMS' not in i and 'Original' not in i
                 and 'errorTime' not in i and '十分钟风速数据' not in i]

# 把文件夹内的TXT按时间顺序排列好，方便索引
files_df = []
for i in range(len(file_list)):
    file_time = datetime.strptime(file_list[i].split('.')[0], '%Y-%m-%d')
    files_df.append([file_time, main_path + '\\' + file_list[i]])
files_df = sorted(files_df, key=lambda x:x[0])
files_df = pd.DataFrame(files_df)
files_df.set_index(0, inplace=True) # 按索引升序

### 计算十分钟风速
velocity = pd.Series([])
for file_path in files_df.iloc[:, 0]:
    number_of_rows = len(["" for line in open(file_path, "r")])
    with open(file_path, 'r') as f:
        for ii in range(number_of_rows // long):
            lines = f.readlines(32 * long)
            v = np.mean([float(x.split(' ')[-1].strip()) for x in lines])/500
            velocity[np.datetime64(lines[0].split(' ')[0].replace('@', ' '))] = v

# 将结果写入文件
velocity.to_excel(main_path + '\\十分钟风速数据.xlsx', index=True, header=None)

# 读取文件
velocity = pd.read_excel(main_path + '\\十分钟风速数据.xlsx', header=None, index_col=0)

start_time = '2014-01-01'; end_time = '2014-12-31'
velocity = velocity[start_time: end_time][velocity>3]

### 绘制十分钟风速图
plt.close('all') # 关闭图片
plt.figure(figsize=(100, 5))
plt.rcParams['figure.dpi'] = 400
# plt.plot(velocity,'.',markersize=0.5)
plt.plot(velocity)
plt.ylabel('Velocity(m/s)')
plt.legend('Velocity')
plt.show()
# plt.savefig(r'E:\【论文】\【小论文】\宁波南站\Python脚本\十分钟风速图\十分钟风速图.png')


### 绘制全年风速图
velocity = pd.Series([])
for file_path in files_df.iloc[:, 0]:
    for line in open(file_path, 'r'):
        v = float(line.split(' ')[-1].strip()) / 500
        velocity[np.datetime64(line.split(' ')[0].replace('@', ' '))] = v
start_time = '2014-01-01'; end_time = '2014-12-31'
velocity = velocity[start_time: end_time][velocity>3]

plt.close('all') # 关闭图片
plt.figure(figsize=(100, 5))
plt.rcParams['figure.dpi'] = 400
# plt.plot(velocity,'.',markersize=0.5)
plt.plot(velocity)
plt.ylabel('Velocity(m/s)')
plt.legend('Velocity')
plt.show()

