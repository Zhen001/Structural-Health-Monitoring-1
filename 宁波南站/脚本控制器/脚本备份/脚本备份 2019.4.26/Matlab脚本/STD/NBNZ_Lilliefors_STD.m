clc, clear, close all; tic  % �캣�� 2019��4��22��

%% ����׼��
project = 'NBNZ-Lilliefors-STD';
position = 'A-W-GGL1-2-Xx-accelerate'; % ���
date_start = '2014-09-15'; date_end = '2014-12-11'; % ��ʼʱ��
main_path = 'G:\\��һ��\\����վ����'; % main_path = 'H:\\���������\\'; main_path = 'G:\\��һ��\\����վ����'
long = 6000; % ��������
Fs = 100; % ����Ƶ��

position_type = position(sum(position<'a'| position>'z'):end);
data_type = strsplit(project,'-'); data_type = data_type{end};
sub_path = [main_path,'\\','Export-',position_type,'\\',position];

if_sigma = 1;  % �Ƿ��޳��쳣����
if_log = 2;  % 0����ȡ������1��ȡ������2�����������Ҫ  % Ĭ��ȡ2������Ҫ���Աȣ�����ȡ0��1û�����壬MarkdownҲû�е��û�������
if_save_pictures = 1;  % �Ƿ񱣴�ͼƬ
if_python = 0;  % 0�����ٴ���ֱ�Ӷ�ȡPython����õ����ݣ�1����Python��������

%% ѭ����ĳһ����Сʱ��STD��Lilliefors����ͼ
data = zeros(23,3); data(:,1) = 1:23;
for n = 1:23
    close all
    number = num2str(n,'%02d');
    time_stamp = [number,':00:00.000'];
    STD_path = ['"',sub_path,'\\',date_start,' to ',date_end,'-',data_type,'-',number,'.txt','"']; % ��GaussFit���ɵ�����һ�����ɹ���
    
%% ����Python������������
    if if_python == 1
        CMD_String = ['python ..\..\Python�ű�\STD\NBNZ-ָ��ʱ����STD.py',' ',sub_path,' ',date_start,' ',date_end,' ',time_stamp,' ',num2str(long),' ',num2str(Fs),' ',STD_path];
        [status,result] = system(CMD_String);
        display(result)
    end

%% ��ȡ����
    format long g
    fileID = fopen(STD_path(2:end-1),'r');
    % �Ƿ�ȡ����
    if if_log == 1 % ��ʱֱ�ӽ�STDȡ����
        STD = log(cell2mat(textscan(fileID,'%f')));
    elseif if_log == 0 || if_log == 2 % ��ʱ��ȡ��������==2������Step2����ȡ����
        STD = cell2mat(textscan(fileID,'%f'));
    end
    
%% Lilliefors���� Step1
    figure('visible','off');set(gcf,'color','w')
    % 3sigma����
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
    
%% Lilliefors���� Step2
    if if_log == 2
        figure('visible','off');set(gcf,'color','w')
        STD2 = log(STD);
        % 3sigma����
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

%% �������ݺ�ͼƬ
    if if_save_pictures
        picture_type = '.png';
        picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project,'\\',position];
        if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
        picture_path1 = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'-',number,picture_type];
        saveas(h1,picture_path1);
        if if_log == 2 
            picture_path2 = [picture_main_path,'\\',date_start,' to ',date_end,'  ',data_type,'(LN)-',number,picture_type];
            saveas(h2,picture_path2);
        end
    end
end

%% ����Excel
xlspath = [picture_main_path,'\\',date_start,' to ',date_end,'  ',project,'.xlsx'];
if exist(xlspath,'file'); delete xlspath; end
xlswrite(xlspath,data)

%% ����Markdown�ļ�
CMD_String2 = ['python ..\..\�ű�������\����Markdown\����Markdown_Lilliefors_LN���LN�Ա�.py',' ',project,' ',position,' ',date_start,' ',date_end,' ',num2str(if_log)];
system(CMD_String2);

%% ��ʱ����
toc
