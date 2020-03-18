# -*-coding:utf-8-*-
# author:ZhuHaitao

# 参数设定
import os
import numpy as np
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import Matern

if_Google_Drive = 0  # 是否从Google_Drive上加载文件
if_pycharm = 0  # 是否在pycharm上操作
have_calculated = 0  # 是否已经在本地计算机上算过了
interval = 10  # 10分钟
interval_1 = 30  # 阵风持续时间3秒*10（采样频率）
start_time_main = '2011-08-06 13:13'  # 和上面单位一致，到分钟
end_time_main = '2011-08-07 05:03'
pictures_path = 'E:\\【论文】\\【小论文】\\航博\\Pictures\\'  # 图片保存位置

# Function-判断变量是否已经加载
def if_var_exists(var):
    var_exists = var in locals() or var in globals()
    return var_exists

# 加载文件
if if_Google_Drive:
    file_path = 'drive/My Drive/论文/航博/wind/'
    # This will prompt for authorization
    from google.colab import drive
    drive.mount('/content/drive')
else:
    original_data_path = 'E:/【论文】/【小论文】/航博/航博数据/wind/梅花-E.csv'
    file_path = 'E:/【Gogle Drive】/【Google 云端硬盘】/论文/航博/wind/'

excel_path = file_path + '%d分钟数据.xlsx' % interval  # Excel保存位置

# 在本地计算机上加载文件并计算
if not if_Google_Drive and not have_calculated:
    # 读取文件
    with open(original_data_path) as f:
        data = pd.read_csv(f, index_col='Date', parse_dates=True)  # 将Date作索引，并且使日期可解析

    # 计算x,y,z方向实时风速
    ux = data['A.3D Wind Speed u'] * np.cos(np.deg2rad(data['A.Elevation'])) * np.sin(np.deg2rad(data['A.Azimuth']))
    uy = data['A.3D Wind Speed u'] * np.cos(np.deg2rad(data['A.Elevation'])) * np.cos(np.deg2rad(data['A.Azimuth']))
    uz = data['A.3D Wind Speed u'] * np.sin(np.deg2rad(data['A.Elevation']))
    data = data.drop(['Offset', 'Schedule', 'A.Azimuth', 'A.Elevation', 'A.Sonic Temp'], axis=1)  # 删除不需要的数据
    data.rename(columns={'A.3D Wind Speed u': '3Dspeed'}, inplace=True); data['ux'] = ux; data['uy'] = uy; data['uz'] = uz

    # 计算x,y,z方向平均风速（高斯过程回归）
    #     time_stamp = []; ux_mean = []; uy_mean = []; uz_mean = []
    start_time = np.datetime64(start_time_main); end_time = np.datetime64(end_time_main)
    data = data[start_time: end_time]
    time_series = data.index
    data_sample = data.sample(1000)
    time_stamp_sample = data_sample.index[:, np.newaxis]
    gp_kernel = 1.0 * Matern(length_scale=1, length_scale_bounds=(1e-2, 1e2), nu=1.5)
    gpr = GaussianProcessRegressor(alpha=1, kernel = gp_kernel, random_state=None)\
          .fit(time_stamp_sample,data_sample['ux'])
    y_pred, sigma = gpr.predict(time_series[:, np.newaxis], return_std=True)

    plt.figure(figsize=(20, 5))
    plt.rcParams['savefig.dpi'] = 600  # 图片像素
    plt.rcParams['figure.dpi'] = 600  # 分辨率
    plt.plot(time_series, data['ux'], 'o', markersize=0.5, label=u'Observations')
    plt.plot(time_series, y_pred, '-', label=u'Prediction')
    plt.fill_between(time_series, y_pred - 1.9600 * sigma, y_pred + 1.9600 * sigma,
                     alpha=0.3, color='k', label='95% confidence interval')
    plt.ylabel('$RMS$')
    plt.xlim(0, 1440)
    plt.legend(loc='upper left')
    plt.show()

