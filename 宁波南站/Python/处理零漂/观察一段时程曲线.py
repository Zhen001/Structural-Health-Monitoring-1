# -*-coding:utf-8-*-
# author:ZhuHaitao

from itertools import islice
import numpy as np
import matplotlib.pyplot as plt

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

# Main
start = 6*360000+6000*4
long = 6000*2
lines = []
path = r'G:\研一下\宁波站数据\已拉回零均值\Export-x-accelerate\A-W-GGL1-2-Xx-accelerate\2014-09-18.txt'
f = open(path,'r')
for line in islice(f, start, start+long):
    lines.append(line)

time_stamp = [get_line_time_stamp(x) for x in lines]
accelerate = [float(x.split(' ')[-1]) for x in lines]

# 用n次多项式拟合
x = [transfer_time_to_number(x) for x in time_stamp]
z1 = np.polyfit(x, accelerate, 3)
# yvals=np.polyval(z1,x)
p1 = np.poly1d(z1)
print(p1) # 在屏幕上打印拟合多项式
yvals = p1(x) # 也可以使用yvals=np.polyval(z1,x)

time_stamp = [np.datetime64(x) for x in time_stamp]

plt.close('all') # 关闭图片
plt.figure(figsize=(100, 5))
plt.rcParams['figure.dpi'] = 400
plt.plot(time_stamp, accelerate)
plt.plot(time_stamp, yvals)
plt.show()
