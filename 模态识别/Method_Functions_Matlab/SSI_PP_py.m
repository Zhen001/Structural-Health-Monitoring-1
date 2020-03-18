% Fs=250; 
% filename1=fopen('G:\文档\研一上\邢哲师兄论文\硕士学位论文\正文\第2章\300N-1e-6s-250Hz.txt','r');
% response=textscan(filename1,'%f %f %f %f','Headerlines',7);
% response=cell2mat(response);  
% [FFFF,DAMP2,VVV,f,ANPSD,locs,pks] = SSI_PP_py(response,Fs);


function [FFFF,DAMP2,VVV,f,ANPSD,locs,pks] = SSI_PP_py(response,Fs,varargin)
close all

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

%% 1.相关设值
% response：可以是多列时域信号（每列代表一个测点）
% Fs：采样频率

p = inputParser();                      
p.CaseSensitive = false;                % 不关心参数大小写
p.addOptional('filtering', [0,0]);      % filtering: 滤波，通带范围
p.addOptional('new_f', 0);              % new_f：降采样频率（避免滤波时数据溢出），也可用于增采样
p.addOptional('PP', 1);                 % 是否同时画PP图
p.addOptional('PSDfangfa', 1);          % PSDfangfa：选择要使用的方法，1为周期图法，2为多个周期图平均法（需手动调整）
p.addOptional('m', 4);                  % m：平均周期图法的平分数
p.addOptional('if_log', 0);             % if_log：是否对结果取对数
p.addOptional('draw', 1);               % draw：是否作图
p.addOptional('percent', 10);           % percent：峰值下限取最高点的百分之几
p.addOptional('minpeakdist', 0.01);     % minpeakdist：峰值之间最小距离
p.addOptional('Xrange', [0,120]);     	% Xrange：绘图范围
p.addOptional('mode_number', 4);        % interval：要提取的阶数

p.parse(varargin{:});
filtering = p.Results.filtering;
new_f = p.Results.new_f; 
PP = p.Results.PP; 
PSDfangfa = p.Results.PSDfangfa;
m = p.Results.m;
if_log = p.Results.if_log;
draw = p.Results.draw;
percent = p.Results.percent;
minpeakdist = p.Results.minpeakdist; 
Xrange = p.Results.Xrange;
mode_number = p.Results.mode_number;

class(response)
size(response)
%% 2.数据预处理
if size(response,2)>size(response,1)
    response=response';                     % 转成一个测点一列
end 
response(:,1)=[];                           % （共用）如果第一列为时间序列，则执行此行代码
num=size(response,2);                       % 测点数

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
%     Wp=[55 100];                            % 通带频率（需手动调整）
%     Ws=[45 105];                            % 阻带频率（需手动调整）
    Wp=filtering(1);                        % 通带频率（需手动调整）
    Ws=filtering(2);                        % 阻带频率（需手动调整）
    Wp=Wp/fs2;                              % 归一化通带频率
    Ws=Ws/fs2;                              % 归一化阻带频率
    Rp=3;                                   % 通带波纹
    Rs=30;                                  % 阻带衰减
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

