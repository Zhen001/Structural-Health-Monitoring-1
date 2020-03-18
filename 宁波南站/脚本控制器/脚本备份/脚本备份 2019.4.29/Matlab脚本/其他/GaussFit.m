%% data sets
close all,clear all

y=[127,129,135,139,141,140,138];
x=[1,25,30,43,56,60,76];

%% Calculate coefficient
fun=fittype('A*exp(-(x-mu)^2/(2*sigma^2))');

[cf,gof]=fit(x(:),y(:),fun,'Start',[]);

%% Interpolate the data

xi=linspace(x(1),x(end),2000);
Yi=cf.A*exp(-(xi-cf.mu).^2/(2*cf.sigma^2));

%% plot data
hold on
plot(x,y,'ro',xi,Yi,'b');