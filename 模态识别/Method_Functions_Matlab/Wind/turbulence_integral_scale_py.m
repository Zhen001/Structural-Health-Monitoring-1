% Calculate the streamwise integral length scale
function LX = turbulence_integral_scale_py(x,Fs,U,method)
% x: fluctuating component [ 1 x N ]
% Fs: ²ÉÑùÆµÂÊ
% U : mean wind speed
% method: 'expoDecay' or 'DirectInt'
% LX = [1 x 1] scalar : turbulence length scale
% Author: Etienne Cheynet  13.12.2015

%%
% check input
if or(nargin<4,isempty(method))
    warning('method is unknown. It is set to "DirectInt" by default');
    method = 'DirectInt';
end
% AUTOCOVARIANCE
N = numel(x); % number of time steps
[autocov, lags] = xcov(detrend(x),detrend(x),N,'coef'); % is 2-sided
% we only keep the positive part (get 1-sided autocov)
autocov = autocov(round(length(autocov)/2):end);
tLag =lags(round(length(lags)/2):end)/Fs;

% get the indice of the first zero-crossing
ind = zerocross(autocov);
if numel(ind)>=1
    % get the first zero-crossing
    ind = ind(1);
    % non linear exponential fit
    if strcmp(method,'expoDecay')
        expoFit =  @(coeff,x) exp(-coeff.*x);
        guess = 0.01; % first guess
        % fitting process
        try
            coefEsts = nlinfit(tLag(1:ind),autocov(1:ind), expoFit, guess);
            % if statistic toolbox is not available, try with optimization toolbox
        catch exception
            option= optimset('Display','off');
            coefEsts = lsqcurvefit(@(L,t)expoFit(L,t),guess,tLag(1:ind),autocov(1:ind),0,500,option);
        end
        % get integral time scale
        T = trapz(tLag(1:ind),expoFit(coefEsts,tLag(1:ind)));
        % Taylor hypothesis of frozen turbulence is applied
        % get the integral length scale
        LX = T*U;
    elseif strcmp(method,'DirectInt') % best choice is not statistic toolbox or optimization toolbox available
        % get integral time scale
        T = trapz(tLag(1:ind),autocov(1:ind));
        % Taylor hypothesis of frozen turbulence is applied
        % get the integral length scale
        LX = T*U;
    else
        error(['method: "',method,...
            '" is unknown. Please, choose between:',...
            ' "expoDecay" or "DirectInt"'])
    end
    
else % no zero-crossing found
    warning('No zero crossing found')
    LX=NaN;
end
    function z=zerocross(v)
        z=find(diff(v>0)~=0)+1;
    end
end

