% Natural Excitation Technique function
% This function uses the time-domain method to find the correlation and it takes only the right hand side 

%function IRF= NExTT(data,refch,maxlags)

%Inputs :

%data: An array that contains response data.its dimensions are (nch,Ndata) where nch is the number of channels. Ndata is the total length of the data 
%refch: A vecor of reference channels .its dimensions (numref,1) where numref is number of reference channels
%maxlags: Number of lags in cross-correlation function

%Outputs :

%IRF: Impulse Response Function matrix of size (nch,numref*(maxlags+1))

function IRF= NExTT(data,refch,maxlags)

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

XCR=xcorr(x,y,maxlags,'unbiased'); %Cross-correlation Vector with 2*maxlags+1 elements
XCF=XCR(maxlags+1:2*maxlags+1);    %Cross-correlation Vector with maxlags+1 elements

%--------------------------------------------------------------------------
% Generation of cross correlation matrix between reference channels and all
%            channels.its dimensions (nch,numref*n)
           
Y(chan,[refl:numref:refl+numref*(maxlags)])=XCF; %Array for cross-correlation
%--------------------------------------------------------------------------
end
end

IRF=Y;
end


