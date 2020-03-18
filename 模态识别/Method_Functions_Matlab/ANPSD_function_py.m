% PP法模态参数识别
function [f,ANPSD,locs,pks] = ANPSD_function_py(response,Fs,varargin)

% if ~matlab.engine.isEngineShared
%     matlab.engine.shareEngine()
% end

%% 参数说明
% response：可以是多列时域信号（每列代表一个测点）
% Fs：采样频率

p = inputParser();                      
p.CaseSensitive = false;                % 不关心参数大小写
p.addOptional('filtering', [0,0]);      % filtering: 滤波，通带范围
p.addOptional('PSDfangfa', 1);          % PSDfangfa：选择要使用的方法，1为周期图法，2为多个周期图平均法（需手动调整）
p.addOptional('m', 4);                  % m：平均周期图法的平分数
p.addOptional('if_log', 0);             % if_log：是否对结果取对数
p.addOptional('draw', 0);               % draw：是否作图
p.addOptional('percent', 10);           % percent：峰值下限取最高点的百分之几
p.addOptional('minpeakdist', 0.01);     % minpeakdist：峰值之间最小距离
p.addOptional('new_f', 0);              % new_f：降采样频率（避免滤波时数据溢出），也可用于增采样

p.parse(varargin{:});
filtering = p.Results.filtering;
PSDfangfa = p.Results.PSDfangfa;
m = p.Results.m;
if_log = p.Results.if_log;
draw = p.Results.draw;
percent = p.Results.percent;
minpeakdist = p.Results.minpeakdist; 
new_f = p.Results.new_f; 

%% 1.数据预处理
if size(response,2)>size(response,1)
    response=response';                     % 转成一个测点一列
end 
n=size(response,2);                         % 测点数

% 降采样相关设置
if new_f
    response=resample(response,...
        new_f*1000,Fs*1000);                % 降采样,默认每列单独降采样
    N=size(response,1);                  	% 降采样后的长度
    Fs=new_f;                             	% 将频率替换成降采样频率
else
    N=size(response,1);                 	% 原始数据长
end

% 滤波  
if sum(filtering ~= [0,0])
    fs2=Fs/2;                               % 奈奎斯特频率
    Wp=filtering(1);                        % 通带频率（需手动调整）
    Ws=filtering(2);                        % 阻带频率（需手动调整）
    Wp=Wp/fs2;                              % 归一化通带频率
    Ws=Ws/fs2;                              % 归一化阻带频率
    Rp=1;                                   % 通带波纹
    Rs=50;                                  % 阻带衰减
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs);       % 求滤波器原型阶数和带宽
    [bn1,an1]=butter(jieshu,Wn);            % 求数字滤波器系数
    response=filter(bn1,an1,response);      % 对数据进行滤波，默认每列单独滤波
end

% % 消除工频50HZ
% fs2=Fs/2;                                 % 设置奈奎斯特频率
% W0=50/fs2;                                % 陷波器中心频率
% BW=0.005;                                 % 陷波器带宽 
% [b,a]=iirnotch(W0,BW);                    % 设计IIR数字陷波器
% response=filter(b,a,response);            % 对信号滤波
% % 消除0HZ
% fs2=Fs/2;                                 % 设置奈奎斯特频率
% W0=0.01/fs2;                              % 陷波器中心频率
% BW=0.005;                                 % 陷波器带宽 
% [b,a]=iirnotch(W0,BW);                    % 设计IIR数字陷波器
% response=filter(b,a,response);            % 对信号滤波
% % 消除工频150HZ
% fs2=Fs/2;                                 % 设置奈奎斯特频率
% W0=150/fs2;                               % 陷波器中心频率
% BW=0.005;                                 % 陷波器带宽 
% [b,a]=iirnotch(W0,BW);                    % 设计IIR数字陷波器
% response=filter(b,a,response);            % 对信号滤波
  
%% 2.预分配内存、平均周期图窗口长度设置
if PSDfangfa==2
    N2=floor(N/m);                                            % 平均周期图窗口长度（方法2）
    if mod(N2,2)==1,N2=N2+1;end
    PSD=zeros(floor((N2/2)+1),n); f=zeros(floor((N2/2)+1),n); % 预分配内存（方法2）
elseif PSDfangfa==1
    PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % 预分配内存（方法1） 
end

%% 3.依次用各测点数据计算PSD
for i=1:n
    x=response(:,i);
    if PSDfangfa==1                         % 1.周期图法（Periodogram）
        window=hamming(N);                	% 选择一种窗函数
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),Fs);
    elseif PSDfangfa==2                  	% 2.多个周期图平均法（Welch）
        window=hamming(N2);                 % 选择一种窗函数
        noverlap=N2/2;                      % 分段序列重叠的采样点数（长度）
        range='onesided';                   % 单边谱
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,Fs,range);  
    end
end

%% 4.计算平均正则化功率谱密度ANPSD
ANPSDs=0;
for i=1:n
    ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i));   % 正则化
    % ANPSDs=ANPSDs+PSD(:,i);               % 不正则化
end

%% 5.是否取对数，并作平均
if if_log
    ANPSD=log10(ANPSDs/n);                  % 对数方式
else
    ANPSD=ANPSDs/n;                         % 非对数
end 

%% 6.绘图
if draw
    xlimt=[0,10];                           % 绘图范围（需手动调整）
    interval=1;                             % 横坐标间隔（需手动调整）

% 绘制ANPSD
    figure
    h1=plot(f,ANPSD,'Color',[0.3 0.5 0.7],'LineWidth',0.8); 
    grid on; box on; xlim(xlimt); MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]);   % 控制出图背景色和大小
    Xlims=get(gca,'Xlim'); Ylims=get(gca,'Ylim'); set(gca,'XTick',0:interval:Xlims(2))
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-2.5 0 2.5 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); % 去除figure中多余的空白部分，注意，在设置坐标label之前做这件事可以避免麻烦
    title('平均正则化功率谱密度ANPSD','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[mean(Xlims) Ylims(2)+0.02*diff(Ylims)])
    xlabel('频率/Hz','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.04*diff(Ylims)])
    ylabel('功率谱密度/(dB/Hz)','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Xlims(1)-0.05*diff(Xlims) mean(Ylims)])
end

% 找峰值
if draw; display=0.5; else; display=0; end                  % 如何作峰值图，0时不做图；0.5时不做内衬线；1时做全图
minpeakh=(max(ANPSD)-min(ANPSD))/100*percent+min(ANPSD);    % 峰值下限
[locs,pks]=peakseek(f,ANPSD,minpeakdist,minpeakh,display);  % 找峰值
if draw
    legend(h1,'ANPSD','FontName','华文仿宋','FontSize',15) ;legend('boxoff');
end

%% 7.返回值处理，转成行向量
f = f'; 
ANPSD = ANPSD';
locs= locs';
pks = pks';

