clc, clear, close all; tic  % �캣�� 2019��4��22��
% ��ע���� NBNZ_Lilliefors_STD.m ֻ��RMS/STD

%% ����׼��
project = 'NBNZ-Lilliefors-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����\\���������ֵ'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����\\���������ֵ'
long = 6000; % ��������
Fs = 100; % ����Ƶ��

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1; % �Ƿ��޳��쳣����
if_log = 2; % 0����ȡ������ֻͨ��Step1��1��ȡ����,ֻͨ��Step1��2����Ҫ����ȡ����ͨ��step2���ٲ�ȡ����ͨ��Step1
if_save_pictures = 1; % �Ƿ񱣴�ͼƬ
if_python = 0; % 0�����ٴ���ֱ�Ӷ�ȡPython����õ����ݣ�1����Python��������   % ��GaussFit���ɵ�����һ�����ɹ���
data = zeros(23,3); data(:,1) = 1:23; % �������������

%% Step1
%% ѭ����ĳһ����Сʱ��RMS��Lilliefors����ͼ
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % ��GaussFit���ɵ�����һ�����ɹ���
    
%% ����Python������������
    if if_python == 1
        CMD_String = ['python ..\..\Python�ű�\RMS\NBNZ-ָ��ʱ����RMS.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% ��ȡ����
    format long g
    fileID = fopen(RMS_path(2:end-1),'r');
    RMS = cell2mat(textscan(fileID,'%f'));
    % �Ƿ�ȡ����
    if if_log; RMS = log(RMS); end
    % 3sigma����
    if if_sigma == 1
        RMS_mean = mean(RMS); RMS_std = std(RMS);
        RMS = RMS(abs(RMS-RMS_mean)<=2*RMS_std);
    end
    
%% Lilliefors����
    figure('visible','off');
    [~,p,~,~] = lillietest(RMS,'Alpha',0.05,'MCTol',1e-3);
    data(n,3) = p;
    h = normplot(RMS); set(gca,'FontName','Cambria'); set(gcf,'color','w');
    h(1).Color = [0 0.447 0.741]; h(2).Color = 'r'; h(1).LineWidth = 0.7; h(2).LineWidth = 1.8; h(3).LineWidth = 0.7;
    title('Normal Probability Plot','FontSize',13,'FontWeight','bold');
    xlabel('Data','FontSize',12,'FontName','Cambria');
    ylabel('Probability','FontSize',12,'FontName','Cambria');

%% ����ͼƬ
    if if_save_pictures
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number];
        if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
        print(gcf, '-dpng', picture_path);
    end
end

%% Step2
if if_log == 2
    %% ѭ����ĳһ����Сʱ��RMS��Lilliefors����ͼ
    for n = 1:23
        close all
        number = num2str(n,'%02d');
        time_stamp = [number,':00:00.000'];
        RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % ��GaussFit���ɵ�����һ�����ɹ���

    %% ��ȡ����
        format long g
        fileID = fopen(RMS_path(2:end-1),'r');
        RMS = cell2mat(textscan(fileID,'%f'));
        % 3sigma����
        if if_sigma == 1
            RMS_mean = mean(RMS); RMS_std = std(RMS);
            RMS = RMS(abs(RMS-RMS_mean)<=2*RMS_std);
        end

    %% Lilliefors����
        figure('visible','off');
        [~,p,~,~] = lillietest(RMS,'Alpha',0.05,'MCTol',1e-3);
        data(n,2) = p;
        h = normplot(RMS); set(gca,'FontName','Cambria'); set(gcf,'color','w');
        h(1).Color = [0 0.447 0.741]; h(2).Color = 'r'; h(1).LineWidth = 0.7; h(2).LineWidth = 1.8; h(3).LineWidth = 0.7;
        title('Normal Probability Plot','FontSize',13,'FontWeight','bold');
        xlabel('Data','FontSize',12,'FontName','Cambria');
        ylabel('Probability','FontSize',12,'FontName','Cambria');

    %% ����ͼƬ
        if if_save_pictures
            picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number];
            print(gcf, '-dpng', picture_path);
        end
    end
    
    %% ����Excel
    xlspath = [picture_main_path,'\\',date_start,' to ',date_end,'  ',project,'.xlsx'];
    if exist(xlspath,'file'); delete xlspath; end
    xlswrite(xlspath,data)

    %% ����Markdown�ļ�
    CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Lilliefors_LN���LN�Ա�.py',' ',project,' ',position,' ',date_start,' ',date_end];
    system(CMD_String2);
end

%% ��ʱ����
toc
