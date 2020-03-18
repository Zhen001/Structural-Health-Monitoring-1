# -*-coding:utf-8-*-
# author:ZhuHaitao

import pandas as pd
import numpy as np
import time
start = time.time()
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
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

# 参数设定
if_log = 1
reject_method = 1
if_Matlab = 1

# 读取数据
RMS_path = r'E:\【论文】\【小论文】\宁波南站\Python脚本\GPR\2014-09-15 to 2014-12-11的所有RMS.txt'
with open(RMS_path, 'r', encoding='utf-8') as f:
    data = pd.read_csv(f, sep=' ', header=None)

# 3σ法则
if reject_method:
    new_data = pd.DataFrame([])
    for ii in range(1,1441):
        temp_data = data[data.iloc[:,0]==ii]
        temp_data = temp_data[(temp_data.iloc[:,1]-temp_data.iloc[:,1].mean()).abs() <3* temp_data.iloc[:,1].std()]
        new_data = pd.concat([new_data,temp_data], ignore_index=True)
    data = new_data

# 是否取对数
if if_log:
    data.iloc[:,1] = np.log(data.iloc[:,1])


time_series = np.array(range(1,1441))
time_stamp = np.array(data.iloc[:, 0])
RMS = np.array(data.iloc[:, 1])

if if_Matlab:
    # 高斯过程回归Matlab
    engine.cd('E:\\【论文】\\【小论文】\\宁波南站\\Matlab脚本\\GPR')
    engine.GaussianProcessRegression(matlab.double(time_stamp.tolist())[0], matlab.double(RMS.tolist())[0], matlab.double(time_series.tolist())[0])
else:
    # 高斯过程回归Python
    # 抽取子集
    data_sample = data.sample(3000)
    time_stamp_sample = np.array(data_sample.iloc[:, 0])
    RMS_sample = np.array(data_sample.iloc[:, 1])
    # 高斯回归
    from sklearn.gaussian_process import GaussianProcessRegressor
    from sklearn.gaussian_process.kernels import Matern
    gp_kernel = 1.0 * Matern(length_scale=1, length_scale_bounds=(1e-2, 1e2), nu=1.5)
    gpr = GaussianProcessRegressor(alpha=1, kernel = gp_kernel, random_state=None).fit(time_stamp_sample.reshape(-1, 1),RMS_sample)
    y_pred, sigma = gpr.predict(time_series[:, np.newaxis], return_std=True)
    # 绘图
    plt.figure(figsize=(20, 5))
    plt.rcParams['savefig.dpi'] = 600 #图片像素
    plt.rcParams['figure.dpi'] = 600 #分辨率
    plt.plot(time_stamp, RMS, 'o', markersize=0.5, label=u'Observations')
    plt.plot(time_series, y_pred, '-', label=u'Prediction')
    plt.fill_between(time_series, y_pred - 1.9600*sigma, y_pred + 1.9600*sigma, alpha=0.3, color='k', label='95% confidence interval')
    plt.ylabel('$RMS$')
    plt.xlim(0, 1440)
    plt.legend(loc='upper left')
    plt.show()

print(str(time.time()-start) + "秒")