% % 注意：此处计算的是风的实测谱而非PSD
function [f,ANPSD] = ANPSD_function_for_wind(response,Fs,PSDfangfa,m,if_log,draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% 参数说明
% response：可以是多列时域信号（每列代表一个测点）
% Fs：采样频率
% PSDfangfa：选择要使用的方法，1为周期图法，2为多个周期图平均法（需手动调整）
% m：平均周期图法的平分数
% if_log：是否对结果取对数
% draw：是否作图
% percent：峰值下限取最高点的百分之几
% minpeakdist：峰值之间最小距离

%% 1.数据预处理
if size(response,2)>size(response,1); response=response'; end

%% 2.相关设值
% 数据处理开关
jcy=0;                                        % 是否降采样（避免滤波时数据溢出）（需手动调整）
n=size(response,2);                           % 测点数量
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
if PSDfangfa==2
    N2=floor(N/m);                            % 平均周期图窗口长度（方法2）（需手动调整）
    if mod(N2,2)==1,N2=N2+1;end
    PSD=zeros(floor((N2/2)+1),n); f=zeros(floor((N2/2)+1),n); % 预分配内存（方法2）
elseif PSDfangfa==1
    PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % 预分配内存（方法1） 
end

%% 3.依次将各测点数据转成PSD
for i=1:n
    fs=Fs;                                     % 如果不降采样，就取原值
    x=response(:,i);
% 3.1 降采样
    if jcy
        x=resample(x,pinlv_jiangcaiyang,Fs);   % 降采样,默认每列单独降采样
        fs=pinlv_jiangcaiyang;                 % 将频率替换成降采样频率
    end 
% 3.3 计算功率谱密度PSD
    if PSDfangfa==1                                  % 1.周期图法（Periodogram）
        window=hamming(N);                           % 选择一种窗函数
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),fs);
        PSD(:,i)=f.*PSD(:,i)./(var(x));
    elseif PSDfangfa==2                              % 2.多个周期图平均法（Welch）
        window=hamming(N2);                          % 选择一种窗函数
        noverlap=N2/2;                               % 分段序列重叠的采样点数（长度）
        range='onesided';                            % 单边谱
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,fs,range);
        PSD(:,i)=f.*PSD(:,i)./(var(x));              % 注意：此处计算的是实测谱而非PSD
    end
end

%% 4.计算平均正则化功率谱密度ANPSD
ANPSD=mean(PSD,2);

%% 5.是否取对数，并作平均
if if_log
    ANPSD=log10(ANPSD);       % 对数方式
    f=log10(f);
end 

%% 6.绘图
if draw
    xlimt=[0,1];                            % 绘图范围（需手动调整）
    interval=1;                              % 横坐标间隔（需手动调整）

    % 绘制ANPSD
    figure
    h1=plot(f,ANPSD,'Color',[0.3 0.5 0.7],'LineWidth',0.8); 
    grid on; box on; xlim(xlimt); MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % 控制出图背景色和大小
    Xlims=get(gca,'Xlim'); Ylims=get(gca,'Ylim'); set(gca,'XTick',0:interval:Xlims(2))
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-2.5 0 2.5 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); % 去除figure中多余的空白部分，注意，在设置坐标label之前做这件事可以避免麻烦
    title('平均正则化功率谱密度ANPSD','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[mean(Xlims) Ylims(2)+0.02*diff(Ylims)])
    xlabel('频率/Hz','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.04*diff(Ylims)])
    ylabel('功率谱密度/(dB/Hz)','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Xlims(1)-0.05*diff(Xlims) mean(Ylims)])
end

%% 7.返回值处理
f = f';
ANPSD = ANPSD';

