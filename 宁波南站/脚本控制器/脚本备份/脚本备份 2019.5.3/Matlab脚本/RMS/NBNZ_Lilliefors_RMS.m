clc, clear, close all; tic  % 朱海涛 2019年4月22日
% 备注：与 NBNZ_Lilliefors_STD.m 只差RMS/STD

%% 参数准备
project = 'NBNZ-Lilliefors-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据\\已拉回零均值'
long = 6000; % 样本长度
Fs = 100; % 采样频率

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1; % 是否剔除异常数据
if_log = 2; % 0：不取对数，只通过Step1；1：取对数,只通过Step1；2：都要，先取对数通过step2，再不取对数通过Step1
if_save_pictures = 1; % 是否保存图片
if_python = 0; % 0：不再处理，直接读取Python处理好的数据；1：用Python处理数据   % 和GaussFit生成的数据一样，可共用
data = zeros(23,3); data(:,1) = 1:23; % 输出到表格的内容

%% Step1
%% 循环出某一测点各小时的RMS的Lilliefors检验图
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % 和GaussFit生成的数据一样，可共用
    
%% 调用Python对数据做处理
    if if_python == 1
        CMD_String = ['python ..\..\Python脚本\RMS\NBNZ-指定时间点的RMS.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% 读取数据
    format long g
    fileID = fopen(RMS_path(2:end-1),'r');
    RMS = cell2mat(textscan(fileID,'%f'));
    % 是否取对数
    if if_log; RMS = log(RMS); end
    % 3sigma法则
    if if_sigma == 1
        RMS_mean = mean(RMS); RMS_std = std(RMS);
        RMS = RMS(abs(RMS-RMS_mean)<=2*RMS_std);
    end
    
%% Lilliefors检验
    figure('visible','off');
    [~,p,~,~] = lillietest(RMS,'Alpha',0.05,'MCTol',1e-3);
    data(n,3) = p;
    h = normplot(RMS); set(gca,'FontName','Cambria'); set(gcf,'color','w');
    h(1).Color = [0 0.447 0.741]; h(2).Color = 'r'; h(1).LineWidth = 0.7; h(2).LineWidth = 1.8; h(3).LineWidth = 0.7;
    title('Normal Probability Plot','FontSize',13,'FontWeight','bold');
    xlabel('Data','FontSize',12,'FontName','Cambria');
    ylabel('Probability','FontSize',12,'FontName','Cambria');

%% 保存图片
    if if_save_pictures
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number];
        if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
        print(gcf, '-dpng', picture_path);
    end
end

%% Step2
if if_log == 2
    %% 循环出某一测点各小时的RMS的Lilliefors检验图
    for n = 1:23
        close all
        number = num2str(n,'%02d');
        time_stamp = [number,':00:00.000'];
        RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % 和GaussFit生成的数据一样，可共用

    %% 读取数据
        format long g
        fileID = fopen(RMS_path(2:end-1),'r');
        RMS = cell2mat(textscan(fileID,'%f'));
        % 3sigma法则
        if if_sigma == 1
            RMS_mean = mean(RMS); RMS_std = std(RMS);
            RMS = RMS(abs(RMS-RMS_mean)<=2*RMS_std);
        end

    %% Lilliefors检验
        figure('visible','off');
        [~,p,~,~] = lillietest(RMS,'Alpha',0.05,'MCTol',1e-3);
        data(n,2) = p;
        h = normplot(RMS); set(gca,'FontName','Cambria'); set(gcf,'color','w');
        h(1).Color = [0 0.447 0.741]; h(2).Color = 'r'; h(1).LineWidth = 0.7; h(2).LineWidth = 1.8; h(3).LineWidth = 0.7;
        title('Normal Probability Plot','FontSize',13,'FontWeight','bold');
        xlabel('Data','FontSize',12,'FontName','Cambria');
        ylabel('Probability','FontSize',12,'FontName','Cambria');

    %% 保存图片
        if if_save_pictures
            picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number];
            print(gcf, '-dpng', picture_path);
        end
    end
    
    %% 保存Excel
    xlspath = [picture_main_path,'\\',date_start,' to ',date_end,'  ',project,'.xlsx'];
    if exist(xlspath,'file'); delete xlspath; end
    xlswrite(xlspath,data)

    %% 生成Markdown文件
    CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Lilliefors_LN与非LN对比.py',' ',project,' ',position,' ',date_start,' ',date_end];
    system(CMD_String2);
end

%% 计时结束
toc
