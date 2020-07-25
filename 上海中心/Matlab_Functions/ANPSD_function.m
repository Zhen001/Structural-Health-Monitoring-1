% PP��ģ̬����ʶ��
function [f,ANPSD] = ANPSD_function(response,Fs,PSDfangfa,m,duishu)

% ����˵��
% response�������Ƕ���ʱ���źţ�ÿ�д���һ����㣩
% Fs������Ƶ��
% PSDfangfa��ѡ��Ҫʹ�õķ�����1Ϊ����ͼ����2Ϊ�������ͼƽ���������ֶ�������
% m��ƽ������ͼ����ƽ����
% duishu���Ƿ�Խ��ȡ����

%% 1.����Ԥ����
if size(response,2)>size(response,1); response=response'; end

%% 2.�����ֵ
% ���ݴ�����
jcy=0;                    % �Ƿ񽵲����������˲�ʱ��������������ֶ�������
lvbo=0;                   % �Ƿ��˲������ֶ�������
n=size(response,2);       % �������
% �������������
x1=response(:,1);                             % ����ȡһ�����ݣ�����ʽ��������
x1=x1-mean(x1);                               % ȥ��ƽ��������
if jcy
    pinlv_jiangcaiyang=256;                   % ������Ƶ�ʣ����ֶ�������
    x1=resample(x1,pinlv_jiangcaiyang,Fs);    % ������,Ĭ��ÿ�е���������
    N=length(x1);                             % ��������ĳ���
else
    N=length(x1);                             % ԭʼ���ݳ�
end
% Ԥ�����ڴ桢ƽ������ͼ���ڳ�������
PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % Ԥ�����ڴ棨����1�� 
if PSDfangfa==2
    N2=floor(N/m);                                        % N2:�������ͼƽ������Welch�����ڳ���
    if mod(N2,2)==1,N2=N2+1;end
end
% % ��ʱ������
% fanwei=1:length(x1);          % ����������ʱ�����߷�Χ
% t=1:length(x1);
% plot(t(fanwei),x1(fanwei))

%% 3.���ν����������ת��PSD
for i=1:n
    fs=Fs;                    % ���������������ȡԭֵ
    x=response(:,i);
% 3.1 ������
    if jcy
        x=resample(x,pinlv_jiangcaiyang,Fs);   % ������,Ĭ��ÿ�е���������
        fs=pinlv_jiangcaiyang;                 % ��Ƶ���滻�ɽ�����Ƶ��
    end 
% 3.2 �˲�  
%     % ������Ƶ50HZ
%     fs2=fs/2;                          % �����ο�˹��Ƶ��
%     W0=50/fs2;                         % �ݲ�������Ƶ��
%     BW=0.005;                          % �ݲ������� 
%     [b,a]=iirnotch(W0,BW);             % ���IIR�����ݲ���
%     x=filter(b,a,x);                   % ���ź��˲�
%     
%     % ����0HZ
%     fs2=fs/2;                          % �����ο�˹��Ƶ��
%     W0=0.01/fs2;                       % �ݲ�������Ƶ��
%     BW=0.005;                          % �ݲ������� 
%     [b,a]=iirnotch(W0,BW);             % ���IIR�����ݲ���
%     x=filter(b,a,x);                   % ���ź��˲�
    
%     % ������Ƶ150HZ
%     fs2=fs/2;                          % �����ο�˹��Ƶ��
%     W0=150/fs2;                        % �ݲ�������Ƶ��
%     BW=0.005;                          % �ݲ������� 
%     [b,a]=iirnotch(W0,BW);             % ���IIR�����ݲ���
%     x=filter(b,a,x);                   % ���ź��˲�
     
    if lvbo
        fs2=fs/2;                            % �ο�˹��Ƶ��
        fp1=[40 110];                        % ͨ��Ƶ�ʣ����ֶ�������
        fs1=[35 120];                        % ���Ƶ�ʣ����ֶ�������
        wp1=fp1/fs2;                         % ��һ��ͨ��Ƶ��
        ws1=fs1/fs2;                         % ��һ�����Ƶ��
        Ap=3; As=30;                         % ͨ�����ƺ����˥�������ֶ�������
        [jieshu,Wn]=buttord(wp1,ws1,Ap,As);  % ���˲���ԭ�ͽ����ʹ���
        [bn1,an1]=butter(jieshu,Wn);         % �������˲���ϵ��
        x=filter(bn1,an1,x);                 % �����ݽ����˲���Ĭ��ÿ�е����˲�
    end
% 3.3 ���㹦�����ܶ�PSD
    window=hamming(N);                      % ѡ��һ�ִ�����
    if PSDfangfa==1                         % 1.����ͼ����Periodogram��
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),fs);
    elseif PSDfangfa==2                  	% 2.�������ͼƽ������Welch��
        noverlap=N2/2;                      % �ֶ������ص��Ĳ������������ȣ�
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N,fs,'onesided');  
    end
end
end

%% 4.����ƽ�����򻯹������ܶ�ANPSD
ANPSDs=0;
for i=1:n
    % ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i)); % ����
    ANPSDs=ANPSDs+PSD(:,i)/n; % ƽ����
end

%% 5.�Ƿ�ȡ����
if duishu
    ANPSD=10*log10(ANPSDs/n);       % ������ʽ
else
    ANPSD=ANPSDs/n;                 % �Ƕ���
end 

