clc, clear, close all; tic  % 朱海涛 2019年4月1日
% 备注：与 NBNZ_GaussFit_RMS.m 只差RMS/STD

%% 参数准备
project = 'NBNZ-GaussFit-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据';
long = 6000; % 样本长度
Fs = 100; % 采样频率

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1;  % 是否剔除异常数据
if_log = 2; % 0：不取对数，只通过Step1；1：取对数,只通过Step1；2：先取对数通过step2，再不取对数通过Step1
if_save_pictures = 1;  % 是否保存图片
if_python = 0; % 0：不再处理，直接读取Python处理好的数据；1：用Python处理数据；2：用Matlab处理数据（只是为了留下代码记录，用python更快一点）

%% Step1
%% 循环出某一测点各小时的STD柱状分布图和高斯拟合曲线
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % 和Lilliefors生成的数据一样，可共用
    
%% 调用Python对数据做处理
    if if_python == 1
        CMD_String = ['python ..\..\Python脚本\STD\NBNZ-指定时间点的STD.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% 读取数据
    format long g
    fileID = fopen(STD_path(2:end-1),'r');
    STD = cell2mat(textscan(fileID,'%f'));
    % 是否取对数
    if if_log; STD = log(STD); end
    % 3sigma法则
    if if_sigma == 1
        STD_mean = mean(STD);
        STD_std = std(STD);
        STD = STD(abs(STD-STD_mean)<=2*STD_std);
    end
    
%% 用Matlab自己对数据做处理（只是为了留下代码记录，用python更快一点）
    if if_python == 2
        % 更改文件名 及 排除非数据项
        file_list = dir(sub_path);
        file_list = {file_list.name}; % 将struct结构转为cell，避免字符串连接
        file_list = cellfun(@(x) string(x(1:end-4)),file_list); % 将cell转换成字符串向量，更容易处理
        file_list(~contains(file_list,'-') | contains(file_list,'to') |file_list == '' | file_list == 'errorTime') = []; % 删除多余项目
        % 依次处理时间段内的TXT文档，从中挑出需要的时间点，并计算STD
        datetime = datenum(file_list);
        filename = file_list + '.txt';
        date_start = datenum(date_start); date_end = datenum(date_end);
        filename = filename(date_start<=datetime & datetime<=date_end);
        skip_lines = Fs*3600*(str2num(time_stamp(1:2)))-Fs*10;
        if skip_lines < 0; skip_lines = 0;end
        for ii = 1:length(filename)
            flag1 = 1; flag2 = 1;
            time_stamp1 = datenum([filename{ii}(1:end-4),'@',time_stamp]);
            file_path = [sub_path, '\\', filename{ii}];
            fileID = fopen(file_path,'r');
            data = textscan(fileID,'%s %f64',1,'Headerlines',skip_lines);
            try
                data{1}{1};
            catch
                disp(['数据缺失1：',filename{ii}])
                flag1 = 0; flag2 = 0;
            end
            while flag1  % 逐行判断是否到达时间戳
                data = textscan(fileID,'%s %f64',1);
                if datenum(data{1}{1}) == time_stamp1
                    flag1 = 0;
                elseif datenum(data{1}{1}) > time_stamp1
                    flag1 = 0; flag2 = 0;
                    disp(['数据缺失2：',filename{ii}])
                end
            end
            if flag2
                data = textscan(fileID,'%s %f64',long);
                velocity = data{2};
                STD(ii) = std(velocity);
            else
                STD(ii) = nan;
            end
        end
        STD = STD(~isnan(STD));
    end
%% 画频次分布直方图
    figure('visible','off'); % 绘图但不弹出
    [counts,centers] = hist(STD, 10);
    bar(centers,counts,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.8)
    ylim([0,max(counts)*1.1]); 

%% 画概率密度曲线
    [mu, sigma, muCI, sigmaCI] = normfit(STD, 0.05); % 分布参数拟合
    x1 = -5:0.0001:5; y1 = pdf('Normal', x1, mu, sigma);
    hold on; yyaxis right; box on; 
    h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',0.8);

%% 图形设置
    % 设置图形大小
    legend(h,'高斯分布拟合','EdgeColor','w','FontName','宋体','FontSize',10);
    xlim([mu-3*sigma,mu+3*sigma]);
    ylim([0,max(y1)*1.1]); % 放宽并取整
    MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % 控制出图背景色和大小
    % 设置坐标轴刻度
    ax = gca;
    ax.YColor = 'k';
    ax.XAxis.MinorTick = 'on'; 
    Xlims = ax.XLim; Ylims = ax.YLim;
    ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2);
    ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.YAxis(1).MinorTick = 'on'; ax.YAxis(2).MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis(1).MinorTickValues = ax.YAxis(1).TickValues(1):diff([ax.YAxis(1).TickValues(1),ax.YAxis(1).TickValues(2)])/2:ax.YAxis(1).TickValues(end);
    ax.YAxis(2).MinorTickValues = ax.YAxis(2).TickValues(1):diff([ax.YAxis(2).TickValues(1),ax.YAxis(2).TickValues(2)])/2:ax.YAxis(2).TickValues(end);
    set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-2.5 0 1.8 0; 0 -2.2 0 2.5; 0 0 3 0; 0 0 0 0]); % 去除图形周围多余空白
    % 设置坐标标签
    ylabel('高斯分布概率密度','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2,'position',[Xlims(2)+0.05*diff(Xlims) mean(Ylims)])
    yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim;
    xlabel('振动STD/(m\cdots^{\fontsize{6}-2})','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.09*diff(Ylims)])
    ylabel('频数/个','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2)
    % 取消最上面那条边线的刻度
    box off
    ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
    set(ax2,'YTick', []); set(ax2,'XTick', []);
    box on

%% 保存图片
    if if_save_pictures
        picture_type = '.png';
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  STD-',number,picture_type];
        if if_log; picture_path = strrep(picture_path, 'STD-', 'STD(LN)-'); end
        f=getframe(gcf); imwrite(f.cdata,picture_path)
    end
end

%% 生成Markdown文件
CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Months.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);


%% Step2（仅当 if_log==2 时，才通过Step2）
if if_log == 2
    %% 循环出某一测点各小时的STD柱状分布图和高斯拟合曲线
    if_log = 0; % 为了可以生成不含(LN)的Markdown，需要做此处理
    for n = 1:23
        close all
        number = num2str(n,'%02d');
        time_stamp = [number,':00:00.000'];
        STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % 和Lilliefors生成的数据一样，可共用

    %% 读取数据
        format long g
        fileID = fopen(STD_path(2:end-1),'r');
        STD = cell2mat(textscan(fileID,'%f'));
        % 3sigma法则
        if if_sigma == 1
            STD_mean = mean(STD);
            STD_std = std(STD);
            STD = STD(abs(STD-STD_mean)<=2*STD_std);
        end
    %% 画频次分布直方图
        figure('visible','off'); % 绘图但不弹出
        [counts,centers] = hist(STD, 10);
        bar(centers,counts,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.8)
        ylim([0,max(counts)*1.1]); 

    %% 画概率密度曲线
        [mu, sigma, muCI, sigmaCI] = normfit(STD, 0.05); % 分布参数拟合
        x1 = -5:0.0001:5; y1 = pdf('Normal', x1, mu, sigma);
        hold on; yyaxis right; box on; 
        h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',0.8);

    %% 图形设置
        % 设置图形大小
        legend(h,'高斯分布拟合','EdgeColor','w','FontName','宋体','FontSize',10);
        xlim([mu-3*sigma,mu+3*sigma]);
        ylim([0,max(y1)*1.1]); % 放宽并取整
        MonitorPosition = get(0,'MonitorPosition'); 
        set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % 控制出图背景色和大小
        % 设置坐标轴刻度
        ax = gca;
        ax.YColor = 'k';
        ax.XAxis.MinorTick = 'on'; 
        Xlims = ax.XLim; Ylims = ax.YLim;
        ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2);
        ax.TickDir='out'; ax.TickLength = [0.008 0.025];
        ax.YAxis(1).MinorTick = 'on'; ax.YAxis(2).MinorTick = 'on'; 
        ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
        ax.YAxis(1).MinorTickValues = ax.YAxis(1).TickValues(1):diff([ax.YAxis(1).TickValues(1),ax.YAxis(1).TickValues(2)])/2:ax.YAxis(1).TickValues(end);
        ax.YAxis(2).MinorTickValues = ax.YAxis(2).TickValues(1):diff([ax.YAxis(2).TickValues(1),ax.YAxis(2).TickValues(2)])/2:ax.YAxis(2).TickValues(end);
        set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-2.5 0 1.8 0; 0 -2.2 0 2.5; 0 0 3 0; 0 0 0 0]); % 去除图形周围多余空白
        % 设置坐标标签
        ylabel('高斯分布概率密度','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2,'position',[Xlims(2)+0.05*diff(Xlims) mean(Ylims)])
        yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim;
        xlabel('振动STD/(m\cdots^{\fontsize{6}-2})','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2,'position',[mean(Xlims) Ylims(1)-0.09*diff(Ylims)])
        ylabel('频数/个','FontName','宋体','FontWeight','bold','FontSize',12,'LineWidth',2)
        % 取消最上面那条边线的刻度
        box off
        ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
        set(ax2,'YTick', []); set(ax2,'XTick', []);
        box on

    %% 保存图片
        if if_save_pictures
            picture_type = '.png';
            picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  STD-',number,picture_type];
            f=getframe(gcf); imwrite(f.cdata,picture_path)
        end
    end

    %% 生成Markdown文件
    CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Months.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String2);
    
    CMD_String3 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_GaussFit_LN与非LN对比.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String3);   
end

%% 计时结束
toc
