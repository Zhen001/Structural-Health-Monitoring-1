# -*-coding:utf-8-*-
# author:ZhuHaitao

from datetime import datetime
import os
import sched
import time


def timeTask():
    # 初始化 sched 模块的 scheduler 类
    scheduler = sched.scheduler(time.time, time.sleep)
    # 增加调度任务
    scheduler.enter(5, 1, task)
    # 运行任务
    scheduler.run()

# 检测文件大小，单位M
def getFileSize(filePath, size=0):
    for root, dirs, files in os.walk(filePath):
        for f in files:
            size += os.path.getsize(os.path.join(root, f))
    return size/1024/1024


# 定时任务
def task():
    a = datetime.now().strftime("%d %H %M ")
    # b1 = '%.2f' % (getFileSize(r'F:\Office'))
    # b2 = '%.2f' % (getFileSize(r'F:\软件'))
    # b3 = '%.2f' % (getFileSize(r'F:\Pictures'))
    b1 = '%.2f' % (getFileSize(r'F:\NbNanzhan\task\data'))
    b2 = '%.2f' % (getFileSize(r'D:\Export-windspeed'))
    b3 = '%.2f' % (getFileSize(r'D:\Export-x-accelerate'))
    c1 = a+b1+'\n'
    c2 = a+b2+'\n'
    c3 = a+b3+'\n'
    with open(r'F:\z-accelerate.txt', 'a', encoding='utf8') as f1:
        f1.writelines(c1)
    with open(r'F:\windspeed.txt', 'a', encoding='utf8') as f2:
        f2.writelines(c2)
    with open(r'F:\x-accelerate.txt', 'a', encoding='utf8') as f3:
        f3.writelines(c3)


if __name__ == '__main__':
    if_it_is_the_time = True
    while if_it_is_the_time:
        if time.strftime('%d.%H.%M.%S', time.localtime(time.time())).split('.', 3)[-1] == '00':
            if_it_is_the_time = False
    print(time.strftime('%d.%H.%M.%S', time.localtime(time.time())))
    task()
    while True:
        timeTask()

