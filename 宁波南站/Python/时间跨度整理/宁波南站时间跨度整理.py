# -*-coding:utf-8-*-
# author:ZhuHaitao

import os
import xlwt
from datetime import datetime

# 选择要处理的数据
option = 4
if option == 1:
    main_path = r'G:\研一下\宁波站数据\Export-x-accelerate'
    xls_path = r'E:\【论文】\【小论文】\宁波南站\数据整理\NBNZ-x-accelerate-精确版.xls'
elif option == 2:
    main_path = r'G:\研一下\宁波站数据\Export-y-accelerate'
    xls_path = r'E:\【论文】\【小论文】\宁波南站\数据整理\NBNZ-y-accelerate-精确版.xls'
elif option == 3:
    main_path = r'G:\研一下\宁波站数据\Export-z-accelerate'
    xls_path = r'E:\【论文】\【小论文】\宁波南站\数据整理\NBNZ-z-accelerate-精确版.xls'
elif option == 4:
    main_path = r'G:\研一下\宁波站数据\Export-windspeed'
    xls_path = r'E:\【论文】\【小论文】\宁波南站\数据整理\NBNZ-windspeed-精确版.xls'

# Function-设置表格样式
def set_style(name, font_height, bold=False):
    al = xlwt.Alignment()
    al.horz = 0x02  # 设置水平居中
    al.vert = 0x01  # 设置垂直居中
    style = xlwt.XFStyle()
    font = xlwt.Font()
    font.name = name
    font.bold = bold
    font.color_index = 4
    font.height = font_height
    style.font = font
    style.alignment = al
    return style

font_height = 280
col_width = 45
row_height = 450
book = xlwt.Workbook(encoding='utf-8', style_compression=0)
sheet = book.add_sheet('宁波站数据整理', cell_overwrite_ok=True)

# 时间跨度整理
for j in range(len(os.listdir(main_path))):
    folder = os.listdir(main_path)[j]
    sub_path = main_path + '\\' + folder
    files_raw = os.listdir(sub_path)
    files_raw = [i for i in files_raw if 'STD' not in i and 'RMS' not in i
                 and 'errorTime' not in i and '十分钟风速数据' not in i] # 排除非数据项
    files = []
    for i in range(len(files_raw)):
        file_path = sub_path + '\\' + files_raw[i]
        if os.path.getsize(file_path)/(1024^2) > 250:
            files.append(datetime.strptime(files_raw[i].split('.')[0], '%Y-%m-%d'))
        else:
            pass
    files.sort()

    periods = []
    start = files[0]
    old = start

    for new in files:
        if new == files[-1]:
            interval = str((new - start).days + 1)
            content = start.strftime(format='%m-%d') + '至' + new.strftime(format='%m-%d') + '：连续' + interval + '天'
            periods.append(content)
        elif (new - old).days == 1:
            old = new
        else:
            if (old - start).days > 0:
                interval = str((old - start).days + 1)
                interrupt = str((new - old).days - 1)
                content = start.strftime(format='%m-%d') + '至' + old.strftime(format='%m-%d') + '：连续' + interval + '天'
                periods.append(content)
                content = '中断 ' + interrupt + ' 天'
                periods.append(content)
                start = new
                old = new
            elif (old - start).days == 0:
                periods.append(start.strftime(format='%Y-%m-%d'))
                start = new
                old = new
            else:
                print('Error')
    periods[0] = str(folder)

    for k in range(len(periods)):
        sheet.write(k, j, periods[k], set_style('Times New Roman', font_height, False))
        tall_style = xlwt.easyxf('font:height ' + str(row_height))
        sheet.row(k).set_style(tall_style)
        sheet.col(j).width = 256 * col_width

# 保存表格
book.save(xls_path)
