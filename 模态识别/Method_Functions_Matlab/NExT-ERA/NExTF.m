% Natural Excitation Technique function
% This function uses the frequency-domain method to find the correlation and it takes only left side.
%function IRF= NExTF(data,refch,window,N,p)

%Inputs :

%data: An array that contains response data.its dimensions are (nch,Ndata) where nch is the number of channels. Ndata is the total length of the data 
%refch: A vecor of reference channels .its dimensions (numref,1) where numref is number of reference channels
%window: window size to get spectral density
%N: Number of windows
%p: overlap ratio between windows. from 0 to 1

%Outputs :

%IRF: Impulse Response Function matrix of size (nch,numref*(ceil(window/2+1)-1))

function IRF= NExTF(data,refch,window,N,p)

nch=size(data,1);
numref=length(refch);

for refl=1:1:numref            %Loop for reference channels
for chan=1:1:nch               %Loop for all channels

Sensor1=refch(refl);            %No. First sensor to get data from
Sensor2=chan;                  %No. Second sensor to get data from

%--------------------------------------------------------------------------
%Generation of vectors before applying cross-correlation to them

x = data(Sensor1,:);           %Extract data from sensor 1 
y = data(Sensor2,:);           %Extract data from sensor 2

%--------------------------------------------------------------------------
%Generation of cross-correlation vector


%----------
l=length(x);

for i=1:1:N
    
   wn=ceil((1-p)*window);
   xx=x([1+wn*(i-1):window+wn*(i-1)]);
   yy=y([1+wn*(i-1):window+wn*(i-1)]);
   
   M1=fft(xx); MX1(i,:)=M1;
   M2=fft(yy); MX2(i,:)=M2;
   
end

MX=zeros(1,length(MX1(1,:)));

for i=1:1:N
MX=MX+MX1(i,:).*conj(MX2(i,:));
end

MX=MX/N;

%----------

XCF=ifft(MX);  %Cross-correlation Vector 
XCR=XCF(1:ceil(window/2+1)-1);
maxlags=length(XCR)-1;
%--------------------------------------------------------------------------
% Generation of cross correlation matrix between reference channels and all
%            channels.its dimensions (nch,numref*(1+maxlags))
           
Y(chan,[refl:numref:refl+numref*(maxlags)])=XCR; %Array for cross-correlation
%--------------------------------------------------------------------------
end
end

IRF=Y;
end


