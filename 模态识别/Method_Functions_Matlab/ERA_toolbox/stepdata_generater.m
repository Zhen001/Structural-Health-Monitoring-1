%this is a ERA algorithm Demo target function generater for Modal analysis
%By Chen yi, Jan. 24th,2004
%  State Key lab of Mechanical Transmission , Chonqqing University
%    chen_yi2000@sina.com
clear
home
close('all');
fid1=fopen('YData.txt','w+');
fid2=fopen('sampling_frequencyHz.txt','r');
fid3=fopen('sampling_time.txt','r');
sampling_frequencyHz=fscanf(fid2,'%g');
sampling_time=fscanf(fid3,'%g');
sampling_step=1/sampling_frequencyHz;
t=0:sampling_step:sampling_time;
y=zeros(1,size(t,2));
for loop_t=1:size(t,2)
if t(loop_t)<=1
     y(loop_t)=0;  
else
   y(loop_t)=1;
end
end 
%y=sin(t);            
figure(1111)
plot(t,y,'b');
xlabel('time');
ylabel('sin');
title('Target Function');
grid
fprintf(fid1,'%g\n',y);
figure(1112)
PSD(y,1024,1024,HAMMING(1024),0,.95);
status=fclose('all');