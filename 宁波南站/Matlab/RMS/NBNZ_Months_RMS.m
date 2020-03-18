clc, clear, close all; tic  % �캣�� 2019��4��3��
% ��ע���� NBNZ_Months_STD.m ֻ��RMS/STD

%% ����׼��
project = 'NBNZ-Months-RMS';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����\\���������ֵ'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����\\���������ֵ';
long = 6000; % ��������
Fs = 100; % ����Ƶ��

position_type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',position_type,'\\',position];
% **************
sub_path = 'E:\\�����ġ�\\��С���ġ�\\������վ\\Python�ű�\\GPR';
% **************
RMS_path = ['"',sub_path,'\\',date_start,' to ',date_end,'������RMS.txt','"'];

if_log = 1; % 0����ȡ������ֻͨ��Step1��1��ȡ����,ֻͨ��Step1��2����Ҫ����ȡ����ͨ��step2���ٲ�ȡ����ͨ��Step1
if_save_pictures = 0; % �Ƿ񱣴�ͼƬ
if_python = 0; % �Ƿ����Python���������ȡ�Ѵ���õ�����
reject_method = 1; % 0�����޳����ݣ�1��3sigma����2��һ����

%% Step1
%% ����Python������������
if if_python == 1
    CMD_String = ['python ..\..\Python�ű�\RMS\NBNZ-N���µ�RMS.py',' ',sub_path,' ',date_start,' ',date_end,' ',num2str(long),' ',num2str(Fs),' ',RMS_path];
    [status,result] = system(CMD_String); display(result)
end

%% ��ȡ����
format long g
fileID = fopen(RMS_path(2:end-1),'r');
data = textscan(fileID,'%f %f');
time_series = [1:1440]'; 
data = [data{1},data{2}];
% data = sortrows(data,1); % ��ʱ������

%% �޳��쳣ֵ
new_data = [];
% ���޳�����
if reject_method == 0
    new_data = data;
end
% 3sigma����
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
% һ����
if reject_method == 2
    new_data = data(data(:,2)<0.2,:);
end
% �޳�����
proportion = (length(data) - length(new_data)) / length(data);
sprintf('%2.2f%%', proportion*100)
time_stamp = new_data(:,1);
% �Ƿ�ȡ����
if if_log
    RMS = log(new_data(:,2));
else
    RMS = new_data(:,2);
end

%% ����RMS-GPRʱ��ͼ
figure('visible','on');hold on; xlim([1 1440]);
% ���ɷ�����
GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','sd','KernelFunction','matern32');
% ���㲢����95%��������
[RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.5,'facealpha',0.25)
% �������ݵ㼰Ԥ��ֵ
plot(time_stamp,RMS,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
plot(time_series,RMSpred,'r','LineWidth',0.8); 
legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

%% ����ͼ��
MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
% ����������̶�
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % �ظ�һ�Σ���֤y�����ܹ���Ӧ
% ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5)

%% ����ͼƬ
if if_save_pictures
    picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project];
    if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
    picture_path = [picture_main_path,'\\','RMS-',date_start,' to ',date_end];
    if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
    print(gcf, '-dpng', picture_path)
end

%% Step2������ if_log==2 ʱ����ͨ��Step2��
if if_log == 2
    %% ��ȡ����
    format long g
    fileID = fopen(RMS_path(2:end-1),'r');
    data = textscan(fileID,'%f %f');
    time_series = [1:1440]'; 
    data = [data{1},data{2}];

    %% �޳��쳣ֵ
    new_data = [];
    % ���޳�����
    if reject_method == 0
        new_data = data;
    end
    % 3sigma����
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
    % һ����
    if reject_method == 2
        new_data = data(data(:,2)<0.2,:);
    end
    % �޳�����
    proportion = (length(data) - length(new_data)) / length(data);
    sprintf('%2.2f%%', proportion*100)
    time_stamp = new_data(:,1);
    % �Ƿ�ȡ����
    RMS = new_data(:,2);

    %% ����RMS-GPRʱ��ͼ
    figure('visible','on');hold on; xlim([1 1440]);
    % ���ɷ�����
    GPRMdl = fitrgp(time_stamp,RMS,'Basis','none','FitMethod','sd','PredictMethod','sd','KernelFunction','matern32');
    % ���㲢����95%��������
    [RMSpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
    patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.5,'facealpha',0.25)
    % �������ݵ㼰Ԥ��ֵ
    plot(time_stamp,RMS,'.','MarkerSize',3,'Color',[0 0.447 0.741]);
    plot(time_series,RMSpred,'r','LineWidth',0.8); 
    legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w','FontName','Cambria','FontSize',9); hold off

    %% ����ͼ��
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
    % ����������̶�
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria')
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'},'FontName','Cambria')
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % �ظ�һ�Σ���֤y�����ܹ���Ӧ
    % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
    set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
    ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5)

    %% ����ͼƬ
    if if_save_pictures
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','RMS-',date_start,' to ',date_end];
        print(gcf, '-dpng', picture_path)
    end
end

%% ��ʱ����
toc
