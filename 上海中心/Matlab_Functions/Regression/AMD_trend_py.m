function IMF=AMD_trend_py(x,Fs,w,nbsym1,nbsym2,name,if_draw)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% AMD_trend: 用于降趋势
% input:
% x: 时间序列，1*N
% Fs:采样频率
% w：需要分段的频率(非圆频率) ,1*N
% nbsym1: 数据延拓数，抑制 AMD 做趋势的边际效应
% nbsym2: 抑制 AMD 的 hilbert 边际效应 
% output:
% IMF: 提取出的子部分

% Fs=2048; % 模拟数据
% t=[1:2018*100]/2048;
% x=5*sin(30*2*pi*t)+10*sin(40*2*pi*t)+150*randn(1,2018*100);

if size(x,2)==1, x=x'; end
t=0:1/Fs:length(x)/Fs-1/Fs;
[tt,xx] = mirror_extend(t,x,nbsym1);
[tt,ind]=unique(tt); % 以防下一步找出多个loc1和多个loc2
loc1=find(tt==t(1));
loc2=loc1+length(t)-1;
xx=xx(ind);
IMF=AMD(xx,Fs,2*pi*w,nbsym2);
IMF=IMF(loc1:loc2);

if if_draw
    %% 绘制数据点及预测值
    figure('visible','on'); hold on
    plot(t,x,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
    plot(t,IMF,'r','LineWidth',0.8); 
    legend(['Data-',name],'AMD trend','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

    %% 设置图形
    MonitorPosition = get(0,'MonitorPosition');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
    % 设置坐标轴刻度
    xlim([0,max(t)]);
    set(gca,'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    % 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('Speed / (m/s)','FontName','Cambria Math','FontSize',11.5)
end
