# -*-coding:utf-8-*-
# author:ZhuHaitao
import os


def replace_sth_in_all_files(folder_path):
    file_list = os.listdir(folder_path)
    for file in file_list:
        file_path = folder_path + '\\' + file
        if os.path.isdir(file_path):
            replace_sth_in_all_files(file_path)
        else:
            if file.split('.')[-1] in ['bat', 'js']:
                try:
                    with open(file_path, 'r', encoding='utf8') as f:
                        content = f.read()
                    content_replaced = content.replace('F:\\MongoDB',  'E:\\NBNZ\\MongoDB')
                    with open(file_path, 'w', encoding='utf8') as f:
                        f.write(content_replaced)
                    print(file)
                except:
                    pass


folder_path = 'E:\\NBNZ'
replace_sth_in_all_files(folder_path)


