% PP法模态参数识别
function [f,ANPSD] = ANPSD_function(response,Fs,PSDfangfa,m,duishu)

% 参数说明
% response：可以是多列时域信号（每列代表一个测点）
% Fs：采样频率
% PSDfangfa：选择要使用的方法，1为周期图法，2为多个周期图平均法（需手动调整）
% m：平均周期图法的平分数
% duishu：是否对结果取对数

%% 1.数据预处理
if size(response,2)>size(response,1); response=response'; end

%% 2.相关设值
% 数据处理开关
jcy=0;                    % 是否降采样（避免滤波时数据溢出）（需手动调整）
lvbo=0;                   % 是否滤波（需手动调整）
n=size(response,2);       % 测点数量
% 降采样相关设置
x1=response(:,1);                             % 随便抽取一列数据，非正式计算内容
x1=x1-mean(x1);                               % 去除平均趋势项
if jcy
    pinlv_jiangcaiyang=256;                   % 降采样频率（需手动调整）
    x1=resample(x1,pinlv_jiangcaiyang,Fs);    % 降采样,默认每列单独降采样
    N=length(x1);                             % 降采样后的长度
else
    N=length(x1);                             % 原始数据长
end
% 预分配内存、平均周期图窗口长度设置
PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % 预分配内存（方法1） 
if PSDfangfa==2
    N2=floor(N/m);                                        % N2:多个周期图平均法（Welch）窗口长度
    if mod(N2,2)==1,N2=N2+1;end
end
% % 画时程曲线
% fanwei=1:length(x1);          % 方便灵活调整时程曲线范围
% t=1:length(x1);
% plot(t(fanwei),x1(fanwei))

%% 3.依次将各测点数据转成PSD
for i=1:n
    fs=Fs;                    % 如果不降采样，就取原值
    x=response(:,i);
% 3.1 降采样
    if jcy
        x=resample(x,pinlv_jiangcaiyang,Fs);   % 降采样,默认每列单独降采样
        fs=pinlv_jiangcaiyang;                 % 将频率替换成降采样频率
    end 
% 3.2 滤波  
%     % 消除工频50HZ
%     fs2=fs/2;                          % 设置奈奎斯特频率
%     W0=50/fs2;                         % 陷波器中心频率
%     BW=0.005;                          % 陷波器带宽 
%     [b,a]=iirnotch(W0,BW);             % 设计IIR数字陷波器
%     x=filter(b,a,x);                   % 对信号滤波
%     
%     % 消除0HZ
%     fs2=fs/2;                          % 设置奈奎斯特频率
%     W0=0.01/fs2;                       % 陷波器中心频率
%     BW=0.005;                          % 陷波器带宽 
%     [b,a]=iirnotch(W0,BW);             % 设计IIR数字陷波器
%     x=filter(b,a,x);                   % 对信号滤波
    
%     % 消除工频150HZ
%     fs2=fs/2;                          % 设置奈奎斯特频率
%     W0=150/fs2;                        % 陷波器中心频率
%     BW=0.005;                          % 陷波器带宽 
%     [b,a]=iirnotch(W0,BW);             % 设计IIR数字陷波器
%     x=filter(b,a,x);                   % 对信号滤波
     
    if lvbo
        fs2=fs/2;                            % 奈奎斯特频率
        fp1=[40 110];                        % 通带频率（需手动调整）
        fs1=[35 120];                        % 阻带频率（需手动调整）
        wp1=fp1/fs2;                         % 归一化通带频率
        ws1=fs1/fs2;                         % 归一化阻带频率
        Ap=3; As=30;                         % 通带波纹和阻带衰减（需手动调整）
        [jieshu,Wn]=buttord(wp1,ws1,Ap,As);  % 求滤波器原型阶数和带宽
        [bn1,an1]=butter(jieshu,Wn);         % 求数字滤波器系数
        x=filter(bn1,an1,x);                 % 对数据进行滤波，默认每列单独滤波
    end
% 3.3 计算功率谱密度PSD
    window=hamming(N);                      % 选择一种窗函数
    if PSDfangfa==1                         % 1.周期图法（Periodogram）
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),fs);
    elseif PSDfangfa==2                  	% 2.多个周期图平均法（Welch）
        noverlap=N2/2;                      % 分段序列重叠的采样点数（长度）
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N,fs,'onesided');  
    end
end
end

%% 4.计算平均正则化功率谱密度ANPSD
ANPSDs=0;
for i=1:n
    % ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i)); % 正则化
    ANPSDs=ANPSDs+PSD(:,i)/n; % 平均化
end

%% 5.是否取对数
if duishu
    ANPSD=10*log10(ANPSDs/n);       % 对数方式
else
    ANPSD=ANPSDs/n;                 % 非对数
end 

