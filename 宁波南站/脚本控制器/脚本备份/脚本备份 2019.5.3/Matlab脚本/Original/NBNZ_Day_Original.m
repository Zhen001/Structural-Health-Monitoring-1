clc, clear, close all; tic  % 朱海涛 2019年4月3日
% 备注：与 NBNZ_Day_STD.m 和 NBNZ_Day_RMS.m 完全不一样，不可简单替换

%% 参数准备
project = 'NBNZ-Day-Original';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值';
long = 6000;  % 样本长度
Fs = 100;    % 采样频率
position_type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',position_type,'\\',position];
Duration_days = datestr([datenum(date_start) : datenum(date_end)],'yyyy-mm-dd');

if_save_pictures = 1;  % 是否保存图片
if_python = 0; % 0：不再处理，直接读取Python处理好的数据；1：用Python处理数据

%% 循环出每天的Original时序图
for ii = 1:size(Duration_days,1)
    close all
    day_specified = Duration_days(ii,:); 
    Original_path = ['"',sub_path,'\\','Original-',day_specified,'.txt','"'];
    
%% 调用Python对数据做处理
    if if_python == 1
        CMD_String = ['python ..\..\Python脚本\Original\NBNZ-一整天的Original.py',' ',sub_path,' ',day_specified,' ',num2str(long),' ',num2str(Fs),' ',Original_path];
        [status,result] = system(CMD_String);
        if status == 1; continue; end % 确保程序无误再开启这一行
    end

%% 读取数据
    format long g
    if ~exist(Original_path(2:end-1),'file'); disp(['缺失',Original_path(end-14:end-1)]); continue; end
    fileID = fopen(Original_path(2:end-1),'r');
    Original_data = textscan(fileID,'%f %f %f %f');
    time_stamp = Original_data{1};
    Original_mean = Original_data{2};
    Original_max = Original_data{3};
    Original_min = Original_data{4};
    if length(Original_mean) < 5; disp(['缺失',Original_path(end-14:end-1)]); continue; end
    
%% 绘制Original时序图
    figure('visible','off'); hold on; xlim([1 1440]);
    plot(time_stamp,Original_mean,'.','MarkerSize',3.5);
    plot(time_stamp,Original_max,'.','MarkerSize',3.5);
    plot(time_stamp,Original_min,'.','MarkerSize',3.5);
    % 设置图形
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[0.05*MonitorPosition(3),MonitorPosition(4)/5,0.9*MonitorPosition(3),MonitorPosition(4)/4]); % 控制出图背景色和大小
    ylabel('Original / (m\cdots^{\fontsize{6}-2})','FontName','Times New Roman','FontSize',11,'LineWidth',2,'position',[Xlims(1)-0.035*diff(Xlims) mean(Ylims)])
    % 设置坐标轴刻度
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'))
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'})
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-2.3 0 2.3 0; 0 -1.5 0 1.8; 0 0 1.5 0; 0 0 0 1.5]);
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % 重复一次，保证y坐标能够对应

%% 保存图片
    if if_save_pictures
        picture_type = '.png';
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','Original-',day_specified,picture_type];
        f=getframe(gcf); imwrite(f.cdata,picture_path)
    end
end

%% 生成Markdown文件
CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(0)];
system(CMD_String2);

%% 计时结束
toc
