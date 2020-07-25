% STD法模态参数识别
function result = STD_function_py(x,Fs,mn)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

draw = 0;

% % 模拟信号
% clear all
% Fs=100; % 模拟数据
% mn=5;
% draw=1;
% t=[1:5000]/100;
% x=5*sin(30*2*pi*t)+10*sin(40*2*pi*t)+150*randn(1,5000);

% 参数说明
% x：时域数据如冲击响应、自由振动、互相关函数、随机减量法处理结果
% Fs：采样频率
% mn：模态阶数
% filename: 输出数据文件名

%数据预处理
x=x(:)';
lvbo=1;                               % 是否滤波（需手动调整）
if lvbo
    fs2=Fs/2;                         % 奈奎斯特频率
    Wp=[10,12];                            % 通带频率（需手动调整）
    Ws=[8,14];                            % 阻带频率（需手动调整）
    Wp=Wp/fs2;                        % 归一化通带频率
    Ws=Ws/fs2;                        % 归一化阻带频率
    Rp=1; Rs=50;                      % 通带波纹和阻带衰减（需手动调整）
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs); % 求滤波器原型阶数和带宽
    [bn1,an1]=butter(jieshu,Wn);      % 求数字滤波器系数
    x=filter(bn1,an1,x);              % 对数据进行滤波，默认每列单独滤波
end

% lvbo=1;                               % 是否滤波（需手动调整）
% if lvbo
%     fs2=Fs/2;                         % 奈奎斯特频率
%     [bn1,an1]=butter(2,[10 12]/fs2);      % 求数字滤波器系数
%     x=filter(bn1,an1,x);              % 对数据进行滤波，默认每列单独滤波
% end

%建立特征方程矩阵的阶数（为模态阶数的2倍）
nm=2*mn;
n=fix(length(x)/2);
h=x(1,1:2*n)';
%计算时间间隔 
dt=1/Fs;
%建立离散时间向量
t=0:dt:(2*n-1)*dt;
%计算自由振动响应矩阵
M=length(h)-nm;
x1 = zeros(M,nm);
x2 = zeros(M,nm);
for k = 1:M
  x1(k,:) = h(k:k+nm-1)'; 
  x2(k,:) = h(k+1:k+nm)';
end
%计算Hessenberg矩阵
B=zeros(nm,nm);
B(2:nm,1:nm-1)=eye(nm-1,nm-1);
%用最小二乘法求解待定系数列向量
B(:,nm)=x1\x2(:,nm); %B(:,nm)=inv(x1'*x1)*x1'*x2(:,nm);
%计算特征值及特征向量
[~,V] = eig(B);
%变换特征值对角阵为一向量   
for k = 1:nm  
  U(k)=V(k,k);  
end
%计算模态频率
F1 = abs(log(U'))./(2*pi*dt);
%计算阻尼比
D1 = sqrt(1./(((imag(log(U'))./real(log(U'))).^2)+1));
%计算振型系数向量（特征向量）
l=1;
for k = 1:nm
  if abs(real(U(k)))<= 1 && abs(imag(U(k)))<= 1 
    V0(l) = U(k); 
    l = l + 1;
  end
end
Va = zeros(2*n,size(V0,2));
for k = 0:(2*n-1)
  Va(k+1,:) = conj(V0).^k ;  
end
S1 = (conj(Va')*Va\conj(Va')*h);
%计算生成的脉冲响应函数
h1=real(Va*S1);
%绘制脉冲响应函数拟合曲线图
if draw
    figure(1)
    plot(t,h,':',t,h1); 
    xlabel('时间 (s)');  
    ylabel('幅值'); 
    legend('实测','拟合');
    grid on;                        
end
%将模态频从小到大排序
[F2,I]=sort(F1); 
%剔除方程解中的非模态项(非共轭根)和共轭项(重复)
m=0;S1
for k=1:nm-1
  if F2(k)~=F2(k+1)
    continue; 
  end
  m=m+1;
  l=I(k);
  F(m)=F1(l); %模态频率
  D(m)=D1(l); %阻尼比  
  S(m)=S1(l); %振型系数   
end

%% 返回值处理
result = [F;D*100.0;imag(S)]; % 阻尼比已经乘过100了

