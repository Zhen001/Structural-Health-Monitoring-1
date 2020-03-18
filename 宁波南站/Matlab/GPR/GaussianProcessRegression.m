function y = GaussianProcessRegression(time_stamp,RMS,time_series)
%% ������ת��������
if size(time_stamp,1)==1, time_stamp=time_stamp'; end
if size(RMS,1)==1, RMS=RMS'; end
if size(time_series,1)==1, time_series=time_series'; end

%% ����RMS-GPRʱ��ͼ
figure('visible','on');hold on;
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
MonitorPosition = get(0,'MonitorPosition');
set(gcf,'color','w','position',[1,MonitorPosition(4)/5,MonitorPosition(3),MonitorPosition(4)/3.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
% ����������̶�
set(gca,'FontName','Cambria')
ax = gca; ax.TickDir='out'; ax.TickLength = [0.008 0.025];
ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on'; 
ax.XAxis.MinorTickValues = ax.XTick(1):diff([ax.XTick(1),ax.XTick(2)])/2:ax.XTick(end);
ax.YAxis.MinorTickValues = ax.YTick(1):diff([ax.YTick(1),ax.YTick(2)])/2:ax.YTick(end);
% ȥ��figure�ж���Ŀհײ��֣�ע�⣬�����ñ�ǩ֮ǰ������¿��Ա����鷳
set(gca, 'Position', get(gca, 'OuterPosition') - 2 * get(gca, 'TightInset') * [-1 0 1 0; 0 -0.6 0 0.6; 0 0 1 0; 0 0 0 0.5]);
ylabel('RMS / (m\cdots^{\fontsize{6}-2})','FontName','Cambria Math','FontSize',11.5)

%     %% ����ͼƬ
%     if if_save_pictures
%         picture_main_path = ['E:\\�����ġ�\\��С���ġ�\\������վ\\Pictures\\Pictures_',project];
%         if exist(picture_main_path,'dir')==0; mkdir(picture_main_path); end
%         picture_path = [picture_main_path,'\\','RMS-',date_start,' to ',date_end];
%         if if_log; picture_path = strrep(picture_path, 'RMS-', 'RMS(LN)-'); end
%         print(gcf, '-dpng', picture_path)
%     end
y = [RMSpred';yci'];
end