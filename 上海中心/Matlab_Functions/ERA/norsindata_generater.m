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
y1=rand(1,size(t,2))+sin(t);
y2=sin(t);

%y=sin(t);            
figure(1111)
plot(t,y1,'b',t,y2,'r');
xlabel('time');
ylabel('sin');
title('Target Function');
grid
for loop=1:size(y1,2)
fprintf(fid1,'%g',y1(loop));
fprintf(fid1,'   ');
fprintf(fid1,'%g\n',y2(loop));
end
figure(1112)
hold
PSD(y1,1024,1024,HAMMING(1024),0,.95);
PSD(y2,1024,1024,HAMMING(1024),0,.95);
status=fclose('all');