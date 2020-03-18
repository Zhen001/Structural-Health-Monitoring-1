clc, clear, close all; tic  % 朱海涛 2019年4月22日

%% 参数准备
project = 'NBNZ-Lilliefors-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % 测点
date_start = '2014-09-15'; date_end = '2014-12-11'; % 起始时间
main_path = 'G:\\研一下\\宁波站数据'; % main_path = 'H:\\已完成数据\\'; main_path = 'G:\\研一下\\宁波站数据'
long = 6000; % 样本长度
Fs = 100; % 采样频率

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1;  % 是否剔除异常数据
if_log = 2;  % 0：不取对数；1：取对数；2：两种情况都要  % 默认取2，就是要做对比，所以取0和1没有意义，Markdown也没有调好会有问题
if_save_pictures = 1;  % 是否保存图片
if_python = 0;  % 0：不再处理，直接读取Python处理好的数据；1：用Python处理数据

%% 循环出某一测点各小时的STD的Lilliefors检验图
data = zeros(23,3); data(:,1) = 1:23;
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % 和GaussFit生成的数据一样，可共用
    
%% 调用Python对数据做处理
    if if_python == 1
        CMD_String = ['python ..\..\Python脚本\STD\NBNZ-指定时间点的STD.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% 读取数据
    format long g
    fileID = fopen(STD_path(2:end-1),'r');
    % 是否取对数
    if if_log == 1 % 此时直接将STD取对数
        STD = log(cell2mat(textscan(fileID,'%f')));
    elseif if_log == 0 || if_log == 2 % 此时不取对数，若==2，则在Step2中再取对数
        STD = cell2mat(textscan(fileID,'%f'));
    end
    
%% Lilliefors检验 Step1
    figure('visible','off');set(gcf,'color','w')
    % 3sigma法则
    if if_sigma == 1
        STD_mean = mean(STD);
        STD_std = std(STD);
        STD1 = STD(abs(STD-STD_mean)<=2*STD_std);
    end
    [~,p,~,~] = lillietest(STD1,'Alpha',0.05,'MCTol',1e-3);
    data(n,2) = p; 
    h1 = normplot(STD1);
    h1(1).Color = [0 0.447 0.741]; h1(2).Color = 'r'; h1(1).LineWidth = 0.7; h1(2).LineWidth = 0.7; h1(3).LineWidth = 0.7;
    title('Normal Probability Plot','FontName','Times New Roman','FontSize',13,'FontWeight','bold');
    xlabel('Data','FontName','Times New Roman','FontSize',12);
    ylabel('Probability','FontName','Times New Roman','FontSize',12)
    f1 = getframe(gcf); h1 = gcf;
    
%% Lilliefors检验 Step2
    if if_log == 2
        figure('visible','off');set(gcf,'color','w')
        STD2 = log(STD);
        % 3sigma法则
        if if_sigma == 1
            STD2_mean = mean(STD2);
            STD2_std = std(STD2);
            STD2 = STD2(abs(STD2-STD2_mean)<=2*STD2_std);
        end
        [~,p,~,~] = lillietest(STD2,'Alpha',0.05,'MCTol',1e-3);
        data(n,3) = p;
        h2 = normplot(STD2);
        h2(1).Color = [0 0.447 0.741]; h2(2).Color = 'r'; h2(1).LineWidth = 0.7; h2(2).LineWidth = 0.7; h2(3).LineWidth = 0.7;
        title('Normal Probability Plot','FontName','Times New Roman','FontSize',13,'FontWeight','bold');
        xlabel('Data','FontName','Times New Roman','FontSize',12);
        ylabel('Probability','FontName','Times New Roman','FontSize',12)
        f2 = getframe(gcf); h2 = gcf;
    end

%% 保存数据和图片
    if if_save_pictures
        picture_type = '.png';
        picture_main_path = ['E:\\【论文】\\【小论文】\\宁波南站\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path1 = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number,picture_type];
        saveas(h1,picture_path1);
        if if_log == 2 
            picture_path2 = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'(LN)-',number,picture_type];
            saveas(h2,picture_path2);
        end
    end
end

%% 保存Excel
xlspath = [picture_main_path,'\\',date_start,' to ',date_end,'  ',project,'.xlsx'];
if exist(xlspath,'file'); delete xlspath; end
xlswrite(xlspath,data)

%% 生成Markdown文件
CMD_String2 = ['python ..\..\脚本控制器\生成Markdown\生成Markdown_Lilliefors_LN与非LN对比.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% 计时结束
toc
