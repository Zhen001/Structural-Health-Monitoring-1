# -*-coding:utf-8-*-
# author:ZhuHaitao

import os

# Function-更改文件后缀
def change_file_suffix(old_suffix, new_suffix, file_path):
    new_file_path = file_path.replace('.'+old_suffix, '.'+new_suffix)
    os.rename(file_path, new_file_path)
    return(new_file_path)

# Function-替换字符串
def replace_something(old, new, main_path):
    file_in_main_path = os.listdir(main_path)
    for file in file_in_main_path:
        file_path = main_path + '\\' + file
        if os.path.isdir(file_path):
            replace_something(old, new ,file_path)
        elif file.split('.')[-1] in ['m']:
            new_file_path = change_file_suffix(file.split('.')[-1], 'txt', file_path)
            with open(new_file_path, 'r', encoding='gbk') as f:
                content = f.read()
            # 判断是否需要替换
            old_in_content = content.find(old) # 检测content里是否有old，没有，则根本不用替换
            new_in_content = content.find(new) # 检测content里是否已经有new，如果有了，则很大可能替换过了，不必再替换
            new_in_old = old.find(new)  # 检测old是不是已经包含了new，如果包含，则是以大换小，通过，否则是以小换大，会把大的搞重复
            if old_in_content == -1: print(file_path, '没有需要更改的地方'); change_file_suffix('txt', file.split('.')[-1], new_file_path); continue
            if new_in_content != -1:
                if new_in_old != -1:
                    content_replaced = content.replace(old, new)
                else:
                    print(file_path, '已经正确了无需更改'); change_file_suffix('txt', file.split('.')[-1], new_file_path); continue
            else:
                content_replaced = content.replace(old, new)
            # 存入替换后的文档
            with open(new_file_path, 'w', encoding='gbk') as f:
                f.write(content_replaced)
            change_file_suffix('txt', file.split('.')[-1], new_file_path)
            print(file_path,'已成功更改')

# Main
if_reversal = 0 # 是否交换 old 和 new
option = 5

if option == 1:
    old = 'G:\\\\研一下\\\\宁波站数据'
    new = 'G:\\\\研一下\\\\宁波站数据\\\\已拉回零均值'
    if if_reversal: [old, new] = [new, old]
elif option ==2:
    old = 'A-W-GGL1-2-Xx-accelerate'
    new = 'A-W-ZD-1-Xx-accelerate'
    if if_reversal: [old, new] = [new, old]
elif option == 3:
    old = 'if_python = 0'
    new = 'if_python = 1'
    if if_reversal: [old, new] = [new, old]
elif option == 4:
    old = '-dpng'
    new = '-dmeta'
    if if_reversal: [old, new] = [new, old]
elif option == 5:
    old = 'if_log = 1'
    new = 'if_log = 2'
    if if_reversal: [old, new] = [new, old]


main_path = r'E:\【论文】\【小论文】\宁波南站\Matlab脚本'
replace_something(old, new, main_path)
