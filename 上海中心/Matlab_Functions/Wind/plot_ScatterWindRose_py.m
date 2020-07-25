function [] = plot_ScatterWindRose_py(Dir,U,Z,name_U,name_Z,scatter_colormap,scatter_size,scatter_LineWidth,scatter_MarkerFaceAlpha,scatter_MarkerEdgeAlpha,picture_path)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% 关闭其他所有图片
close all

% set limits and labels
limU = [min(U),max(U)]; % #3 limites for the wind speed

% plot the data
figure
ScatterWindRose(Dir,U,scatter_colormap,scatter_size,scatter_LineWidth,scatter_MarkerFaceAlpha,scatter_MarkerEdgeAlpha,'Ylim',limU,'labelY',name_U,'Z',Z,'labelZ',name_Z);
% 设置图形大小
MonitorPosition = get(0,'MonitorPosition'); 
% 控制出图背景色和大小
set(gcf,'position',[0.3*MonitorPosition(3),0.2*MonitorPosition(4),0.5*MonitorPosition(3),0.7*MonitorPosition(4)]); 

% put axis on bottom and text on top
th1 = findobj(gcf,'Type','text');
th2 = findobj(gcf,'Type','line');
for jj = 1:length(th1)
    uistack(th1(jj),'top');
end
for jj = 1:length(th2)
    uistack(th2(jj),'bottom');
end

% 保存图片
if ~isempty(picture_path)
    print(gcf, '-dmeta', picture_path);
    print(gcf, '-depsc', picture_path);
end
