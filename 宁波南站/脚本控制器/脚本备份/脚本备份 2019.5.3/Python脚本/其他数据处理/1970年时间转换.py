# -*-coding:utf-8-*-
# author:ZhuHaitao
import time
timestamp = 1388484000100

timestamp = timestamp / 1000
haomiao = timestamp - int(timestamp)
haomiao = ('%.3f' % haomiao).split('.')[-1]
timeArray = time.localtime(timestamp)  # 1970秒数
otherStyleTime = time.strftime("%Y-%m-%d@%H:%M:%S", timeArray)
timestamp = otherStyleTime + '.' + haomiao
print(timestamp)
input()
