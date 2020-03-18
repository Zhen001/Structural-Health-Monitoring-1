% Fs=250; 
% filename1=fopen('G:\�ĵ�\��һ��\����ʦ������\˶ʿѧλ����\����\��2��\300N-1e-6s-250Hz.txt','r');
% response=textscan(filename1,'%f %f %f %f','Headerlines',7);
% response=cell2mat(response);  
% [FFFF,DAMP2,VVV,f,ANPSD,locs,pks] = SSI_PP_py(response,Fs);


function [FFFF,DAMP2,VVV,f,ANPSD,locs,pks] = SSI_PP_py(response,Fs,varargin)
close all

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

%% 1.�����ֵ
% response�������Ƕ���ʱ���źţ�ÿ�д���һ����㣩
% Fs������Ƶ��

p = inputParser();                      
p.CaseSensitive = false;                % �����Ĳ�����Сд
p.addOptional('filtering', [0,0]);      % filtering: �˲���ͨ����Χ
p.addOptional('new_f', 0);              % new_f��������Ƶ�ʣ������˲�ʱ�����������Ҳ������������
p.addOptional('PP', 1);                 % �Ƿ�ͬʱ��PPͼ
p.addOptional('PSDfangfa', 1);          % PSDfangfa��ѡ��Ҫʹ�õķ�����1Ϊ����ͼ����2Ϊ�������ͼƽ���������ֶ�������
p.addOptional('m', 4);                  % m��ƽ������ͼ����ƽ����
p.addOptional('if_log', 0);             % if_log���Ƿ�Խ��ȡ����
p.addOptional('draw', 1);               % draw���Ƿ���ͼ
p.addOptional('percent', 10);           % percent����ֵ����ȡ��ߵ�İٷ�֮��
p.addOptional('minpeakdist', 0.01);     % minpeakdist����ֵ֮����С����
p.addOptional('Xrange', [0,120]);     	% Xrange����ͼ��Χ
p.addOptional('mode_number', 4);        % interval��Ҫ��ȡ�Ľ���

p.parse(varargin{:});
filtering = p.Results.filtering;
new_f = p.Results.new_f; 
PP = p.Results.PP; 
PSDfangfa = p.Results.PSDfangfa;
m = p.Results.m;
if_log = p.Results.if_log;
draw = p.Results.draw;
percent = p.Results.percent;
minpeakdist = p.Results.minpeakdist; 
Xrange = p.Results.Xrange;
mode_number = p.Results.mode_number;

class(response)
size(response)
%% 2.����Ԥ����
if size(response,2)>size(response,1)
    response=response';                     % ת��һ�����һ��
end 
response(:,1)=[];                           % �����ã������һ��Ϊʱ�����У���ִ�д��д���
num=size(response,2);                       % �����

% �������������
if new_f
    response=resample(response,...
        new_f*1000,Fs*1000);                % ������,Ĭ��ÿ�е���������
    N=size(response,1);                  	% ��������ĳ���
    Fs=new_f;                             	% ��Ƶ���滻�ɽ�����Ƶ��
else
    N=size(response,1);                 	% ԭʼ���ݳ�
end

% �˲�  
if sum(filtering ~= [0,0])
    fs2=Fs/2;                               % �ο�˹��Ƶ��
%     Wp=[55 100];                            % ͨ��Ƶ�ʣ����ֶ�������
%     Ws=[45 105];                            % ���Ƶ�ʣ����ֶ�������
    Wp=filtering(1);                        % ͨ��Ƶ�ʣ����ֶ�������
    Ws=filtering(2);                        % ���Ƶ�ʣ����ֶ�������
    Wp=Wp/fs2;                              % ��һ��ͨ��Ƶ��
    Ws=Ws/fs2;                              % ��һ�����Ƶ��
    Rp=3;                                   % ͨ������
    Rs=30;                                  % ���˥��
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs);       % ���˲���ԭ�ͽ����ʹ���
    [bn1,an1]=butter(jieshu,Wn);            % �������˲���ϵ��
    response=filter(bn1,an1,response);      % �����ݽ����˲���Ĭ��ÿ�е����˲�
end

% % ������Ƶ50HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=50/fs2;                                % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�
% % ����0HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=0.01/fs2;                              % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�
% % ������Ƶ150HZ
% fs2=Fs/2;                                 % �����ο�˹��Ƶ��
% W0=150/fs2;                               % �ݲ�������Ƶ��
% BW=0.005;                                 % �ݲ������� 
% [b,a]=iirnotch(W0,BW);                    % ���IIR�����ݲ���
% response=filter(b,a,response);            % ���ź��˲�

