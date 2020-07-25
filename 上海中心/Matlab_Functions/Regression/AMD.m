function [IMF]=AMD(x,Fs,w,nbsym)
% AMD 解析模态分析法
% input:
% x: 时间序列，1*N
% Fs: 采样频率, >2Hz
% w：需要分段的频率(圆频率) ,1*N
% nbsym: 延拓数
% output:
% IMF: 提取出的子部分
t=0:1/Fs:length(x)/Fs-1/Fs;
for i=1:length(w)
    % 镜像延拓
    [tt,xx] = mirror_extend(t,x.*cos(w(i)*t),nbsym);
    [tt,ind]=unique(tt);
    loc1=find(tt==t(1));
    loc2=loc1+length(t)-1;
    xx=xx(ind);
    Hc=hilbert(xx);
    Hc=Hc(loc1:loc2);
%     figure
%     hold on 
%     plot(t,x.*cos(w(i)*t),'k',tt(loc1:loc2),abs(Hc),'ro')
      %     plot(tt,xx,'k*',tt,abs(hilbert(xx)),'kv')
    [tt,xx] = mirror_extend(t,x.*sin(w(i)*t),nbsym);
    [tt,ind]=unique(tt);
    loc1=find(tt==t(1));
    loc2=loc1+length(t)-1;
    xx=xx(ind);
    Hs=hilbert(xx);
    Hs=Hs(loc1:loc2); 
%       figure
%       hold on
%       plot(t,x.*sin(w(i)*t),'k',tt(loc1:loc2),abs(Hs),'ro')
%       plot(tt,xx,'k*',tt,abs(hilbert(xx)),'kv')
    S(i,:)=sin(w(i)*t).*imag(Hc)-cos(w(i)*t).*imag(Hs);
    S(i,:)=lowp(S(i,:),Fs/2-2,Fs/2-1,0.1,30,Fs);  %   由于一般很低频，土木所涉及的频率远远低于采样的一半
end
IMF(1,:)=S(1,:);
for i=2:size(S,1)
    IMF(i,:)=S(i,:)-S(i-1,:);
end
end
