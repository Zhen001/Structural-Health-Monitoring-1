function [zeta, frequency] = Filter_RDT_function_py(Az,Fs,fn,fnMin,fnMax,long_out,optionPlot,picture_name)

if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end

% [IRF] = RDT(y,ys,T,dt) returns the impulse response function (IRF) by
% using the random decrement technique (RDT) to the time serie y, with a
% triggering value ys, and for a duration T
%
% INPUT:
% Az: acceleration data. Matrix of size [Nyy x N] where Nyy is the number of sensors, and N is the number of time steps
% y: time series of ambient vibrations: vector of size [1xN]
% ys: triggering values (ys < max(abs(y)) and here ys~=0)
% Fs: sample frequency
% fn: Vector of size [1x M];  "target eigen frequencies"
% OUTPUT:
% IRF: impusle response function
% t: time vector asociated to IRF
% zeta : modal damping ratio

%% Preprocessing
format longG
long_out = long_out + 50; % zht�޸� Ϊ����ȥǰ���25����ϵĲ��õ�envelop������envelop_and_fit_function.mһ���
fn = fn(:)';
Nmodes = numel(fn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pinlv_jiangcaiyang = 20;                        % ������Ƶ��
Az=resample(Az',pinlv_jiangcaiyang*10,Fs*10);   % ������,Ĭ��ÿ�е���������
Az=Az';
Fs=pinlv_jiangcaiyang;                          % ��Ƶ���滻�ɽ�����Ƶ��
close all
% if optionPlot
%      plot(Az); 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Nyy,N] = size(Az); % Dimension of displacement matrix. Nyy ��ʵ����1

%% Band pass filtering for each modes
Az_filt = zeros(Nmodes,Nyy,N);
for ii=1:Nmodes
    h1=fdesign.bandpass('N,F3dB1,F3dB2',20,fnMin(ii),fnMax(ii),Fs); % �����ü����˲���Ҫ����
    d1 = design(h1,'butter');
    for jj=1:Nyy
        Az_filt(ii,jj,:) = filtfilt(d1.sosMatrix,d1.ScaleValues, Az(jj,:));
    end
end

%% Calculate the damping ratio
zeta = zeros(Nyy,Nmodes);
frequency = zeros(Nyy,Nmodes);
for ii=1:Nyy
    for jj=1:Nmodes
        y = squeeze(Az_filt(jj,ii,:))';
        ys1 = sqrt(2)*std(y);
%         ys1 = mean(abs(y));
%         ys1 = ys * max(y); ysָռ���ֵ�ı���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if optionPlot 
%             figure; plot(y); ANPSD_function_py(y,Fs,0,2,2,0,1,10,0.1);
%         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% RDT
        if long_out >= numel(y)-1
            error('Error: subsegment length is too large');
        end
        if ys1==0
            error('Error: ys must be different from zero')
        elseif or(ys1 >=max(y),ys1 <=min(y))
            error('Error:  ys must verifiy : min(y) < ys < max(y)')
        else
            % find triggering value
            ind=find(diff(y(1:end-long_out)>ys1)~=0)+1;   
        end
        % construction of decay vibration
        IRF = zeros(numel(ind),long_out);
        for iii=1:numel(ind)
            IRF(iii,:)=y(ind(iii):ind(iii)+long_out-1);
        end
        % averaging to remove the random part
        IRF = mean(IRF);
        % normalize the IRF
        IRF = IRF./IRF(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% NExT
%         [~,IRF] = NExT_function_py(y,y,Fs,long_out,optionPlot,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if optionPlot 
%             figure; plot(y); ANPSD_function_py(y,Fs,0,2,2,0,1,10,0.1);
%         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% Envelop and fit
        zeta(ii,jj) = envelop_and_fit_function(IRF,Fs,fn(ii),optionPlot);
%         [~,~,frequency(ii,jj),~] =  ANPSD_function_py(y,Fs,0,2,2,0,optionPlot,10,0.2);
        ind_max = find(diff(diff(IRF)>0)==-1);
        ind_min = find(diff(diff(IRF)>0)==1)+1;
        frequency(ii,jj) = Fs/((sum(diff(ind_max)) + sum(diff(ind_min)))/(length(ind_max)+length(ind_min)-2));
        picture_path = [picture_name,'-',num2str(jj),'.png'];
        print(gcf, '-dpng', picture_path);
    end
end

end
