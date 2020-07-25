function [t,IRF] = NExT_function_py(x1,x2,Fs,long_out,draw,method)
% 默认方法为2
% [IRF] = NExT(y,Fs,T) implements the Natural Excitation Technique to
% retrieve the Impulse Response Function (IRF) from the cross-correlation
% of the measured output y.
%
% [IRF] = NExT(y,Fs,T,1) calculate the IRF with cross-correlation
% calculated by using the inverse fast fourier transform of the
% cross-spectral power densities  (method = 1).
%
% [IRF] = NExT(y,Fs,T,2) calculate the IRF with cross-correlation
% calculated by using the unbiased cross-covariance function (method = 2)
%
% [IRF] = NExT(y,Fs,T,3) matlab在振动信号中的应用中提供的方法，没研究和第一种有啥区别，但结果不一样
% 
% x1,x2: time series of ambient vibrations: x1可以与x2相同，做互功率谱
% Fs : sample frequency
% method: 1 or 2 for the computation of cross-correlation functions
% long_out: Duration of subsegments (T<dt*(numel(y)-1))
% IRF: impusle response function
% t: time vector asociated to IRF
%%
% 数据预处理
x1=x1(:)';
x2=x2(:)';

if nargin<6, method = 2; end % the fastest method is the default method

switch method
    case 1
        y1 = fft(x1);
        y2 = fft(x2);
        h0 = ifft(y1.*conj(y2));
        IRF = h0(1:long_out);
        % get time vector t associated to the IRF
        t=0:1/Fs:(long_out-1)/Fs;
    case 2
        [dummy,~]=xcov(x1,x2,long_out,'unbiased');
        IRF = dummy(end-round(numel(dummy)/2)+1:end);
        % get time vector t associated to the IRF
        t=0:1/Fs:(long_out-1)/Fs;
        IRF=IRF(1:length(t)); % 有一次莫名报错，不清楚原因，故加此句做修正
    case 3 % Matlab在振动信号处理中的应用
        %建立离散输出时间向量
        t=0:1/Fs:(long_out-1)/Fs;
        %建立FFT长度
        nfft=2^nextpow2(2*long_out);
        %计算互功率谱
        p=csd(x1,x2,nfft);
        %建立负频率段的互功率谱
        p(nfft/2+1)=real(p(nfft/2)); 
        p(nfft/2+2:nfft)=conj(p(nfft/2:-1:2));
        %IFFT变换
        g=ifft(p);
        %按要求时间长度取IFFT变换的实部为的互相关函数
        IRF=real(g(1:long_out))';
end

% 绘制互相关函数时程曲线图
if draw
    figure
    plot(t,IRF);
    xlabel('时间 (s)');
    ylabel('幅值');
    grid on;
end