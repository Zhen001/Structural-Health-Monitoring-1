function [zeta] = expoFit(y,t,wn,optionPlot)
    % [zeta] = expoFit(y,t,wn) returns the damping ratio calcualted by fiting
    % an exponential decay to the envelop of the Impulse Response Function.
    %
    % y: envelop of the IRF: vector of size [1 x N]
    % t: time vector [ 1 x N]
    % wn: target eigen frequencies (rad/Hz) :  [1 x 1]
    % zeta: modal damping ratio:  [1 x 1]
    % optionPlot: 1 to plot the fitted function, and 0 not to plot it.
    %%
    % Initialisation
    guess = [1,1e-2];
    % simple exponentiald ecay function
    myFun = @(a,x) a(1).*exp(-a(2).*x);
    % application of nlinfit function
    coeff = nlinfit(t,y,myFun,guess);
    % modal damping ratio:
    zeta = abs(coeff(2)./wn);

    % alternatively: plot the fitted function
%     if optionPlot== 1
        plot(t,myFun(coeff,t),'r')
%     end
end

