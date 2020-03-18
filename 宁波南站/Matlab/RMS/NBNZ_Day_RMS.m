clc, clear, close all; tic  % �캣�� 2019��4��3��
% ��ע���� NBNZ_Day_STD.m ֻ��RMS/STD������ NBNZ_Day_Original.m ��ȫ��һ��

%% ����׼��
project = 'NBNZ-Day-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����\\���������ֵ'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����\\���������ֵ';
long = 6000; % ��������
Fs = 100; % ����Ƶ��

position_type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',position_type,'\\',position];
Duration_days = datestr([datenum(date_start) : datenum(date_end)],'yyyy-mm-dd');

if_log = 2; % 0����ȡ������ֻͨ��Step1��1��ȡ����,ֻͨ��Step1��2����Ҫ����ȡ����ͨ��step2���ٲ�ȡ����ͨ��Step1
if_save_pictures = 1; % �Ƿ񱣴�ͼƬ
if_python = 0; % 0�����ٴ���ֱ�Ӷ�ȡPython����õ����ݣ�1����Python��������

%% Step1
%% ѭ����ÿ���RMS-GPRʱ��ͼ
for ii = 1:size(Duration_days,1)
    close all
    day_specified = Duration_days(ii,:); 
    RMS_path = ['"',sub_path,'\\','RMS-',day_specified,'.txt','"'];

%% ����Python������������
    if if_python == 1
        CMD_String = ['python ..\..\Python�ű�\RMS\NBNZ-һ�����RMS.py',' ',sub_path,' ',day_specified,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
        [status,result] = system(CMD_String);
        if status == 1; continue; end % ȷ�����������ٿ�����һ�У���Ϊ��Щ������ݲ����ڣ��ᱨ����ʱ�����ֹ��ѭ����������һ��
    end

%% ��ȡ����
    format long g
    if ~exist(RMS_path(2:end-1),'file'); disp(['ȱʧ',RMS_path(end-14:end-1)]); continue; end
    fileID = fopen(RMS_path(2:end-1),'r');
    RMS_data = cell2mat(textscan(fileID,'%f %f'));
    time_series = [1:1440]'; 
    time_stamp = RMS_data(:,1);
    RMS = RMS_data(:,2);
    if length(RMS) < 5; disp(['ȱʧ',RMS_path(end-14:end-1)]); continue; end
    % �Ƿ�ȡ����
    if if_log; RMS = log(RMS); end
    
%% ����RMS-GPRʱ��ͼ
    figure('visible','on'); hold on; xlim([1 1440]);
    % ���ɷ�����
    GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','exact','KernelFunction','matern32');
    % ���㲢����95%��������
    [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
    patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
    % �������ݵ㼰Ԥ��ֵ
    plot(time_stamp,RMS,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
    plot(time_series,RMSpred,'r','LineWidth',0.8); box off
    legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off
    % ����ͼ��
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
    % ����������̶�
    ylim([Ylims(1),Ylims(2)]); % ��һ���������y������ң��õ�������
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025]; ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5,'position',[Xlims(1)-0.032*diff(Xlims) mean(Ylims)])

%% ����ͼƬ
    if if_save_pictures
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','RMS-',day_specified];
        if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
        print(gcf, '-dpng', picture_path)
    end
end

%% ����Markdown�ļ�
CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% Step2������ if_log==2 ʱ����ͨ��Step2��
if if_log == 2  
    %% ѭ����ÿ���RMS-GPRʱ��ͼ
    if_log = 0; % Ϊ�˿������ɲ���(LN)��Markdown����Ҫ���˴���
    for ii = 1:size(Duration_days,1)
        close all
        day_specified = Duration_days(ii,:); 
        RMS_path = ['"',sub_path,'\\','RMS-',day_specified,'.txt','"'];

    %% ��ȡ����
        format long g
        if ~exist(RMS_path(2:end-1),'file'); disp(['ȱʧ',RMS_path(end-14:end-1)]); continue; end
        fileID = fopen(RMS_path(2:end-1),'r');
        RMS_data = cell2mat(textscan(fileID,'%f %f'));
        time_series = [1:1440]'; 
        time_stamp = RMS_data(:,1);
        RMS = RMS_data(:,2);
        if length(RMS) < 5; disp(['ȱʧ',RMS_path(end-14:end-1)]); continue; end

    %% ����RMS-GPRʱ��ͼ
        figure('visible','off'); hold on; box off; xlim([1 1440]);
        % ���ɷ�����
        GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','exact','KernelFunction','matern32');
        % ���㲢����95%��������
        [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
        patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
        % �������ݵ㼰Ԥ��ֵ
        plot(time_stamp,RMS,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
        plot(time_series,RMSpred,'r','LineWidth',0.8); box off
        legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off
        % ����ͼ��
        MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
        set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
        % ����������̶�
        ylim([Ylims(1),Ylims(2)]); % ��һ���������y������ң��õ�������
        set(gca,'YTickLabel',num2str(get(gca,'YTick'),'%.1f'),'FontName','Cambria')
        set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
        ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025]; ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
        ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
        ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
        % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
        set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
        ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5,'position',[Xlims(1)-0.032*diff(Xlims) mean(Ylims)])

    %% ����ͼƬ
        if if_save_pictures
            picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\','RMS-',day_specified];
            print(gcf, '-dpng', picture_path)
        end
    end

    %% ����Markdown�ļ�
    CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String2);
    
    CMD_String3 = ['python ..\..\�ű�������\����Markdown\����Markdown_GaussFit_LN���LN�Ա�.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String3);
end    

%% ��ʱ����
toc
