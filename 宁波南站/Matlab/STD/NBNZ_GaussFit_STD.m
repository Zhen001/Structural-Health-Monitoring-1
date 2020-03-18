clc, clear, close all; tic  % �캣�� 2019��4��1��
% ��ע���� NBNZ_GaussFit_RMS.m ֻ��RMS/STD

%% ����׼��
project = 'NBNZ-GaussFit-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����\\���������ֵ'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����\\���������ֵ';
long = 6000; % ��������
Fs = 100; % ����Ƶ��

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1; % �Ƿ��޳��쳣����
if_log = 2; % 0����ȡ������ֻͨ��Step1��1��ȡ����,ֻͨ��Step1��2����Ҫ����ȡ����ͨ��step2���ٲ�ȡ����ͨ��Step1
if_save_pictures = 1; % �Ƿ񱣴�ͼƬ
if_python = 0; % 0�����ٴ���ֱ�Ӷ�ȡPython����õ����ݣ�1����Python�������ݣ�2����Matlab�������ݣ�ֻ��Ϊ�����´����¼����python����һ�㣩

%% Step1
%% ѭ����ĳһ����Сʱ��STD��״�ֲ�ͼ�͸�˹�������
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % ��Lilliefors���ɵ�����һ�����ɹ���
    
%% ����Python������������
    if if_python == 1
        CMD_String = ['python ..\..\Python�ű�\STD\NBNZ-ָ��ʱ����STD.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% ��ȡ����
    format long g
    fileID = fopen(STD_path(2:end-1),'r');
    STD = cell2mat(textscan(fileID,'%f'));
    % �Ƿ�ȡ����
    if if_log; STD = log(STD); end
    % 3sigma����
    if if_sigma == 1
        STD_mean = mean(STD);
        STD_std = std(STD);
        STD = STD(abs(STD-STD_mean)<=2*STD_std);
    end
    
%% ��Matlab�Լ�������������ֻ��Ϊ�����´����¼����python����һ�㣩
    if if_python == 2
        % �����ļ��� �� �ų���������
        file_list = dir(sub_path);
        file_list = {file_list.name}; % ��struct�ṹתΪcell�������ַ�������
        file_list = cellfun(@(x) string(x(1:end-4)),file_list); % ��cellת�����ַ��������������״���
        file_list(~contains(file_list,'-') | contains(file_list,'to') |file_list == '' | file_list == 'errorTime') = []; % ɾ��������Ŀ
        % ���δ���ʱ����ڵ�TXT�ĵ�������������Ҫ��ʱ��㣬������STD
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
                disp(['����ȱʧ1��',filename{ii}])
                flag1 = 0; flag2 = 0;
            end
            while flag1  % �����ж��Ƿ񵽴�ʱ���
                data = textscan(fileID,'%s %f64',1);
                if datenum(data{1}{1}) == time_stamp1
                    flag1 = 0;
                elseif datenum(data{1}{1}) > time_stamp1
                    flag1 = 0; flag2 = 0;
                    disp(['����ȱʧ2��',filename{ii}])
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

%% ��Ƶ�ηֲ�ֱ��ͼ
    figure('visible','off'); % ��ͼ��������
    [counts,centers] = hist(STD, 10); % ����ֱ��ͼ
    bar(centers,counts,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.8) % ����ֱ��ͼ
    ylim([0,1.05*max(counts)]) % ��ֱ��ͼ�ϱ߽���һ��ռ�

%% �������ܶ�����
    hold on; yyaxis right;
    [mu, sigma, muCI, sigmaCI] = normfit(STD, 0.05); % �ֲ��������
    x1 = mu-3*sigma:0.001:mu+3*sigma; y1 = pdf('Normal', x1, mu, sigma); % ��������ܶ�����
    h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',0.8); % ���Ƹ����ܶ�����
    xlim([mu-3*sigma,mu+3*sigma]); % ��x��Χ���������Ҹ�3sigma֮��
    ylim([0,1.05*max(y1)]) % �������ϱ߽���һ��ռ�
    legend(h,'��˹�ֲ����','EdgeColor','w','FontName','����','FontSize',12);
    
%% ͼ������
    % ����ͼ�δ�С
    MonitorPosition = get(0,'MonitorPosition'); 
    set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % ���Ƴ�ͼ����ɫ�ʹ�С
    % ����������̶�
    ax = gca; ax.YColor = 'k'; % ������������ɫ
    Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
    ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2); % ��x��ֳ�8��
    ax.TickDir='out'; ax.TickLength = [0.008 0.025]; % ���ÿ̶ȷ���ʹ�С
    ax.XAxis.MinorTick = 'on'; ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end); % ����С�̶�����
    set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'),'FontName','Cambria');
    set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1.05 0; 0 0 0 1]); % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
    % ���������ǩ
    ylabel('��˹�ֲ������ܶ�','FontName','����','FontWeight','bold','FontSize',12,'position',[Xlims(2)+0.05*diff(Xlims) mean(Ylims)])
    yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
    xlabel('��STD/(m\cdots^{\fontsize{6}-2})','FontName','����','FontWeight','bold','FontSize',12,'position',[mean(Xlims) Ylims(1)-0.095*diff(Ylims)])
    ylabel('Ƶ�� / ��','FontName','����','FontWeight','bold','FontSize',12)
    % ȡ���������������ߵĿ̶�
    box off; ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
    set(ax2,'YTick', []); set(ax2,'XTick', []); box on

