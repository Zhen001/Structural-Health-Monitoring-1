function y1 = Fitting(x,y,x1)
%% 把数据转成列向量
if size(x,2)==1, x=x'; end
if size(y,2)==1, y=y'; end
if size(x1,2)==1, x1=x1'; end

%% 拟合
p = polyfit(x,y,2);
y1 = polyval(p,x1);

%% 绘制数据点及预测值
figure; hold on
plot(x,y,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
plot(x1,y1,'r','LineWidth',0.8); 
legend('Data','Fitting curve','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

%% 设置图形
MonitorPosition = get(0,'MonitorPosition');
set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
% 设置坐标轴刻度
xlim([0,max(x)]);
set(gca,'FontName','Cambria')
ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
% 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
ylabel('Speed / (m/s)','FontName','Cambria Math','FontSize',11.5)

