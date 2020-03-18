clc, clear, close all; tic  % �캣�� 2019��4��3��
% ��ע���� NBNZ_Day_RMS.m ֻ��RMS/STD������ NBNZ_Day_Original.m ��ȫ��һ��

%% ����׼��
project = 'NBNZ-Day-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����';
long = 6000;  % ��������
Fs = 100;    % ����Ƶ��
type = position(sum(position<'a'| position>'z'):end);
sub_path = [main_path,'\\','Export-',type,'\\',position];
Duration_days = datestr([datenum(date_start) : datenum(date_end)],'yyyy-mm-dd');

if_log = 1; % �Ƿ�ȡ����
if_save_pictures = 1;  % �Ƿ񱣴�ͼƬ
if_python = 1; % 0�����ٴ���ֱ�Ӷ�ȡPython����õ����ݣ�1����Python��������

%% ѭ����ÿ���STD-GPRʱ��ͼ
for ii = 1:size(Duration_days,1)
    close all
    day_specified = Duration_days(ii,:); 
    STD_path = ['"',sub_path,'\\','STD-',day_specified,'.txt','"'];
    
%% ����Python������������
    if if_python == 1
        CMD_String = ['python ..\..\Python�ű�\STD\NBNZ-һ�����STD.py',' ',sub_path,' ',day_specified,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
        [status,result] = system(CMD_String);
        if status == 1; continue; end % ȷ�����������ٿ�����һ��
    end

%% ��ȡ����
    format long g
    if ~exist(STD_path(2:end-1),'file'); disp(['ȱʧ',STD_path(end-14:end-1)]); continue; end
    fileID = fopen(STD_path(2:end-1),'r');
    STD_data = cell2mat(textscan(fileID,'%f %f'));
    time_series = [1:1440]'; 
    time_stamp = STD_data(:,1);
    STD = STD_data(:,2);
    if length(STD) < 5; disp(['ȱʧ',STD_path(end-14:end-1)]); continue; end
    % �Ƿ�ȡ����
    if if_log; STD = log(STD); end
    
%% ����STD-GPRʱ��ͼ
    figure('visible','off'); hold on; xlim([1 1440]);
    GPRMdl = fitrgp(time_stamp,STD,'Basis','none','FitMethod','sd','PredictMethod','exact','KernelFunction','matern32');
    % ���㲢����95%��������
    [STDpred,~,yci] = predict(GPRMdl,time_series,'Alpha',0.05);
    patch([time_series;flip(time_series)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
    % �������ݵ㼰Ԥ��ֵ
    hold on;
    h2 = plot(time_stamp,STD,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
    plot(time_series,STDpred,'r','LineWidth',0.8); box off
    % ����ͼ��
    legend('95% Confidence Interval','Data','GPR Predictions','Location','northwest','EdgeColor','w'); hold off
    MonitorPosition = get(0,'MonitorPosition'); Xlims = get(gca,'Xlim'); Ylims = get(gca,'Ylim');
    set(gcf,'color','w','position',[0.05*MonitorPosition(3),MonitorPosition(4)/5,0.9*MonitorPosition(3),MonitorPosition(4)/4]); % ���Ƴ�ͼ����ɫ�ʹ�С
    ylabel('STD / (m\cdots^{\fontsize{6}-2})','FontName','Times New Roman','FontSize',11,'LineWidth',2,'position',[Xlims(1)-0.035*diff(Xlims) mean(Ylims)])
    % ����������̶�
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'))
    set(gca,'XTick',linspace(Xlims(1),Xlims(2),13),'XTickLabel',{'0:00','2:00','4:00','6:00','8:00','10:00','12:00','14:00','16:00','18:00','20:00','22:00','24:00'})
    ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
    ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
    set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-2.3 0 2.3 0; 0 -1.5 0 1.8; 0 0 1.5 0; 0 0 0 1.5]);
    ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
    ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f')) % �ظ�һ�Σ���֤y�����ܹ���Ӧ

%% ����ͼƬ
    if if_save_pictures
        picture_type = '.png';
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\','STD-',day_specified,picture_type];
        if if_log; picture_path = strrep(picture_path, 'STD-', 'STD(LN)-'); end
        f=getframe(gcf); imwrite(f.cdata,picture_path)
    end
end

%% ����Markdown�ļ�
CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Day.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% ��ʱ����
toc
