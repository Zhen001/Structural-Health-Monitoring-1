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
if PSDfangfa==2
    N2=floor(N/m);           % ƽ������ͼ���ڳ��ȣ�����2�������ֶ�������
    if mod(N2,2)==1,N2=N2+1;end
    PSD=zeros(floor((N2/2)+1),n); f=zeros(floor((N2/2)+1),n); % Ԥ�����ڴ棨����2��
elseif PSDfangfa==1
    PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % Ԥ�����ڴ棨����1�� 
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
    if PSDfangfa==1                                  % 1.����ͼ����Periodogram��
        window=boxcar(N);                            % ѡ��һ�ִ�����
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),fs);
    elseif PSDfangfa==2                              % 2.�������ͼƽ������Welch��
        window=boxcar(N2);                           % ѡ��һ�ִ�����
        noverlap=N2/2;                               % �ֶ������ص��Ĳ������������ȣ�
        range='onesided';                            % ������
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,fs,range);  
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