%% 4.SSI随机子空间&作图
i=100;                                          % i为块行数，越大算的越细
J=[1 50];                                       % N为给定阶数范围
dn=1;                                           % dn为计算稳定图的隔行数，越小算的越细
s=1;                                            % s为数据分段数，越小算的越细
[FFF,DAMP1,VV]=SSI(response,Fs,i,J,dn,s,draw); 	% FFF为频率矩阵；DAMP1为阻尼矩阵；VV为振型矩阵
if draw
    figure(2); hold on;
    title('阻尼','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2)
    xlabel('阻尼','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2)
    ylabel('模型阶数','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2)
    
    figure(1); hold on; grid on; box on; 
    title('SSI随机子空间+PP峰值法','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2)
    xlabel('频率/Hz','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2)
    ylabel('模型阶数','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2)
end

%% 5.将频率和振型导入EXCEL
filename2='E:\【论文】\【小论文】\模态识别\Matlab脚本\SSI随机子空间\最终使用\3=1-频率矩阵.xlsx';
delete E:\【论文】\【小论文】\模态识别\Matlab脚本\SSI随机子空间\最终使用\3=1-频率矩阵.xlsx; % 先删除原表格
% 频率矩阵:
FFFF=FFF(1:2:mode_number*2-1,:);             	% 偶数行和奇数行完全一样，所以只取奇数行，并只取前4阶
DAMP2=DAMP1(1:2:mode_number*2-1,:);         	% 偶数行和奇数行完全一样，所以只取奇数行，并只取前4阶
xlswrite(filename2,FFFF,1)
% 振型矩阵:
VVV=zeros(num*mode_number,J(2));
for i=1:num
    for j=1:mode_number
        VVV(mode_number*(i-1)+j,:)=abs(VV(2*j-1,:,i)).*((abs(angle(VV(2*j-1,:,i)))<pi/2)*2-1);
    end
end
xlswrite(filename2,VVV,2)

%% 以下为PP峰值法（ANPSD）

if PP % 是否同时作PP图
    %% 2.预分配内存、平均周期图窗口长度设置
    if PSDfangfa==2
        N2=floor(N/m);                                                  % 平均周期图窗口长度（方法2）
        if mod(N2,2)==1,N2=N2+1;end
        PSD=zeros(floor((N2/2)+1),num); f=zeros(floor((N2/2)+1),num);   % 预分配内存（方法2）
    elseif PSDfangfa==1
        PSD=zeros(floor((N/2)+1),num); f=zeros(floor((N/2)+1),num);     % 预分配内存（方法1） 
    end

    %% 3.依次用各测点数据计算PSD
    for i=1:num
        x=response(:,i);
        if PSDfangfa==1                         % 1.周期图法（Periodogram）
            window=hamming(N);                  % 选择一种窗函数
            [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),Fs);
        elseif PSDfangfa==2                     % 2.多个周期图平均法（Welch）
            window=hamming(N2);                 % 选择一种窗函数
            noverlap=N2/2;                      % 分段序列重叠的采样点数（长度）
            range='onesided';                   % 单边谱
            [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,Fs,range);  
        end
    end

    %% 4.计算平均正则化功率谱密度ANPSD
    ANPSDs=0;
    for i=1:num
        ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i));   % 正则化
    %     ANPSDs=ANPSDs+PSD(:,i);               % 不正则化
    end

    %% 5.是否取对数，并作平均
    if if_log
        ANPSD=log10(ANPSDs/num);                % 对数方式
    else
        ANPSD=ANPSDs/num;                       % 非对数
    end

    %% 6.绘图
    fangda=0.7*50/max(ANPSD);                   % 由于坐标系不同，故将峰值放大
    ANPSD1=fangda*ANPSD;
    if draw
        % 绘制ANPSD
        figure(1)                               % 在第一张图（频率图）上继续画峰值法的图
        hold on;grid on; box on;
        set(gcf,'color','w','unit','centimeters','position',[0 0.6 37 21.5]); % 控制出图背景色和大小
        plot(f,ANPSD1,'k');                     % k是black
        xlim(Xrange);
        title('SSI随机子空间+PP峰值法','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[Fs/4 51])
        xlabel('频率/Hz','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Fs/4 -2])
        ylabel('模型阶数','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[-6*(Fs/400) 25])
    end

    % 找峰值
    if draw; display=0.5; else; display=0; end                              % 如何作峰值图，0时不做图；0.5时不做内衬线；1时做全图
    minpeakh=(max(ANPSD1)-min(ANPSD1))/100*percent+min(ANPSD1);             % 峰值下限
    [locs,pks]=peakseek(f,ANPSD1,minpeakdist,minpeakh,display);             % 找峰值
    fprintf('峰值点对应频率为：\n'); disp(locs)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 以下为子函数部分
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%   SSI 随机子空间法计算模态参数
function [FFF,DAMP1,VV]=SSI(acc,fs,i,N,dn,s,draw)

%   [FFF,DAMP1,VV]=SSI(acc,Fs,i,N,dn,s)
%   输入参数——acc,Fs,i,N,dn,s:
%   acc为输入的数据
%   fs为采样频率；
%   i为块行数；
%   N为计算阶数；
%   dn为计算稳定图的隔行数；
%   s为数据分段数；
%   输出参数——FFF,DAMP1,VV:
%   FFF为频率矩阵；
%   DAMP1为阻尼矩阵；
%   VV为振型矩阵；

if nargin<5;s=1;dn=2; end
if nargin<6;s=1; end
N1=N(1);N2=N(2);

[xs,l]=head(s,acc);

F=zeros(N2,N2/dn);Damp=zeros(N2,N2/dn);V=zeros(N2,N2,l);

for si=1:s
    k=0;x=xs(:,:,si);
    [T1,T2]=TH(x,i);
    [U0,S0,V0]=svd(T1);
    for n=N1:dn:N2
        k=k+1;
        [U1,S1,V1]=sj(n,U0,S0,V0);
        [A,C]=tzz(S1,U1,V1,T2,l);
        [f,v,damp]=mt(A,C,fs);
        for Fi=1:length(f)       % 各阶频率组成矩阵（二维）
            F(Fi,k,si)=f(Fi);
        end
        for Di=1:length(damp)    % 各阶阻尼组成矩阵（二维）
            Damp(Di,k,si)=damp(Di);
        end
        [~,nv]=size(v);          % 各阶振型组成矩阵（三维）
        for Vi=1:nv
            V(Vi,k,:,si)=v(:,Vi);
        end
    end
end
[FFF,~,DAMP1,~,VV]=pl(F,Damp,V,l,N1,N2,dn,s,draw); % 提取各阶数的频率、阻尼、振型

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FFF,FF,DAMP1,DAMP,VV]=pl(F,Damp,V,l,N1,N,dn,s,draw)

% 筛选法（标准）
FF=zeros(N,N/dn);DAMP=zeros(N,N/dn);VV=zeros(N,N/dn,l);
for si=1:s
    for n=1:N/dn-1
        m=0; 
        for m1=1:N
            for m2=1:N
                MAC=abs(F(m1,n,si)-F(m2,n+1,si))/F(m1,n,si);                %第一步筛检(频率)
                if MAC<0.01                                                 %频率限定值1%（根据需要手动调整）
                    MACD=abs(Damp(m1,n,si)-Damp(m2,n+1,si))/Damp(m1,n,si);  %第二步筛检(阻尼)
                    if MACD<0.05                                            %阻尼限定值5%（根据需要手动调整）
                        V1=zeros(l,1);
                        V2=zeros(l,1);
                        for i=1:l
                            V1(i)=V(m1,n,i,si);
                            V2(i)=V(m2,n+1,i,si);
                        end
                        DMACF=abs(V1'*V2)^2/((V1'*V1)*(V2'*V2));            %第三步筛检(振型)
                        MACF=1-DMACF;
                        if MACF<0.02                                        %振型限定值2%（根据需要手动调整）
                            m=m+1;
                            FF(m,n,si)=F(m1,n,si);                          %筛检后的频率矩阵
                            DAMP(m,n,si)=Damp(m1,n,si);                     %筛检后的阻尼矩阵
                            VV(m,n,:,si)=V(m1,n,:,si);                      %筛检后的振型矩阵
                            break
                        end
                    end
                end
            end
        end
    end
end

FFF=zeros(N,N/dn);DAMP1=zeros(N,N/dn);
f=FF;d=DAMP;
if s==1
    FFF=FF;DAMP1=DAMP;
elseif s~=1
    for si=2:s
        for n=1:N/dn-1
            m=0;
            for m1=1:N
                for m2=1:N
                    MAC=abs(f(m1,n,1)-f(m2,n,si));
                    if MAC<10                                               %多次稳定图限定值
                        m=m+1;
                        FFF(m,n)=f(m1,n,1);
                        DAMP1(m,n)=d(m1,n,1);
                        f(m2,n,si)=0;
                        break
                    end
                end
            end
        end
        f(:,:,1)=FFF;
        d(:,:,1)=DAMP1;
    end
end

if draw
    % 绘制多次叠加稳定图（频率稳定图）
    figure                                                                     
    set(gcf,'color','w')
    for n=1:(N-N1)/dn
        for m=1:N
            if FFF(m,n)~=0&&FFF(m,n)<3200/2                                     %频率绘制范围
                scatter(FFF(m,n),N1+dn*(n-1),'o')
                hold on
            end
        end
    end
    maxf=ceil(max(max(FFF)));
    xlabel('频率(Hz)'),ylabel('模型阶数')
    grid on
    set(gca,'Ylim',[0,N]);
    grid on;box on;

    % 绘制多次叠加稳定图（阻尼稳定图）
    figure                                                                      
    set(gcf,'color','w')
    k=0;md=zeros(1);
    for n=1:N/dn
        for m=1:N
            if DAMP1(m,n)>0
                k=k+1;
                md(k)=DAMP1(m,n);
            end
        end
    end
    MD=mean(md);
    maxf=2*MD;
    for n=1:N/dn
        for m=1:N
            if DAMP1(m,n)>0&&DAMP1(m,n)<maxf
                scatter(DAMP1(m,n),n,'o');
                hold on
            end
        end
    end
    title('阻尼')
    grid on;box on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xs,l]=head(s,acc)
    [~, l]=size(acc);
    n=fix(length(acc)/s);
    for si=1:s
        xs(:,:,si)=acc(1+(si-1)*n:si*n,:);
    end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,V,damp]=mt(A,C,fs)
[V,D]=eig(A);
u=diag(D);
r=log(u)*fs;
w=abs(r);
damp=(-real(r))./w;
f=w/(2*pi);
V=C*V;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T1,T2]=TH(x,i)    %形成Toeplitz矩阵 T1、T2
[Y1,Y2]=YH_1(x,i);          %调用YH函数形成Hankel矩阵

[m,~]=size(Y1);
yp1=Y1(1:m/2,:);
yf1=Y1(m/2+1:m,:);
T1=yf1*yp1';

[m,~]=size(Y2);
yp2=Y2(1:m/2,:);
yf2=Y2(m/2+1:m,:);
T2=yf2*yp2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Y1,Y2]=YH_1(x,i) %形成Hankel矩阵 Y1、Y2
%相比原YH函数，对Y1和Y2进行了初始空间分配，对循环内部进行了优化
temp=x';
[j,l]=size(x);   %j为采集数据长度，l为采集通道数
Y1=zeros(2*i*l,j-2*i);Y2=zeros(2*i*l,j-2*i);

for yi=1:2*i
    Y1((yi-1)*l+1:yi*l,:)=temp(:,yi:j-2*i+yi-1);
end
Y1=Y1/sqrt(j-2*i);  %Y1形成T1

for yi=1:2*i
    if yi<i+1
        Y2((yi-1)*l+1:yi*l,:)=temp(:,yi:j-2*i+yi-1);
    else
        Y2((yi-1)*l+1:yi*l,:)=temp(:,yi+1:j-2*i+yi);
    end
end

Y2=Y2/sqrt(j-2*i);   %Y2形成T2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,C]=tzz(S1,U1,V1,T2,l)
A=pinv(U1*S1^(1/2))*T2*pinv(S1^(1/2)*V1');   
O=U1*S1^(1/2);
C=O(1:l,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U1,S1,V1]=sj(n,U,S,V)   %选取阶数，得到缩减后的S1、U1、V1
U1=U(:,1:n);
S1=S(1:n,1:n);
V1=V(:,1:n);
