% 自然激励法 模态参数识别预处理
function [IRF,t] = NExT_function2(x,fs,Ts,method)
    %
    % [IRF] = NExT(y,ys,T,fs) implements the Natural Excitation Technique to
    % retrieve the Impulse Response Function (IRF) from the cross-correlation
    % of the measured output y.
    %
    % [IRF] = NExT(y,fs,Ts,1) calculate the IRF with cross-correlation
    % calculated by using the inverse fast fourier transform of the
    % cross-spectral power densities  (method = 1).
    %
    % [IRF] = NExT(y,fs,Ts,2) calculate the IRF with cross-correlation
    % calculated by using the unbiased cross-covariance function (method = 2)
    %
    %
    % y: time series of ambient vibrations: vector of size [1xN]
    % fs : frequency
    % method: 1 or 2 for the computation of cross-correlation functions
    % T: Duration of subsegments (T<fs*(numel(y)-1))
    % IRF: impusle response function
    % t: time vector asociated to IRF
    %%
    if nargin<4, method = 2; end % the fastest method is the default method
    if ~ismatrix(x), error('Error: x must be a vector or a matrix'),end
    [Nxx,N1]=size(x);
    if Nxx>N1
        x=x';
        [Nxx,~]=size(x);
    end

    % get the maximal segment length fixed by T
    M = round(Ts*fs);
    switch method
        case 1
            clear IRF
            IRF = zeros(Nxx,Nxx,M);
            for oo=1:Nxx
                for jj=1:Nxx
                    y1 = fft(x(oo,:));
                    y2 = fft(x(jj,:));
                    h0 = ifft(y1.*conj(y2));
                    IRF(oo,jj,:) = h0(1:M);
                end
            end
            % get time vector t associated to the IRF
            t = linspace(0,(size(IRF,3)-1)./fs,size(IRF,3));
            if Nxx==1
                IRF = squeeze(IRF)'; % if Nxx=1
            end
        case 2
            IRF = zeros(Nxx,Nxx,M+1);
            for oo=1:Nxx
                for jj=1:Nxx
                    [dummy,lag]=xcov(x(oo,:),x(jj,:),M,'unbiased');
                    IRF(oo,jj,:) = dummy(end-round(numel(dummy)/2)+1:end);
                end
            end
            if Nxx==1
                IRF = squeeze(IRF)'; % if Nxx=1
            end
            % get time vector t associated to the IRF
            t = lag(end-round(numel(lag)/2)+1:end)./fs;
    end
    % normalize the IRF
    if Nxx==1
        IRF = IRF./IRF(1);
    end
