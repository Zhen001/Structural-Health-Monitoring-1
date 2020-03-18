# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import numpy as np
import time; time_start=time.time()

# 参数设定
long = 6000

# Function-创建文件夹
def mkdir(path):
    path = path.strip()
    path = path.rstrip("\\")
    isExists = os.path.exists(path)
    if not isExists:
        os.makedirs(path)

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

# Function-将时间索引(str)转换成自然数索引(1:8640000)
def transfer_time_to_number(line_time_stamp):
    time_stamp = line_time_stamp.split(' ')[-1].split(':')
    time_stamp = [float(i) for i in time_stamp]
    number = int(time_stamp[0]*60*60*100 + time_stamp[1]*60*100 + time_stamp[2]*100)
    return number

# Function-转成待写入行(list) 保留'@'(悔不当初，没必要用@，应该用空格，但改源数据太麻烦了)
def transfer_to_prepared_lines(lines, accelerate_list):
    for ii in range(len(accelerate_list)):
        line_time_stamp = get_line_time_stamp(lines[ii])
        accelerate_list[ii] = line_time_stamp.replace(' ', '@') + ' ' +  str(accelerate_list[ii]) + '\n'
    return accelerate_list

# Function-拉回零均值
def pull_back_to_zero(import_handle):
    mean_list = []
    n = 0; mark = 1
    while mark:
        n += 1
        lines = readlines(import_handle, long)
        if lines[-1] == '':
            if lines[0] != '':
                mark = 0
                lines = list(filter(None, lines))
            else:
                break
        accelerate_list = [float(x.split(' ')[-1].strip()) for x in lines]
        mean = np.mean(accelerate_list)
        if n == 1: # 第一个直接拉回零均值，不能对空列表求均值，只好这样
            accelerate_list = [x - mean for x in accelerate_list]
            mean_list.append(mean)
        else: # 如果第n次均值和前面的均值偏离太大，就先用多项式拟合消除趋势项，再拉回零均值
            if mean - np.mean(mean_list) > np.std(mean_list) and n > 5:
                # 用n次多项式拟合
                x = [transfer_time_to_number(get_line_time_stamp(x)) for x in lines]
                p = np.polyfit(x, accelerate_list, 3)
                yvals = np.polyval(p,x)
                # print(lines[0]) # 看看是哪个时间点用到了拟合
                accelerate_list = list(map(lambda x: x[0]-x[1], zip(accelerate_list, yvals))) # 消除趋势项
                # accelerate_list = [x - np.mean(accelerate_list) for x in accelerate_list] # 拉回零均值, 这一步把原本32秒的程序增加到了55秒，对比后发现实在没有必要增加这一步
                mean_list = [x + (mean - np.mean(mean_list)) for x in mean_list] # 把前面的均值人为地升降
                mean_list.append(mean)
            else: # 对于前m次以及偏差不大的，直接拉回零均值
                accelerate_list = [x - mean for x in accelerate_list]
                mean_list.append(mean)
        prepared_lines = transfer_to_prepared_lines(lines, accelerate_list)
        export_handle.writelines(prepared_lines)

# Main
main_path_import = r'G:\研一下\宁波站数据\Export-x-accelerate\A-W-GGL1-2-Xx-accelerate'
main_path_export = '\\'.join(main_path_import.split('\\')[:-2]) + '\\已拉回零均值\\' + '\\'.join(main_path_import.split('\\')[-2:]); mkdir(main_path_export)
file_list_import = os.listdir(main_path_import)
file_list_import = [x for x in file_list_import if '2014-09-18.txt' == x] # 测试用
file_list_export = file_list_import
for file in file_list_import:
    file_path_import = main_path_import + '\\' + file
    file_path_export = main_path_export + '\\' + file
    import_handle = open(file_path_import, 'r')
    export_handle = open(file_path_export, 'w')
    pull_back_to_zero(import_handle)
    import_handle.close(); export_handle.close()

time_end=time.time()
print('totally cost',time_end-time_start)