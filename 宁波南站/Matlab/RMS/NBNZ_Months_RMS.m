clc, clear, close all; tic  % 朱海涛 2019年4月3日
% 备注：与 NBNZ_Months_STD.m 只差RMS/STD

%% 参数准备
project = 'NBNZ-Months-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值';
long = 6000; % 样本长度
Fs = 100; % 采样频率

position_type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',position_type,'\\',position];
% **************
sub_path = 'E:\\【论文】\\【小论文】\\宁波南站\\Python脚本\\GPR';
% **************
RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'的所有RMS.txt','"'];

if_log = 1; % 0：不取对数，只通过Step1；1：取对数,只通过Step1；2：都要，先取对数通过step2，再不取对数通过Step1
if_save_pictures = 0; % 是否保存图片
if_python = 0; % 是否调用Python，若否则读取已处理好的数据
reject_method = 1; % 0：不剔除数据；1：3sigma法则；2：一刀切

%% Step1
%% 调用Python对数据做处理
if if_python == 1
    CMD_String = ['python ..\..\Python脚本\RMS\NBNZ-N个月的RMS.py',' ',sub_path,' ',date_start,' ',date_end,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
    [status,result] = system(CMD_String); display(result)
end

%% 读取数据
format long g
fileID = fopen(RMS_path(2:end-1),'r');
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
    RMS = log(new_data(:,2));
else
    RMS = new_data(:,2);
end

%% 绘制RMS-GPR时序图
figure('visible','on');hold on; xlim([1 1440]);
% 生成分类器
GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','sd','KernelFunction','matern32');
% 计算并绘制95%置信区间
[RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.5,'facealpha',0.25)
% 绘制数据点及预测值
plot(time_stamp,RMS,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
plot(time_series,RMSpred,'r','LineWidth',0.8); 
legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

%% 设置图形
MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
% 设置坐标轴刻度
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % 重复一次，保证y坐标能够对应
% 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5)

%% 保存图片
if if_save_pictures
    picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project];
    if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
    picture_path = [picture_main_path,'\\','RMS-',date_start,' to ',date_end];
    if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
    print(gcf, '-dpng', picture_path)
end

%% Step2（仅当 if_log==2 时，才通过Step2）
if if_log == 2
    %% 读取数据
    format long g
    fileID = fopen(RMS_path(2:end-1),'r');
    data = textscan(fileID,'%f %f');
    time_series = [1:1440]'; 
    data = [data{1},data{2}];

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
    RMS = new_data(:,2);

    %% 绘制RMS-GPR时序图
    figure('visible','on');hold on; xlim([1 1440]);
    % 生成分类器
    GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','sd','KernelFunction','matern32');
    % 计算并绘制95%置信区间
    [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
    patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.5,'facealpha',0.25)
    % 绘制数据点及预测值
    plot(time_stamp,RMS,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
    plot(time_series,RMSpred,'r','LineWidth',0.8); 
    legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

    %% 设置图形
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
    % 设置坐标轴刻度
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % 重复一次，保证y坐标能够对应
    % 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5)

    %% 保存图片
    if if_save_pictures
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','RMS-',date_start,' to ',date_end];
        print(gcf, '-dpng', picture_path)
    end
end

%% 计时结束
toc
