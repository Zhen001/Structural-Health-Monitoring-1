% STD��ģ̬����ʶ��
function result = STD_function_py(x,Fs,mn)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

draw = 0;

% % ģ���ź�
% clear all
% Fs=100; % ģ������
% mn=5;
% draw=1;
% t=[1:5000]/100;
% x=5*sin(30*2*pi*t)+10*sin(40*2*pi*t)+150*randn(1,5000);

% ����˵��
% x��ʱ������������Ӧ�������񶯡�����غ��������������������
% Fs������Ƶ��
% mn��ģ̬����
% filename: ��������ļ���

%����Ԥ����
x=x(:)';
lvbo=1;                               % �Ƿ��˲������ֶ�������
if lvbo
    fs2=Fs/2;                         % �ο�˹��Ƶ��
    Wp=[10,12];                            % ͨ��Ƶ�ʣ����ֶ�������
    Ws=[8,14];                            % ���Ƶ�ʣ����ֶ�������
    Wp=Wp/fs2;                        % ��һ��ͨ��Ƶ��
    Ws=Ws/fs2;                        % ��һ�����Ƶ��
    Rp=1; Rs=50;                      % ͨ�����ƺ����˥�������ֶ�������
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs); % ���˲���ԭ�ͽ����ʹ���
    [bn1,an1]=butter(jieshu,Wn);      % �������˲���ϵ��
    x=filter(bn1,an1,x);              % �����ݽ����˲���Ĭ��ÿ�е����˲�
end

% lvbo=1;                               % �Ƿ��˲������ֶ�������
% if lvbo
%     fs2=Fs/2;                         % �ο�˹��Ƶ��
%     [bn1,an1]=butter(2,[10 12]/fs2);      % �������˲���ϵ��
%     x=filter(bn1,an1,x);              % �����ݽ����˲���Ĭ��ÿ�е����˲�
% end

%�����������̾���Ľ�����Ϊģ̬������2����
nm=2*mn;
n=fix(length(x)/2);
h=x(1,1:2*n)';
%����ʱ���� 
dt=1/Fs;
%������ɢʱ������
t=0:dt:(2*n-1)*dt;
%������������Ӧ����
M=length(h)-nm;
x1 = zeros(M,nm);
x2 = zeros(M,nm);
for k = 1:M
  x1(k,:) = h(k:k+nm-1)'; 
  x2(k,:) = h(k+1:k+nm)';
end
%����Hessenberg����
B=zeros(nm,nm);
B(2:nm,1:nm-1)=eye(nm-1,nm-1);
%����С���˷�������ϵ��������
B(:,nm)=x1\x2(:,nm); %B(:,nm)=inv(x1'*x1)*x1'*x2(:,nm);
%��������ֵ����������
[~,V] = eig(B);
%�任����ֵ�Խ���Ϊһ����   
for k = 1:nm  
  U(k)=V(k,k);  
end
%����ģ̬Ƶ��
F1 = abs(log(U'))./(2*pi*dt);
%���������
D1 = sqrt(1./(((imag(log(U'))./real(log(U'))).^2)+1));
%��������ϵ������������������
l=1;
for k = 1:nm
  if abs(real(U(k)))<= 1 && abs(imag(U(k)))<= 1 
    V0(l) = U(k); 
    l = l + 1;
  end
end
Va = zeros(2*n,size(V0,2));
for k = 0:(2*n-1)
  Va(k+1,:) = conj(V0).^k ;  
end
S1 = (conj(Va')*Va\conj(Va')*h);
%�������ɵ�������Ӧ����
h1=real(Va*S1);
%����������Ӧ�����������ͼ
if draw
    figure(1)
    plot(t,h,':',t,h1); 
    xlabel('ʱ�� (s)');  
    ylabel('��ֵ'); 
    legend('ʵ��','���');
    grid on;                        
end
%��ģ̬Ƶ��С��������
[F2,I]=sort(F1); 
%�޳����̽��еķ�ģ̬��(�ǹ����)�͹�����(�ظ�)
m=0;S1
for k=1:nm-1
  if F2(k)~=F2(k+1)
    continue; 
  end
  m=m+1;
  l=I(k);
  F(m)=F1(l); %ģ̬Ƶ��
  D(m)=D1(l); %�����  
  S(m)=S1(l); %����ϵ��   
end

%% ����ֵ����
result = [F;D*100.0;imag(S)]; % ������Ѿ��˹�100��

