function [centers,frequencys,sigma,x1,y1] = GaussFit_functin_py(x,binWidth,if_sigma,if_log,if_draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

%% 参数准备
% x : [N * 1]
% binWidth : 条形图宽度
% if_sigma : 是否剔除异常数据
% if_log : 是否对绝对值取对数
% if_pictures : 是否出图

%% 读取数据
format long g
x = x(:);

%% 是否取对数
if if_log
    signs = sign(x);
    x = log(abs(x));
    x = signs .* x;
end

%% Main
%% 4sigma法则
if if_sigma == 1
    speed_mean = mean(x); speed_std = std(x);
    x = x(abs(x-speed_mean)<=4*speed_std);
end
%% 计算直方图
[frequencys,edges] = histcounts(x,'BinWidth',binWidth,'Normalization','pdf'); 
centers = (edges(1:end-1)+edges(2:end))/2;
%% 计算概率密度曲线
[mu, sigma, muCI, sigmaCI] = normfit(x, 0.05); % 分布参数拟合 
x1 = linspace(mu-3.5*sigma,mu+3.5*sigma,500);
y1 = pdf('Normal', x1, mu, sigma);
%% 绘图
if if_draw
    %% 画频次分布直方图
    figure('visible','on'); % 绘图但不弹出
    bar(centers,frequencys,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.4) % 绘制直方图
    ylim([0,1.05*max(frequencys)]) % 给直方图上边界留一点空间

    %% 画概率密度曲线
    hold on; yyaxis right;
    h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',1.5); % 绘制概率密度曲线
    xlim([mu-3*sigma,mu+3*sigma]); % 将x范围限制在左右各3sigma之内
    ylim([0,1.05*max(frequencys)]) % 和柱状图在图形面积为1时做出的图形一致，但是坐标轴‘频数’得到了保留
    legend(h,'Gaussian Distribution Fitting','EdgeColor','w','FontName','Times New Roman','FontSize',12);
    %% 图形设置
    % 设置图形大小
    MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % 控制出图背景色和大小
    % 设置坐标轴刻度
    ax = gca; ax.YColor = 'k'; % 调整坐标轴颜色
    Xlims = ax.XLim; Ylims = ax.YLim; % 获取x,y轴范围
    ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2); % 将x轴分成8份
    ax.TickDir='out'; ax.TickLength = [0.008 0.025]; % 设置刻度方向和大小
    ax.XAxis.MinorTick = 'on'; ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end); % 调整小刻度数量
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'),'FontName','Times New Roman');
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1.05 0; 0 0 0 1]); % 去除figure中多余的空白部分，注意，在设置坐标label之前做这件事可以避免麻烦
    % 设置坐标标签
    ylabel('Gaussian Probability Density','FontName','Times New Roman','FontWeight','bold','FontSize',12,'position',[Xlims(2)+0.07*diff(Xlims) mean(Ylims)])
    yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim; % 获取x,y轴范围
    xlabel(['Fluctuating Wind/(m\cdots^{\fontsize{6}-2})'],'FontName','Times New Roman','FontWeight','bold','FontSize',12,'position',[mean(Xlims) Ylims(1)-0.095*diff(Ylims)])
    ylabel('Frequency','FontName','Times New Roman','FontWeight','bold','FontSize',12)
    % 取消最上面那条边线的刻度
    box off; ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
    set(ax2,'YTick', []); set(ax2,'XTick', []); box on
end
