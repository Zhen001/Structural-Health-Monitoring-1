# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import matlab.engine
engine_list = matlab.engine.find_matlab()

# 如果已经存在会话，就不必新开一个
if len(engine_list):
    try:
        engine = matlab.engine.connect_matlab(engine_list[-1])
    except:
        engine = matlab.engine.start_matlab()
else:
    engine = matlab.engine.start_matlab()

# Function-找到main_path下所有的m文件的路径
def find_all_file_path(main_path):
    file_path_list = []
    file_in_main_path = os.listdir(main_path)
    for file in file_in_main_path:
        file_path = main_path + '\\' + file
        if os.path.isdir(file_path):
            file_path_list += find_all_file_path(file_path)
        else:
            file_path_list.append(file_path)
    return file_path_list

# Function-执行Matlab代码
def run_m(m_path):
    main_path = '\\'.join(m_path.split('\\')[:-1])
    name = m_path.split('\\')[-1].split('.')[0]
    engine.cd('E:\\【论文】\\【小论文】\\宁波南站\\脚本控制器\\操控Matlab')
    engine.Control_Matlab(main_path, name)

# Main
m_path = r'E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD\NBNZ_Months_STD.m'
main_path = r'E:\【论文】\【小论文】\宁波南站\Matlab脚本'
m_path_list = find_all_file_path(main_path)
m_path_list = [x for x in m_path_list if '.m' in x and 'NBNZ_Day_Original.m' not in x and 'GaussFit.m' not in x and 'GaussFit_test.m' not in x and 'NBNZ_Day_RMS.m' not in x and 'NBNZ_GaussFit_RMS.m' not in x]
for m_path in m_path_list:
    print(m_path)
    run_m(m_path) 

