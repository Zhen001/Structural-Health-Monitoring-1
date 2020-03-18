% 自然激励法 模态参数识别预处理
function r = NExT_function(x1,x2,Fs,long)

%% 参数说明
% x1：第一列数据
% x2：第二列数据
% Fs：采样频率
% long：输出数据长度

%% 数据预处理
x1=x1(:)';
x2=x2(:)';

%% NExT
%建立离散输出时间向量
t=0:1/Fs:(long-1)/Fs;
%建立FFT长度
nfft=2^nextpow2(2*long);
%计算互功率谱
p=csd(x1,x2,nfft);
%建立负频率段的互功率谱
p(nfft/2+1)=real(p(nfft/2)); 
p(nfft/2+2:nfft)=conj(p(nfft/2:-1:2));
%IFFT变换
g=ifft(p);
%按要求时间长度取IFFT变换的实部为的互相关函数
r=real(g(1:long));
%绘制互相关函数时程曲线图
plot(t,r);
xlabel('时间 (s)');  
ylabel('幅值'); 
grid on;                        

