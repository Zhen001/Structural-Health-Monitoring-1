% % ע�⣺�˴�������Ƿ��ʵ���׶���PSD
function [f,ANPSD] = ANPSD_function_for_wind(response,Fs,PSDfangfa,m,if_log,draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% ����˵��
% response�������Ƕ���ʱ���źţ�ÿ�д���һ����㣩
% Fs������Ƶ��
% PSDfangfa��ѡ��Ҫʹ�õķ�����1Ϊ����ͼ����2Ϊ�������ͼƽ���������ֶ�������
% m��ƽ������ͼ����ƽ����
% if_log���Ƿ�Խ��ȡ����
% draw���Ƿ���ͼ
% percent����ֵ����ȡ��ߵ�İٷ�֮��
% minpeakdist����ֵ֮����С����

%% 1.����Ԥ����
if size(response,2)>size(response,1); response=response'; end

%% 2.�����ֵ
% ���ݴ�����
jcy=0;                                        % �Ƿ񽵲����������˲�ʱ��������������ֶ�������
n=size(response,2);                           % �������
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
    N2=floor(N/m);                            % ƽ������ͼ���ڳ��ȣ�����2�������ֶ�������
    if mod(N2,2)==1,N2=N2+1;end
    PSD=zeros(floor((N2/2)+1),n); f=zeros(floor((N2/2)+1),n); % Ԥ�����ڴ棨����2��
elseif PSDfangfa==1
    PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % Ԥ�����ڴ棨����1�� 
end

%% 3.���ν����������ת��PSD
for i=1:n
    fs=Fs;                                     % ���������������ȡԭֵ
    x=response(:,i);
% 3.1 ������
    if jcy
        x=resample(x,pinlv_jiangcaiyang,Fs);   % ������,Ĭ��ÿ�е���������
        fs=pinlv_jiangcaiyang;                 % ��Ƶ���滻�ɽ�����Ƶ��
    end 
% 3.3 ���㹦�����ܶ�PSD
    if PSDfangfa==1                                  % 1.����ͼ����Periodogram��
        window=hamming(N);                           % ѡ��һ�ִ�����
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),fs);
        PSD(:,i)=f.*PSD(:,i)./(var(x));
    elseif PSDfangfa==2                              % 2.�������ͼƽ������Welch��
        window=hamming(N2);                          % ѡ��һ�ִ�����
        noverlap=N2/2;                               % �ֶ������ص��Ĳ������������ȣ�
        range='onesided';                            % ������
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,fs,range);
        PSD(:,i)=f.*PSD(:,i)./(var(x));              % ע�⣺�˴��������ʵ���׶���PSD
    end
end

%% 4.����ƽ�����򻯹������ܶ�ANPSD
ANPSD=mean(PSD,2);

%% 5.�Ƿ�ȡ����������ƽ��
if if_log
    ANPSD=log10(ANPSD);       % ������ʽ
    f=log10(f);
end 

%% 6.��ͼ
if draw
    xlimt=[0,1];                            % ��ͼ��Χ�����ֶ�������
    interval=1;                              % �������������ֶ�������

    % ����ANPSD
    figure
    h1=plot(f,ANPSD,'Color',[0.3 0.5 0.7],'LineWidth',0.8); 
    grid on; box on; xlim(xlimt); MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % ���Ƴ�ͼ����ɫ�ʹ�С
    Xlims=get(gca,'Xlim'); Ylims=get(gca,'Ylim'); set(gca,'XTick',0:interval:Xlims(2))
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-2.5 0 2.5 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); % ȥ��figure�ж���Ŀհײ��֣�ע�⣬����������label֮ǰ������¿��Ա����鷳
    title('ƽ�����򻯹������ܶ�ANPSD','FontName','���ķ���','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[mean(Xlims) Ylims(2)+0.02*diff(Ylims)])
    xlabel('Ƶ��/Hz','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.04*diff(Ylims)])
    ylabel('�������ܶ�/(dB/Hz)','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Xlims(1)-0.05*diff(Xlims) mean(Ylims)])
end

%% 7.����ֵ����
f = f';
ANPSD = ANPSD';

