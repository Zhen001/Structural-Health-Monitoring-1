% ��Ȼ������ ģ̬����ʶ��Ԥ����
function r = NExT_function(x1,x2,Fs,long)

%% ����˵��
% x1����һ������
% x2���ڶ�������
% Fs������Ƶ��
% long��������ݳ���

%% ����Ԥ����
x1=x1(:)';
x2=x2(:)';

%% NExT
%������ɢ���ʱ������
t=0:1/Fs:(long-1)/Fs;
%����FFT����
nfft=2^nextpow2(2*long);
%���㻥������
p=csd(x1,x2,nfft);
%������Ƶ�ʶεĻ�������
p(nfft/2+1)=real(p(nfft/2)); 
p(nfft/2+2:nfft)=conj(p(nfft/2:-1:2));
%IFFT�任
g=ifft(p);
%��Ҫ��ʱ�䳤��ȡIFFT�任��ʵ��Ϊ�Ļ���غ���
r=real(g(1:long));
%���ƻ���غ���ʱ������ͼ
plot(t,r);
xlabel('ʱ�� (s)');  
ylabel('��ֵ'); 
grid on;                        

