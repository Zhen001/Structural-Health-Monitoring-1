% PP��ģ̬����ʶ��
function [f,ANPSD,locs,pks] = ANPSD_function_py(response,Fs,varargin)

% if ~matlab.engine.isEngineShared
%     matlab.engine.shareEngine()
% end

%% ����˵��
% response�������Ƕ���ʱ���źţ�ÿ�д���һ����㣩
% Fs������Ƶ��

p = inputParser();                      
p.CaseSensitive = false;                % �����Ĳ�����Сд
p.addOptional('filtering', [0,0]);      % filtering: �˲���ͨ����Χ
p.addOptional('PSDfangfa', 1);          % PSDfangfa��ѡ��Ҫʹ�õķ�����1Ϊ����ͼ����2Ϊ�������ͼƽ���������ֶ�������
p.addOptional('m', 4);                  % m��ƽ������ͼ����ƽ����
p.addOptional('if_log', 0);             % if_log���Ƿ�Խ��ȡ����
p.addOptional('draw', 0);               % draw���Ƿ���ͼ
p.addOptional('percent', 10);           % percent����ֵ����ȡ��ߵ�İٷ�֮��
p.addOptional('minpeakdist', 0.01);     % minpeakdist����ֵ֮����С����
p.addOptional('new_f', 0);              % new_f��������Ƶ�ʣ������˲�ʱ�����������Ҳ������������

p.parse(varargin{:});
filtering = p.Results.filtering;
PSDfangfa = p.Results.PSDfangfa;
m = p.Results.m;
if_log = p.Results.if_log;
draw = p.Results.draw;
percent = p.Results.percent;
minpeakdist = p.Results.minpeakdist; 
new_f = p.Results.new_f; 

%% 1.����Ԥ����
if size(response,2)>size(response,1)
    response=response';                     % ת��һ�����һ��
end 
n=size(response,2);                         % �����

% �������������
if new_f
    response=resample(response,...
        new_f*1000,Fs*1000);                % ������,Ĭ��ÿ�е���������
    N=size(response,1);                  	% ��������ĳ���
    Fs=new_f;                             	% ��Ƶ���滻�ɽ�����Ƶ��
else
    N=size(response,1);                 	% ԭʼ���ݳ�
end

% �˲�  
if sum(filtering ~= [0,0])
    fs2=Fs/2;                               % �ο�˹��Ƶ��
    Wp=filtering(1);                        % ͨ��Ƶ�ʣ����ֶ�������
    Ws=filtering(2);                        % ���Ƶ�ʣ����ֶ�������
    Wp=Wp/fs2;                              % ��һ��ͨ��Ƶ��
    Ws=Ws/fs2;                              % ��һ�����Ƶ��
    Rp=1;                                   % ͨ������
    Rs=50;                                  % ���˥��
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs);       % ���˲���ԭ�ͽ����ʹ���
    [bn1,an1]=butter(jieshu,Wn);            % �������˲���ϵ��
    response=filter(bn1,an1,response);      % �����ݽ����˲���Ĭ��ÿ�е����˲�
end

% % ������Ƶ50HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=50/fs2;                                % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�
% % ����0HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=0.01/fs2;                              % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�
% % ������Ƶ150HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=150/fs2;                               % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�
  
%% 2.Ԥ�����ڴ桢ƽ������ͼ���ڳ�������
if PSDfangfa==2
    N2=floor(N/m);                                            % ƽ������ͼ���ڳ��ȣ�����2��
    if mod(N2,2)==1,N2=N2+1;end
    PSD=zeros(floor((N2/2)+1),n); f=zeros(floor((N2/2)+1),n); % Ԥ�����ڴ棨����2��
elseif PSDfangfa==1
    PSD=zeros(floor((N/2)+1),n); f=zeros(floor((N/2)+1),n);   % Ԥ�����ڴ棨����1�� 
end

%% 3.�����ø�������ݼ���PSD
for i=1:n
    x=response(:,i);
    if PSDfangfa==1                         % 1.����ͼ����Periodogram��
        window=hamming(N);                	% ѡ��һ�ִ�����
        [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),Fs);
    elseif PSDfangfa==2                  	% 2.�������ͼƽ������Welch��
        window=hamming(N2);                 % ѡ��һ�ִ�����
        noverlap=N2/2;                      % �ֶ������ص��Ĳ������������ȣ�
        range='onesided';                   % ������
        [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,Fs,range);  
    end
end

%% 4.����ƽ�����򻯹������ܶ�ANPSD
ANPSDs=0;
for i=1:n
    ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i));   % ����
    % ANPSDs=ANPSDs+PSD(:,i);               % ������
end

%% 5.�Ƿ�ȡ����������ƽ��
if if_log
    ANPSD=log10(ANPSDs/n);                  % ������ʽ
else
    ANPSD=ANPSDs/n;                         % �Ƕ���
end 

%% 6.��ͼ
if draw
    xlimt=[0,10];                           % ��ͼ��Χ�����ֶ�������
    interval=1;                             % �������������ֶ�������

% ����ANPSD
    figure
    h1=plot(f,ANPSD,'Color',[0.3 0.5 0.7],'LineWidth',0.8); 
    grid on; box on; xlim(xlimt); MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]);   % ���Ƴ�ͼ����ɫ�ʹ�С
    Xlims=get(gca,'Xlim'); Ylims=get(gca,'Ylim'); set(gca,'XTick',0:interval:Xlims(2))
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-2.5 0 2.5 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]); % ȥ��figure�ж���Ŀհײ��֣�ע�⣬����������label֮ǰ������¿��Ա����鷳
    title('ƽ�����򻯹������ܶ�ANPSD','FontName','���ķ���','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[mean(Xlims) Ylims(2)+0.02*diff(Ylims)])
    xlabel('Ƶ��/Hz','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.04*diff(Ylims)])
    ylabel('�������ܶ�/(dB/Hz)','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Xlims(1)-0.05*diff(Xlims) mean(Ylims)])
end

% �ҷ�ֵ
if draw; display=0.5; else; display=0; end                  % �������ֵͼ��0ʱ����ͼ��0.5ʱ�����ڳ��ߣ�1ʱ��ȫͼ
minpeakh=(max(ANPSD)-min(ANPSD))/100*percent+min(ANPSD);    % ��ֵ����
[locs,pks]=peakseek(f,ANPSD,minpeakdist,minpeakh,display);  % �ҷ�ֵ
if draw
    legend(h1,'ANPSD','FontName','���ķ���','FontSize',15) ;legend('boxoff');
end

%% 7.����ֵ����ת��������
f = f'; 
ANPSD = ANPSD';
locs= locs';
pks = pks';

