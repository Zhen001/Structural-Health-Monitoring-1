function [locs,pks]=peakseek(x,y,minpeakdist,minpeakh,display)
% Alternative to the findpeaks function.  This thing runs much much faster.
% It really leaves findpeaks in the dust.  It also can handle ties between
% peaks.  Findpeaks just erases both in a tie.  Shame on findpeaks.

% y is a vector input (generally a timecourse)
% minpeakdist is the minimum desired distance between peaks (optional, defaults to 1)
% minpeakh is the minimum height of a peak (optional)
% display=0时不做图；display=0.5时不做内衬线；display=1时做全图；


if size(x,2)==1, x=x'; end
if size(y,2)==1, y=y'; end
% Find all maxima and ties
locs=find(y(2:end-1)>=y(1:end-2) & y(2:end-1)>=y(3:end)) + 1; % 加1是因为从第二个开始判断
locs(locs(1:end-1)-locs(2:end)==-1)=[]; % 删除临近的相同峰值

if nargin<2, minpeakdist=1; end % If no minpeakdist specified, default to 1.

if nargin>2 % If there's a minpeakheight
    locs(y(locs)<=minpeakh)=[];
end

if minpeakdist>1
    while 1
        del=diff(locs)<=minpeakdist/(x(2)-x(1));
        if ~any(del), break; end
        pks=y(locs);
        [garb,mins]=min([pks(del) ; pks([false del])]); %#ok<ASGLU>
        deln=find(del);
        deln=[deln(mins==1) deln(mins==2)+1];
        locs(deln)=[];
        
%         pks=y(locs); 改成个数
%         [pks,locs2]=sort(pks,'descend');
%         locs=locs(locs2);
%         pks=pks(1:number);
%         locs=locs(1:number);
    end
end

if nargout>1
    pks=y(locs);
end

if display==1
    hold on;grid on; % 继续在函数外的上一幅图里画
%     plot(x,y,'LineWidth',0.01); hold on;    
    plot(x(locs),y(locs),'.','Markersize',15,'MarkerEdgeColor','r');hold on;
    y1([1:length(y)],1)=0; y1(locs) = y(locs);
    plot(x,y1,'r','LineWidth',0.01); hold off
elseif display==0.5
    hold on;grid on; % 继续在函数外的上一幅图里画
%     plot(x,y,'LineWidth',0.01); hold on; 
    plot(x(locs),y(locs),'.','Markersize',15,'MarkerEdgeColor','r'); hold off
end

pks=pks';
locs=x(1)+(locs-1)*(x(2)-x(1));
locs=locs';

end