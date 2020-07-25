function IMF=AMD_trend_py(x,Fs,w,nbsym1,nbsym2,name,if_draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% AMD_trend: ���ڽ�����
% input:
% x: ʱ�����У�1*N
% Fs:����Ƶ��
% w����Ҫ�ֶε�Ƶ��(��ԲƵ��) ,1*N
% nbsym1: ���������������� AMD �����Ƶı߼�ЧӦ
% nbsym2: ���� AMD �� hilbert �߼�ЧӦ 
% output:
% IMF: ��ȡ�����Ӳ���

% Fs=2048; % ģ������
% t=[1:2018*100]/2048;
% x=5*sin(30*2*pi*t)+10*sin(40*2*pi*t)+150*randn(1,2018*100);

if size(x,2)==1, x=x'; end
t=0:1/Fs:length(x)/Fs-1/Fs;
[tt,xx] = mirror_extend(t,x,nbsym1);
[tt,ind]=unique(tt); % �Է���һ���ҳ����loc1�Ͷ��loc2
loc1=find(tt==t(1));
loc2=loc1+length(t)-1;
xx=xx(ind);
IMF=AMD(xx,Fs,2*pi*w,nbsym2);
IMF=IMF(loc1:loc2);

if if_draw
    %% �������ݵ㼰Ԥ��ֵ
    figure('visible','on'); hold on
    plot(t,x,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
    plot(t,IMF,'r','LineWidth',0.8); 
    legend(['Data-',name],'AMD trend','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

    %% ����ͼ��
    MonitorPosition = get(0,'MonitorPosition');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
    % ����������̶�
    xlim([0,max(t)]);
    set(gca,'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('Speed / (m/s)','FontName','Cambria Math','FontSize',11.5)
end
