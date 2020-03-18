clc, clear, close all; tic  % 朱海涛 2019年4月3日
% 备注：与 NBNZ_Day_STD.m 只差RMS/STD；但与 NBNZ_Day_Original.m 完全不一样

%% 参数准备
project = 'NBNZ-Day-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值';
long = 6000; % 样本长度
Fs = 100; % 采样频率

position_type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',position_type,'\\',position];
Duration_days = datestr([datenum(date_start) : datenum(date_end)],'yyyy-mm-dd');

if_log = 2; % 0：不取对数，只通过Step1；1：取对数,只通过Step1；2：都要，先取对数通过step2，再不取对数通过Step1
if_save_pictures = 1; % 是否保存图片
if_python = 0; % 0：不再处理，直接读取Python处理好的数据；1：用Python处理数据

%% Step1
%% 循环出每天的RMS-GPR时序图
for ii = 1:size(Duration_days,1)
    close all
    day_specified = Duration_days(ii,:); 
    RMS_path = ['"',sub_path,'\\','RMS-',day_specified,'.txt','"'];

%% 调用Python对数据做处理
    if if_python == 1
        CMD_String = ['python ..\..\Python脚本\RMS\NBNZ-一整天的RMS.py',' ',sub_path,' ',day_specified,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
        [status,result] = system(CMD_String);
        if status == 1; continue; end % 确保程序无误再开启这一行，因为有些天的数据不存在，会报错，这时候就终止此循环，放弃这一天
    end

%% 读取数据
    format long g
    if ~exist(RMS_path(2:end-1),'file'); disp(['缺失',RMS_path(end-14:end-1)]); continue; end
    fileID = fopen(RMS_path(2:end-1),'r');
    RMS_data = cell2mat(textscan(fileID,'%f %f'));
    time_series = [1:1440]'; 
    time_stamp = RMS_data(:,1);
    RMS = RMS_data(:,2);
    if length(RMS) < 5; disp(['缺失',RMS_path(end-14:end-1)]); continue; end
    % 是否取对数
    if if_log; RMS = log(RMS); end
    
%% 绘制RMS-GPR时序图
    figure('visible','on'); hold on; xlim([1 1440]);
    % 生成分类器
    GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','exact','KernelFunction','matern32');
    % 计算并绘制95%置信区间
    [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
    patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
    % 绘制数据点及预测值
    plot(time_stamp,RMS,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
    plot(time_series,RMSpred,'r','LineWidth',0.8); box off
    legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off
    % 设置图形
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
    % 设置坐标轴刻度
    ylim([Ylims(1),Ylims(2)]); % 上一步操作会把y坐标搞乱，得调整回来
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025]; ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    % 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5,'position',[Xlims(1)-0.032*diff(Xlims) mean(Ylims)])

%% 保存图片
    if if_save_pictures
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','RMS-',day_specified];
        if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
        print(gcf, '-dpng', picture_path)
    end
end

%% 生成Markdown文件
CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% Step2（仅当 if_log==2 时，才通过Step2）
if if_log == 2  
    %% 循环出每天的RMS-GPR时序图
    if_log = 0; % 为了可以生成不含(LN)的Markdown，需要做此处理
    for ii = 1:size(Duration_days,1)
        close all
        day_specified = Duration_days(ii,:); 
        RMS_path = ['"',sub_path,'\\','RMS-',day_specified,'.txt','"'];

    %% 读取数据
        format long g
        if ~exist(RMS_path(2:end-1),'file'); disp(['缺失',RMS_path(end-14:end-1)]); continue; end
        fileID = fopen(RMS_path(2:end-1),'r');
        RMS_data = cell2mat(textscan(fileID,'%f %f'));
        time_series = [1:1440]'; 
        time_stamp = RMS_data(:,1);
        RMS = RMS_data(:,2);
        if length(RMS) < 5; disp(['缺失',RMS_path(end-14:end-1)]); continue; end

    %% 绘制RMS-GPR时序图
        figure('visible','off'); hold on; box off; xlim([1 1440]);
        % 生成分类器
        GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','exact','KernelFunction','matern32');
        % 计算并绘制95%置信区间
        [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
        patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
        % 绘制数据点及预测值
        plot(time_stamp,RMS,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
        plot(time_series,RMSpred,'r','LineWidth',0.8); box off
        legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off
        % 设置图形
        MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
        set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % 控制出图背景色和大小
        % 设置坐标轴刻度
        ylim([Ylims(1),Ylims(2)]); % 上一步操作会把y坐标搞乱，得调整回来
        set(gca,'YTickLabel',num2str(get(gca,'YTick'),'%.1f'),'FontName','Cambria')
        set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
        ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025]; ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
        ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
        ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
        % 去除figure中多余的空白部分，注意，在设置标签之前做这件事可以避免麻烦
        set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
        ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5,'position',[Xlims(1)-0.032*diff(Xlims) mean(Ylims)])

    %% 保存图片
        if if_save_pictures
            picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\','RMS-',day_specified];
            print(gcf, '-dpng', picture_path)
        end
    end

    %% 生成Markdown文件
    CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String2);
    
    CMD_String3 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_GaussFit_LN与非LN对比.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String3);
end    

%% 计时结束
toc
