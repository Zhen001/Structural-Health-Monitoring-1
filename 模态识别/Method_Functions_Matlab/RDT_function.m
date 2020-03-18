% 随机减量法 模态参数识别预处理
function y = RDT_function(x,Fs,long)

%% 参数说明
% x：输入时程信号数据存成行向量
% Fs：采样频率
% long：输出数据长度

%数据预处理
x=x(:)';

% 模拟数据
% Fs=2048; 
% t=[1:2018*100]/2048;
% x=5*sin(30*2*pi*t)+10*sin(40*2*pi*t)+150*randn(1,2018*100);
% long=2000;

%建立离散输出时间向量
t=0:1/Fs:(long-1)/Fs;
%取输入数据长度
nt=length(x);
%设置截取振幅为输入信号标准差的1.5倍
s=0.03*std(x); 
%获取输入信号的子样本函数进行叠加
m=0; 
y=zeros(1,long);
for k=2:nt-long % 寻找x==s的位置
  a=abs(x(k-1)-s); 
  b=abs(x(k)-s); 
  c=abs(x(k+1)-s); 
  if b<a && b<c 
    y(1:long)=y(1:long)+x(k:k+long-1); % 移到起点然后相加
    m=m+1; % 计数
  end
end
%对叠加结果做平均
y=y./m;

%绘制自由振动时程曲线图
plot(t,y);
xlabel('时间 (s)');  
ylabel('幅值'); 
grid on;                        

