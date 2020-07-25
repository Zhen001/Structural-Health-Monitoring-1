% STD��ģ̬����ʶ��
function [] = STD_function(x,Fs,mn,filename)

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
M=length(h)-nm;
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
for k = 0:(2*n - 1)  
  Va(k+1,:) = [conj(V0).^k ];  
end
S1 = (conj(Va')*Va\conj(Va')*h);

%�������ɵ�������Ӧ����
h1=real(Va*S1);
%����������Ӧ�����������ͼ
figure(1)
plot(t,h,':',t,h1); 
xlabel('ʱ�� (s)');  
ylabel('��ֵ'); 
legend('ʵ��','���');
grid on;                        

%��ģ̬Ƶ��С��������
[F2,I]=sort(F1); 
%�޳����̽��еķ�ģ̬��(�ǹ����)�͹�����(�ظ�)
m=0;
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

%���ļ����ʶ���ģ̬��������
fid=fopen(filename,'w'); 
fprintf(fid,'Ƶ��(Hz)     �����(%%)     ����ϵ��\n');
for k=1:m
  fprintf(fid,'%10.4f	%10.4f	%10.6f\n',F(k),D(k)*100.0,imag(S(k)));
end
fclose(fid);
type(filename)

