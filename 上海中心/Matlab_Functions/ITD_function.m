% IDT��ģ̬����ʶ��
function [] = ITD_function(x,Fs,mn,filename)

%% ����˵��
% x��ʱ������������Ӧ�������񶯡�����غ��������������������
% Fs������Ƶ��
% mn :ģ̬����
% filename: ��������ļ���

%����Ԥ����
x=x(:)';

%�����������̾���Ľ�����Ϊģ̬������2����
nm=2*mn;
n=fix(length(x)/2);
h=x(1,1:2*n)';
%����ʱ���� 
dt=1/Fs;
%������ɢʱ������
t=0:dt:(2*n-1)*dt;

%������������Ӧ����
L = length(h); 
M = L/2; 
for k = 1:nm
  x1(k,:) = h(k:L-(nm-k+1))'; 
  x2(k,:) = h(k+1:L-(nm-k))';
end

%����С���˷�����������̾���
B=x1\x2; %B=x2*x1'*inv(x1*x1');

%��������ֵ����������
[~,V]=eig(B);
%�任����ֵ�Խ���Ϊһ����   
for k = 1:nm  
  U(k)=V(k,k);  
end
%����ģ̬Ƶ������
F1 = abs(log(U'))./(2*pi*dt);
%�������������
D1 = sqrt(1./(((imag(log(U'))./real(log(U'))).^2)+1));
%��������ϵ������
l=1;
for k = 0:(2*n-1)  
  Va(k+1,:) = [conj(U).^k ];  
end
S1 = (inv(conj(Va')*Va)*conj(Va')*h);

%�������ɵ�������Ӧ����
h1=real(Va*S1);
%����������Ӧ�����������ͼ
figure
plot(t,h,':',t,h1); 
xlabel('ʱ�� (s)');  
ylabel('��ֵ'); 
legend('ʵ��','���');
grid on;     

%������Ƶ�ʴ�С��������
[F2,I]=sort(F1); 
%�޳����̽��еķ�ģ̬��(�ǹ����)�͹�����
m=0;
for k=1:nm-1
  if F2(k)~=F2(k+1)
    continue; 
  end
  m=m+1;
  l=I(k);
  F(m)=F1(l); %����Ƶ��
  D(m)=D1(l); %�����  
  S(m)=S1(l); %����ϵ��   
end

%���ļ����ʶ���ģ̬��������
fid=fopen(filename,'w'); 
fprintf(fid,'Ƶ��(Hz)     �����(%%)     ����ϵ��\n');
for k=1:m
  fprintf(fid,'%10.4f	%10.4f	%10.6f\n',F(k),D(k)*100.0,imag(S(k)));
end
fclose(fid);
type(filename)
toc
