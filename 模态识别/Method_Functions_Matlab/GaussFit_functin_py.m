function [centers,frequencys,sigma,x1,y1] = GaussFit_functin_py(x,binWidth,if_sigma,if_log,if_draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

%% ����׼��
% x : [N * 1]
% binWidth : ����ͼ���
% if_sigma : �Ƿ��޳��쳣����
% if_log : �Ƿ�Ծ���ֵȡ����
% if_pictures : �Ƿ��ͼ

%% ��ȡ����
format long g
x = x(:);

%% �Ƿ�ȡ����
if if_log
    signs = sign(x);
    x = log(abs(x));
    x = signs .* x;
end

%% Main
%% 4sigma����
if if_sigma == 1
    speed_mean = mean(x); speed_std = std(x);
    x = x(abs(x-speed_mean)<=4*speed_std);
end
%% ����ֱ��ͼ
[frequencys,edges] = histcounts(x,'BinWidth',binWidth,'Normalization','pdf'); 
centers = (edges(1:end-1)+edges(2:end))/2;
%% ��������ܶ�����
[mu, sigma, muCI, sigmaCI] = normfit(x, 0.05); % �ֲ�������� 
x1 = linspace(mu-3.5*sigma,mu+3.5*sigma,500);
y1 = pdf('Normal', x1, mu, sigma);
%% ��ͼ
if if_draw
    %% ��Ƶ�ηֲ�ֱ��ͼ
    figure('visible','on'); % ��ͼ��������
    bar(centers,frequencys,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.4) % ����ֱ��ͼ
    ylim([0,1.05*max(frequencys)]) % ��ֱ��ͼ�ϱ߽���һ��ռ�

    %% �������ܶ�����
    hold on; yyaxis right;
    h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',1.5); % ���Ƹ����ܶ�����
    xlim([mu-3*sigma,mu+3*sigma]); % ��x��Χ���������Ҹ�3sigma֮��
    ylim([0,1.05*max(frequencys)]) % ����״ͼ��ͼ�����Ϊ1ʱ������ͼ��һ�£����������ᡮƵ�����õ��˱���
    legend(h,'Gaussian Distribution Fitting','EdgeColor','w','FontName','Times New Roman','FontSize',12);
    %% ͼ������
    % ����ͼ�δ�С
    MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % ���Ƴ�ͼ����ɫ�ʹ�С
    % ����������̶�
    ax = gca; ax.YColor = 'k'; % ������������ɫ
    Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
    ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2); % ��x��ֳ�8��
    ax.TickDir='out'; ax.TickLength = [0.008 0.025]; % ���ÿ̶ȷ���ʹ�С
    ax.XAxis.MinorTick = 'on'; ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end); % ����С�̶�����
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'),'FontName','Times New Roman');
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1.05 0; 0 0 0 1]); % ȥ��figure�ж���Ŀհײ��֣�ע�⣬����������label֮ǰ������¿��Ա����鷳
    % ���������ǩ
    ylabel('Gaussian Probability Density','FontName','Times New Roman','FontWeight','bold','FontSize',12,'position',[Xlims(2)+0.07*diff(Xlims) mean(Ylims)])
    yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
    xlabel(['Fluctuating Wind/(m\cdots^{\fontsize{6}-2})'],'FontName','Times New Roman','FontWeight','bold','FontSize',12,'position',[mean(Xlims) Ylims(1)-0.095*diff(Ylims)])
    ylabel('Frequency','FontName','Times New Roman','FontWeight','bold','FontSize',12)
    % ȡ���������������ߵĿ̶�
    box off; ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
    set(ax2,'YTick', []); set(ax2,'XTick', []); box on
end