%% 4.SSI����ӿռ�&��ͼ
i=100;                                          % iΪ��������Խ�����Խϸ
J=[1 50];                                       % NΪ����������Χ
dn=1;                                           % dnΪ�����ȶ�ͼ�ĸ�������ԽС���Խϸ
s=1;                                            % sΪ���ݷֶ�����ԽС���Խϸ
[FFF,DAMP1,VV]=SSI(response,Fs,i,J,dn,s,draw); 	% FFFΪƵ�ʾ���DAMP1Ϊ�������VVΪ���;���
if draw
    figure(2); hold on;
    title('����','FontName','���ķ���','FontWeight','bold','FontSize',20,'LineWidth',2)
    xlabel('����','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2)
    ylabel('ģ�ͽ���','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2)
    
    figure(1); hold on; grid on; box on; 
    title('SSI����ӿռ�+PP��ֵ��','FontName','���ķ���','FontWeight','bold','FontSize',20,'LineWidth',2)
    xlabel('Ƶ��/Hz','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2)
    ylabel('ģ�ͽ���','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2)
end

%% 5.��Ƶ�ʺ����͵���EXCEL
filename2='E:\�����ġ�\��С���ġ�\ģ̬ʶ��\Matlab�ű�\SSI����ӿռ�\����ʹ��\3=1-Ƶ�ʾ���.xlsx';
delete E:\�����ġ�\��С���ġ�\ģ̬ʶ��\Matlab�ű�\SSI����ӿռ�\����ʹ��\3=1-Ƶ�ʾ���.xlsx; % ��ɾ��ԭ���
% Ƶ�ʾ���:
FFFF=FFF(1:2:mode_number*2-1,:);             	% ż���к���������ȫһ��������ֻȡ�����У���ֻȡǰ4��
DAMP2=DAMP1(1:2:mode_number*2-1,:);         	% ż���к���������ȫһ��������ֻȡ�����У���ֻȡǰ4��
xlswrite(filename2,FFFF,1)
% ���;���:
VVV=zeros(num*mode_number,J(2));
for i=1:num
    for j=1:mode_number
        VVV(mode_number*(i-1)+j,:)=abs(VV(2*j-1,:,i)).*((abs(angle(VV(2*j-1,:,i)))<pi/2)*2-1);
    end
end
xlswrite(filename2,VVV,2)

%% ����ΪPP��ֵ����ANPSD��

if PP % �Ƿ�ͬʱ��PPͼ
    %% 2.Ԥ�����ڴ桢ƽ������ͼ���ڳ�������
    if PSDfangfa==2
        N2=floor(N/m);                                                  % ƽ������ͼ���ڳ��ȣ�����2��
        if mod(N2,2)==1,N2=N2+1;end
        PSD=zeros(floor((N2/2)+1),num); f=zeros(floor((N2/2)+1),num);   % Ԥ�����ڴ棨����2��
    elseif PSDfangfa==1
        PSD=zeros(floor((N/2)+1),num); f=zeros(floor((N/2)+1),num);     % Ԥ�����ڴ棨����1�� 
    end

    %% 3.�����ø�������ݼ���PSD
    for i=1:num
        x=response(:,i);
        if PSDfangfa==1                         % 1.����ͼ����Periodogram��
            window=hamming(N);                  % ѡ��һ�ִ�����
            [PSD(:,i),f(:,i)]=periodogram(x,window,length(x),Fs);
        elseif PSDfangfa==2                     % 2.�������ͼƽ������Welch��
            window=hamming(N2);                 % ѡ��һ�ִ�����
            noverlap=N2/2;                      % �ֶ������ص��Ĳ������������ȣ�
            range='onesided';                   % ������
            [PSD(:,i),f(:,i)]=pwelch(x,window,noverlap,N2,Fs,range);  
        end
    end

    %% 4.����ƽ�����򻯹������ܶ�ANPSD
    ANPSDs=0;
    for i=1:num
        ANPSDs=ANPSDs+PSD(:,i)/sum(PSD(:,i));   % ����
    %     ANPSDs=ANPSDs+PSD(:,i);               % ������
    end

    %% 5.�Ƿ�ȡ����������ƽ��
    if if_log
        ANPSD=log10(ANPSDs/num);                % ������ʽ
    else
        ANPSD=ANPSDs/num;                       % �Ƕ���
    end

    %% 6.��ͼ
    fangda=0.7*50/max(ANPSD);                   % ��������ϵ��ͬ���ʽ���ֵ�Ŵ�
    ANPSD1=fangda*ANPSD;
    if draw
        % ����ANPSD
        figure(1)                               % �ڵ�һ��ͼ��Ƶ��ͼ���ϼ�������ֵ����ͼ
        hold on;grid on; box on;
        set(gcf,'color','w','unit','centimeters','position',[0 0.6 37 21.5]); % ���Ƴ�ͼ����ɫ�ʹ�С
        plot(f,ANPSD1,'k');                     % k��black
        xlim(Xrange);
        title('SSI����ӿռ�+PP��ֵ��','FontName','���ķ���','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[Fs/4 51])
        xlabel('Ƶ��/Hz','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[Fs/4 -2])
        ylabel('ģ�ͽ���','FontName','���ķ���','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[-6*(Fs/400) 25])
    end

    % �ҷ�ֵ
    if draw; display=0.5; else; display=0; end                              % �������ֵͼ��0ʱ����ͼ��0.5ʱ�����ڳ��ߣ�1ʱ��ȫͼ
    minpeakh=(max(ANPSD1)-min(ANPSD1))/100*percent+min(ANPSD1);             % ��ֵ����
    [locs,pks]=peakseek(f,ANPSD1,minpeakdist,minpeakh,display);             % �ҷ�ֵ
    fprintf('��ֵ���ӦƵ��Ϊ��\n'); disp(locs)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Ϊ�Ӻ�������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%   SSI ����ӿռ䷨����ģ̬����
function [FFF,DAMP1,VV]=SSI(acc,fs,i,N,dn,s,draw)

%   [FFF,DAMP1,VV]=SSI(acc,Fs,i,N,dn,s)
%   �����������acc,Fs,i,N,dn,s:
%   accΪ���������
%   fsΪ����Ƶ�ʣ�
%   iΪ��������
%   NΪ���������
%   dnΪ�����ȶ�ͼ�ĸ�������
%   sΪ���ݷֶ�����
%   �����������FFF,DAMP1,VV:
%   FFFΪƵ�ʾ���
%   DAMP1Ϊ�������
%   VVΪ���;���

if nargin<5;s=1;dn=2; end
if nargin<6;s=1; end
N1=N(1);N2=N(2);

[xs,l]=head(s,acc);

F=zeros(N2,N2/dn);Damp=zeros(N2,N2/dn);V=zeros(N2,N2,l);

for si=1:s
    k=0;x=xs(:,:,si);
    [T1,T2]=TH(x,i);
    [U0,S0,V0]=svd(T1);
    for n=N1:dn:N2
        k=k+1;
        [U1,S1,V1]=sj(n,U0,S0,V0);
        [A,C]=tzz(S1,U1,V1,T2,l);
        [f,v,damp]=mt(A,C,fs);
        for Fi=1:length(f)       % ����Ƶ����ɾ��󣨶�ά��
            F(Fi,k,si)=f(Fi);
        end
        for Di=1:length(damp)    % ����������ɾ��󣨶�ά��
            Damp(Di,k,si)=damp(Di);
        end
        [~,nv]=size(v);          % ����������ɾ�����ά��
        for Vi=1:nv
            V(Vi,k,:,si)=v(:,Vi);
        end
    end
end
[FFF,~,DAMP1,~,VV]=pl(F,Damp,V,l,N1,N2,dn,s,draw); % ��ȡ��������Ƶ�ʡ����ᡢ����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FFF,FF,DAMP1,DAMP,VV]=pl(F,Damp,V,l,N1,N,dn,s,draw)

% ɸѡ������׼��
FF=zeros(N,N/dn);DAMP=zeros(N,N/dn);VV=zeros(N,N/dn,l);
for si=1:s
    for n=1:N/dn-1
        m=0; 
        for m1=1:N
            for m2=1:N
                MAC=abs(F(m1,n,si)-F(m2,n+1,si))/F(m1,n,si);                %��һ��ɸ��(Ƶ��)
                if MAC<0.01                                                 %Ƶ���޶�ֵ1%��������Ҫ�ֶ�������
                    MACD=abs(Damp(m1,n,si)-Damp(m2,n+1,si))/Damp(m1,n,si);  %�ڶ���ɸ��(����)
                    if MACD<0.05                                            %�����޶�ֵ5%��������Ҫ�ֶ�������
                        V1=zeros(l,1);
                        V2=zeros(l,1);
                        for i=1:l
                            V1(i)=V(m1,n,i,si);
                            V2(i)=V(m2,n+1,i,si);
                        end
                        DMACF=abs(V1'*V2)^2/((V1'*V1)*(V2'*V2));            %������ɸ��(����)
                        MACF=1-DMACF;
                        if MACF<0.02                                        %�����޶�ֵ2%��������Ҫ�ֶ�������
                            m=m+1;
                            FF(m,n,si)=F(m1,n,si);                          %ɸ����Ƶ�ʾ���
                            DAMP(m,n,si)=Damp(m1,n,si);                     %ɸ�����������
                            VV(m,n,:,si)=V(m1,n,:,si);                      %ɸ�������;���
                            break
                        end
                    end
                end
            end
        end
    end
end

FFF=zeros(N,N/dn);DAMP1=zeros(N,N/dn);
f=FF;d=DAMP;
if s==1
    FFF=FF;DAMP1=DAMP;
elseif s~=1
    for si=2:s
        for n=1:N/dn-1
            m=0;
            for m1=1:N
                for m2=1:N
                    MAC=abs(f(m1,n,1)-f(m2,n,si));
                    if MAC<10                                               %����ȶ�ͼ�޶�ֵ
                        m=m+1;
                        FFF(m,n)=f(m1,n,1);
                        DAMP1(m,n)=d(m1,n,1);
                        f(m2,n,si)=0;
                        break
                    end
                end
            end
        end
        f(:,:,1)=FFF;
        d(:,:,1)=DAMP1;
    end
end

if draw
    % ���ƶ�ε����ȶ�ͼ��Ƶ���ȶ�ͼ��
    figure                                                                     
    set(gcf,'color','w')
    for n=1:(N-N1)/dn
        for m=1:N
            if FFF(m,n)~=0&&FFF(m,n)<3200/2                                     %Ƶ�ʻ��Ʒ�Χ
                scatter(FFF(m,n),N1+dn*(n-1),'o')
                hold on
            end
        end
    end
    maxf=ceil(max(max(FFF)));
    xlabel('Ƶ��(Hz)'),ylabel('ģ�ͽ���')
    grid on
    set(gca,'Ylim',[0,N]);
    grid on;box on;

    % ���ƶ�ε����ȶ�ͼ�������ȶ�ͼ��
    figure                                                                      
    set(gcf,'color','w')
    k=0;md=zeros(1);
    for n=1:N/dn
        for m=1:N
            if DAMP1(m,n)>0
                k=k+1;
                md(k)=DAMP1(m,n);
            end
        end
    end
    MD=mean(md);
    maxf=2*MD;
    for n=1:N/dn
        for m=1:N
            if DAMP1(m,n)>0&&DAMP1(m,n)<maxf
                scatter(DAMP1(m,n),n,'o');
                hold on
            end
        end
    end
    title('����')
    grid on;box on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xs,l]=head(s,acc)
    [~, l]=size(acc);
    n=fix(length(acc)/s);
    for si=1:s
        xs(:,:,si)=acc(1+(si-1)*n:si*n,:);
    end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,V,damp]=mt(A,C,fs)
[V,D]=eig(A);
u=diag(D);
r=log(u)*fs;
w=abs(r);
damp=(-real(r))./w;
f=w/(2*pi);
V=C*V;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [T1,T2]=TH(x,i)    %�γ�Toeplitz���� T1��T2
[Y1,Y2]=YH_1(x,i);          %����YH�����γ�Hankel����

[m,~]=size(Y1);
yp1=Y1(1:m/2,:);
yf1=Y1(m/2+1:m,:);
T1=yf1*yp1';

[m,~]=size(Y2);
yp2=Y2(1:m/2,:);
yf2=Y2(m/2+1:m,:);
T2=yf2*yp2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Y1,Y2]=YH_1(x,i) %�γ�Hankel���� Y1��Y2
%���ԭYH��������Y1��Y2�����˳�ʼ�ռ���䣬��ѭ���ڲ��������Ż�
temp=x';
[j,l]=size(x);   %jΪ�ɼ����ݳ��ȣ�lΪ�ɼ�ͨ����
Y1=zeros(2*i*l,j-2*i);Y2=zeros(2*i*l,j-2*i);

for yi=1:2*i
    Y1((yi-1)*l+1:yi*l,:)=temp(:,yi:j-2*i+yi-1);
end
Y1=Y1/sqrt(j-2*i);  %Y1�γ�T1

for yi=1:2*i
    if yi<i+1
        Y2((yi-1)*l+1:yi*l,:)=temp(:,yi:j-2*i+yi-1);
    else
        Y2((yi-1)*l+1:yi*l,:)=temp(:,yi+1:j-2*i+yi);
    end
end

Y2=Y2/sqrt(j-2*i);   %Y2�γ�T2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,C]=tzz(S1,U1,V1,T2,l)
A=pinv(U1*S1^(1/2))*T2*pinv(S1^(1/2)*V1');   
O=U1*S1^(1/2);
C=O(1:l,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U1,S1,V1]=sj(n,U,S,V)   %ѡȡ�������õ��������S1��U1��V1
U1=U(:,1:n);
S1=S(1:n,1:n);
V1=V(:,1:n);