%% ����ͼƬ
    if if_save_pictures
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  STD-',number];
        if if_log; picture_path = strrep(picture_path, 'STD-', 'STD(LN)-'); end
        print(gcf, '-dpng', picture_path)
    end
end

%% ����Markdown�ļ�
CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Months.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% Step2������ if_log==2 ʱ����ͨ��Step2��
if if_log == 2
    %% ѭ����ĳһ����Сʱ��STD��״�ֲ�ͼ�͸�˹�������
    if_log = 0; % Ϊ�˿������ɲ���(LN)��Markdown����Ҫ���˴���
    for n = 1:23
        close all
        number = num2str(n,'%02d');
        time_stamp = [number,':00:00.000'];
        STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % ��Lilliefors���ɵ�����һ�����ɹ���

    %% ��ȡ����
        format long g
        fileID = fopen(STD_path(2:end-1),'r');
        STD = cell2mat(textscan(fileID,'%f'));
        % 3sigma����
        if if_sigma == 1
            STD_mean = mean(STD);
            STD_std = std(STD);
            STD = STD(abs(STD-STD_mean)<=2*STD_std);
        end
    %% ��Ƶ�ηֲ�ֱ��ͼ
        figure('visible','off'); % ��ͼ��������
        [counts,centers] = hist(STD, 10); % ����ֱ��ͼ
        bar(centers,counts,0.85,'FaceColor','w','EdgeColor',[0 0 0],'LineWidth',0.8) % ����ֱ��ͼ
        ylim([0,1.05*max(counts)]) % ��ֱ��ͼ�ϱ߽���һ��ռ�

    %% �������ܶ�����
        hold on; yyaxis right;
        [mu, sigma, muCI, sigmaCI] = normfit(STD, 0.05); % �ֲ��������
        x1 = mu-3*sigma:0.001:mu+3*sigma; y1 = pdf('Normal', x1, mu, sigma); % ��������ܶ�����
        h = plot(x1,y1,'Color',[0 0.447 0.741],'LineWidth',0.8); % ���Ƹ����ܶ�����
        xlim([mu-3*sigma,mu+3*sigma]); % ��x��Χ���������Ҹ�3sigma֮��
        ylim([0,1.05*max(y1)]) % �������ϱ߽���һ��ռ�
        legend(h,'��˹�ֲ����','EdgeColor','w','FontName','����','FontSize',12);

    %% ͼ������
        % ����ͼ�δ�С
        MonitorPosition = get(0,'MonitorPosition'); 
        set(gcf,'color','w','position',[0.2*MonitorPosition(3),MonitorPosition(4)/5,0.6*MonitorPosition(3),MonitorPosition(4)/2]); % ���Ƴ�ͼ����ɫ�ʹ�С
        % ����������̶�
        ax = gca; ax.YColor = 'k'; % ������������ɫ
        Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
        ax.XTick = Xlims(1): diff(Xlims)/8: Xlims(2); % ��x��ֳ�8��
        ax.TickDir='out'; ax.TickLength = [0.008 0.025]; % ���ÿ̶ȷ���ʹ�С
        ax.XAxis.MinorTick = 'on'; ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end); % ����С�̶�����
        set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.0f'),'FontName','Cambria');
        set(gca, 'Position', get(gca, 'OuterPosition') - 2.3 * get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1.05 0; 0 0 0 1]); % ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
        % ���������ǩ
        ylabel('��˹�ֲ������ܶ�','FontName','����','FontWeight','bold','FontSize',12,'position',[Xlims(2)+0.05*diff(Xlims) mean(Ylims)])
        yyaxis left; Xlims = ax.XLim; Ylims = ax.YLim; % ��ȡx,y�᷶Χ
        xlabel('��STD/(m\cdots^{\fontsize{6}-2})','FontName','����','FontWeight','bold','FontSize',12,'position',[mean(Xlims) Ylims(1)-0.095*diff(Ylims)])
        ylabel('Ƶ�� / ��','FontName','����','FontWeight','bold','FontSize',12)
        % ȡ���������������ߵĿ̶�
        box off; ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Color','none','XColor','k','YColor','none');
        set(ax2,'YTick', []); set(ax2,'XTick', []); box on

    %% ����ͼƬ
        if if_save_pictures
            picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
            if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
            picture_path = [picture_main_path,'\\',date_start,' to ',date_end,'  STD-',number];
            print(gcf, '-dpng', picture_path)
        end
    end

    %% ����Markdown�ļ�
    CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Months.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String2);
    
    CMD_String3 = ['python ..\..\�ű�������\����Markdown\����Markdown_GaussFit_LN���LN�Ա�.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
    system(CMD_String3);
end

%% ��ʱ����
toc
