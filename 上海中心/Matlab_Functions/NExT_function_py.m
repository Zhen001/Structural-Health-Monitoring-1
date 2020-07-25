function [t,IRF] = NExT_function_py(x1,x2,Fs,long_out,draw,method)
% Ĭ�Ϸ���Ϊ2
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
% [IRF] = NExT(y,Fs,T,3) matlab�����ź��е�Ӧ�����ṩ�ķ�����û�о��͵�һ����ɶ���𣬵������һ��
% 
% x1,x2: time series of ambient vibrations: x1������x2��ͬ������������
% Fs : sample frequency
% method: 1 or 2 for the computation of cross-correlation functions
% long_out: Duration of subsegments (T<dt*(numel(y)-1))
% IRF: impusle response function
% t: time vector asociated to IRF
%%
% ����Ԥ����
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
        IRF=IRF(1:length(t)); % ��һ��Ī�����������ԭ�򣬹ʼӴ˾�������
    case 3 % Matlab�����źŴ����е�Ӧ��
        %������ɢ���ʱ������
        t=0:1/Fs:(long_out-1)/Fs;
        %����FFT����
        nfft=2^nextpow2(2*long_out);
        %���㻥������
        p=csd(x1,x2,nfft);
        %������Ƶ�ʶεĻ�������
        p(nfft/2+1)=real(p(nfft/2)); 
        p(nfft/2+2:nfft)=conj(p(nfft/2:-1:2));
        %IFFT�任
        g=ifft(p);
        %��Ҫ��ʱ�䳤��ȡIFFT�任��ʵ��Ϊ�Ļ���غ���
        IRF=real(g(1:long_out))';
end

% ���ƻ���غ���ʱ������ͼ
if draw
    figure
    plot(t,IRF);
    xlabel('ʱ�� (s)');
    ylabel('��ֵ');
    grid on;
end