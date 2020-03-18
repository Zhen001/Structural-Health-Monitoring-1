clc, clear, close all; tic  % 朱海涛 2019年4月3日

%% 参数准备
project = 'NBNZ-Months-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据';
long = 6000;  % 样本长度
Fs = 100;    % 采样频率
type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',type,'\\',position];
STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'的所有STD.txt','"'];

if_log = 1; % 是否取对数
if_save_pictures = 1;  % 是否保存图片
if_python = 0; % 是否调用Python，若否则读取已处理好的数据
reject_method = 1; % 0：不剔除数据；1：3sigma法则；2：一刀切

%% 调用Python对数据做处理
if if_python == 1
    CMD_String = ['python ..\..\Python脚本\STD\NBNZ-N个月的STD.py',' ',sub_path,' ',date_start,' ',date_end,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
    [status,result] = system(CMD_String); display(result)
end

%% 读取数据
format long g
fileID = fopen(STD_path(2:end-1),'r');
data = textscan(fileID,'%f %f');
time_series = [1:1440]'; 
data = [data{1},data{2}];
% data = sortrows(data,1); % 按时间排序

%% 剔除异常值
new_data = [];
% 不剔除数据
if reject_method == 0
    new_data = data;
end
% 3sigma法则
if reject_method == 1
    for ii = 1:1440
        temp = data(data(:,1)==ii,:);
        temp_mean = mean(temp(:,2));
        temp_std = std(temp(:,2));
        loc = abs(temp-temp_mean)<=3*temp_std;
        temp = temp(loc(:,2),:);
        new_data = [new_data;temp];
    end
end
% 一刀切
if reject_method == 2
    new_data = data(data(:,2)<0.2,:);
end
% 剔除比例
proportion = (length(data) - length(new_data)) / length(data);
sprintf('%2.2f%%', proportion*100)
time_stamp = new_data(:,1);
% 是否取对数
if if_log
    STD = log(new_data(:,2));
else
    STD = new_data(:,2);
end

%% 绘制STD-GPR时序图
figure('visible','on');
% 生成分类器
GPRMdl = fitrgp(time_stamp,STD,'Basis','none','FitMethod','sd','PredictMethod','sd','KernelFunction','matern32');
% 计算并绘制95%置信区间
[STDpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.5,'facealpha',0.25)
% 绘制数据点及预测值
hold on; box off
plot(time_stamp,STD,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
plot(time_series,STDpred,'r','LineWidth',0.8); 
xlim([1 1440]); % ylim([0 0.3])

%% 设置图形
legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w'); hold off
MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
set(gcf,'color','w','position',[0.05*MonitorPosition(3),MonitorPosition(4)/5,0.9*MonitorPosition(3),MonitorPosition(4)/4]); % 控制出图背景色和大小
ylabel('STD / (m\cdots^{\fontsize{6}-2})','FontName','Times New Roman','FontSize',11,'position',[Xlims(1)-0.035*diff(Xlims) mean(Ylims)])
% 设置坐标轴刻度
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))
set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'})
ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-2.3 0 2.3 0; 0 -1.5 0 1.8; 0 0 1.5 0; 0 0 0 1.5]);
ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f')) % 重复一次，保证y坐标能够对应
    
%% 保存图片
if if_save_pictures
    picture_type = '.png';
    picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project];
    if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
    picture_path = [picture_main_path,'\\','STD-',date_start,' to ',date_end,picture_type];
    if if_log; picture_path = strrep(picture_path, 'STD-', 'STD(LN)-'); end
    f=getframe(gcf); imwrite(f.cdata,picture_path)
end

%% 计时结束
toc
