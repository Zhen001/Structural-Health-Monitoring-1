% STD法模态参数识别
function [] = STD_function(x,Fs,mn,filename)

%% 参数说明
% x：时域数据如冲击响应、自由振动、互相关函数、随机减量法处理结果
% Fs：采样频率
% mn :模态阶数
% filename: 输出数据文件名

%数据预处理
x=x(:)';

%建立特征方程矩阵的阶数（为模态阶数的2倍）
nm=2*mn;
n=fix(length(x)/2);
h=x(1,1:2*n)';
%计算时间间隔 
dt=1/Fs;
%建立离散时间向量
t=0:dt:(2*n-1)*dt;

%计算自由振动响应矩阵
M=length(h)-nm;
for k = 1:M
  x1(k,:) = h(k:k+nm-1)'; 
  x2(k,:) = h(k+1:k+nm)';
end

%计算Hessenberg矩阵
B=zeros(nm,nm);
B(2:nm,1:nm-1)=eye(nm-1,nm-1);
%用最小二乘法求解待定系数列向量
B(:,nm)=x1\x2(:,nm); %B(:,nm)=inv(x1'*x1)*x1'*x2(:,nm);
%计算特征值及特征向量
[~,V] = eig(B);
%变换特征值对角阵为一向量   
for k = 1:nm  
  U(k)=V(k,k);  
end
%计算模态频率
F1 = abs(log(U'))./(2*pi*dt);
%计算阻尼比
D1 = sqrt(1./(((imag(log(U'))./real(log(U'))).^2)+1));
%计算振型系数向量（特征向量）
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

%计算生成的脉冲响应函数
h1=real(Va*S1);
%绘制脉冲响应函数拟合曲线图
figure(1)
plot(t,h,':',t,h1); 
xlabel('时间 (s)');  
ylabel('幅值'); 
legend('实测','拟合');
grid on;                        

%将模态频从小到大排序
[F2,I]=sort(F1); 
%剔除方程解中的非模态项(非共轭根)和共轭项(重复)
m=0;
for k=1:nm-1
  if F2(k)~=F2(k+1)
    continue; 
  end
  m=m+1;
  l=I(k);
  F(m)=F1(l); %模态频率
  D(m)=D1(l); %阻尼比  
  S(m)=S1(l); %振型系数   
end

%打开文件输出识别的模态参数数据
fid=fopen(filename,'w'); 
fprintf(fid,'频率(Hz)     阻尼比(%%)     振型系数\n');
for k=1:m
  fprintf(fid,'%10.4f	%10.4f	%10.6f\n',F(k),D(k)*100.0,imag(S(k)));
end
fclose(fid);
type(filename)

