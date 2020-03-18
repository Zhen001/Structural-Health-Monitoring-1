Eigensystem realization Algorithm - ERA Demo



特征系统实现法(Eigensystem realization algorithm,ERA)算法toolbox for matlab Demo ver

%   By Yi, Chen -  24th Jan.,2004
%  State Key lab of Mechanical Transmission , Chonqqing University
%  leo.chen.yi@gmail.com

#Input Data

1. YData ----------------------M*N输出测点响应矩阵
                                (MIMO) 如：一个点响应则为1*n的时间序列
2. sampling_time---------------采样时间
3. sampling_frequencyHz--------采样频率

# Output Data

4. System_Eigenvalue-----------用ERA算法得到的系统特征参数
5. System_Shape----------------用ERA算法得到的系统振型
6. MAC----------------------------------模态幅值相干系数，[0,1], MAC(I)-->1 ，则处于I阶系统模态;若MAC(I)-->0，则处于噪声模态;
7.MPC-----------------------------------模态相位共线性,[0,1], MPC(I)-->1 ，则处于I阶系统模态(小阻尼);若MPC(I)-->0，则处于噪声模态或复模态(大阻尼);
#m.files
8.ERA-----------------------------------ERA 实现函数
9. ERA_StartDemo-------------------- ERA 主程序
10. sindata_generater------------------与9.配套的正弦信号产生测试程序
