function [t,IRF] = RDT_function_py(y,ys,Fs,long_out)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% [IRF] = RDT(y,ys,T,dt) returns the impulse response function (IRF) by
% using the random decrement technique (RDT) to the time serie y, with a
% triggering value ys, and for a duration T
%
% INPUT:
% y: time series of ambient vibrations: vector of size [1xN]
% ys: triggering values (ys < max(abs(y)) and here ys~=0)
% Fs : sample frequency
% OUTPUT:
% IRF: impusle response function
% t: time vector asociated to IRF

%%
format longG;
y = y(:)';

if long_out >= numel(y)-1
    error('Error: subsegment length is too large');
end

if ys==0
    error('Error: ys must be different from zero')
elseif or(ys >=max(y),ys <=min(y))
    error('Error:  ys must verifiy : min(y) < ys < max(y)')
else
    % find triggering value
    ind=find(diff(y(1:end-long_out)>ys)~=0)+1;
    
end

% construction of decay vibration
IRF = zeros(numel(ind),long_out);
for ii=1:numel(ind)
    IRF(ii,:)=y(ind(ii):ind(ii)+long_out-1);
end

% averaging to remove the random part
IRF = mean(IRF);
% normalize the IRF
IRF = IRF./IRF(1);
% time vector corresponding to the IRF
t = 0:1/Fs:(long_out-1)/Fs;

end

