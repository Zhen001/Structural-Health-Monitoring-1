clc,clear,close all;tic  % 朱海涛 2019年4月17日

%% 单个数据
time_series1 = [1:1000]';
time_series2 = [1:1000]';
y1 = 3 * log(time_series1); y1 = awgn(y1,10);
y2 = 5 * log(time_series2); y2 = awgn(y2,10);

%% 混合数据
time_series = [time_series1;time_series2];
y = [y1;y2];

%% 学习用
% time_series = time_series1;
% y = log(time_series);
% y = awgn(y,10);

%% 绘制STD-GPR时序图
GPRMdl = fitrgp(time_series,y,'Basis','linear','FitMethod','exact','PredictMethod','exact');
% 95%置信区间
[ypred,~,yci] = predict(GPRMdl,time_series1,'Alpha',0.05); hold on;
patch([time_series1;flip(time_series1)],[yci(:,1);flip(yci(:,2))],[0.8,0.8,0.8],'edgealpha',0.2,'facealpha',0.25)
% 数据点及预测值
plot(time_series,y,'.','MarkerSize',5,'Color',[0 0.447 0.741]);
plot(time_series1,ypred,'r','LineWidth',0.8); xlim([1,length(time_series1)]); box off

%% 计时结束
toc