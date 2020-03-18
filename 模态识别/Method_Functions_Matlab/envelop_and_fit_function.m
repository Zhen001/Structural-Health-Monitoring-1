function [zeta] = envelop_and_fit_function(IRF,Fs,f,optionPlot)
    % IRF: the result of RDT
    % Fs: sample frequency
    % f : eigen frequency
    IRF = IRF(:)'; % 转成行向量
    % get the envelop of the curve with the hilbert transform:
    envelop = abs(hilbert(IRF));
    t=0-25/Fs:1/Fs:length(IRF)/Fs-26/Fs;  % zht修改 为了舍去前后各25个拟合的不好的envelop
    if optionPlot
        figure('visible','on')
    else
        figure('visible','off');
    end
    hold on; box on;
    plot(t,IRF,'b',t,envelop,'k');
    xlabel('time (s)')
    ylabel('normalized displacement')
    set(gcf,'color','w')
    % fit an exponential decay to the envelop
    wn = 2*pi*f; % -> f is obtained with peak picking method (fast way)
    envelop = envelop(26:end-25);
    t = t(26:end-25);
    [zeta] = expoFit(envelop,t,wn);
    xlim([0,length(IRF)/Fs-50/Fs])       % zht修改 为了舍去前后各25个拟合的不好的envelop
    legend('IRF','envelop',' best fit')
    % fprintf([' the calculated modal damping ratio is ',num2str(zeta,2),' \n'])
    
    function [zeta] = expoFit(y,t,wn)
        % [zeta] = expoFit(y,t,wn) returns the damping ratio calcualted by fiting
        % an exponential decay to the envelop of the Impulse Response Function.
        % y: envelop of the IRF: vector of size [1 x N]
        % t: time vector [ 1 x N]
        % wn: target eigen frequencies (rad/Hz) :  [1 x 1]
        % zeta: modal damping ratio:  [1 x 1]
        % optionPlot: 1 to plot the fitted function, and 0 not to plot it.
        % Initialisation
        guess = [1,1e-2];
        % simple exponentiald ecay function
        myFun = @(a,x) a(1).*exp(-a(2).*x);
        % application of nlinfit function
        coeff = nlinfit(t,y,myFun,guess);
        % modal damping ratio:
        zeta = abs(coeff(2)./wn);
        % alternatively: plot the fitted function
        plot(t,myFun(coeff,t),'r')
    end
end