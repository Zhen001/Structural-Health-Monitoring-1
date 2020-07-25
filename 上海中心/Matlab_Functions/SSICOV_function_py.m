function [fn,zeta,phi,plotdata] = SSICOV_function_py(y,fs,varargin)
close all
% 出图说明
% stable pole : 频率、阵型、阻尼同时满足精度要求
% stable freq.& MAC : 频率、阵型满足精度要求
% stable freq.& damp.: 频率、阻尼满足精度要求
% stable freq.: 频率满足精度要求

%
% -------------------------------------------------------------------------
% [fn,zeta,phi,plotdata] = SSICOV(y,fs,varargin) identifies the modal
% parameters of the M-DOF system whose response histories are located in
% the matrix y, sampled with a time step fs.
% -------------------------------------------------------------------------
% Input:
% y: time series of ambient vibrations: matrix of size [MxN]
% fs : scalar: frequency
% Varargin: contains additional optaional parameters:
%	'Ts': scalar : time lag for covariance calculation
%	'methodCOV': scalar: method for COV estimate ( 1 or 2)
%	'Nmin': scalar: minimal number of model order
%	'Nmax': scalar: maximal number of model order
%	'eps_freq': scalar: frequency accuracy
%	'eps_zeta': scalar: % damping accuracy
%	'eps_MAC': scalar: % MAC accuracy
%	'eps_cluster': scalar: % maximal distance inside each cluster
% -------------------------------------------------------------------------
% Output:
% fn: eigen frequencies identified
% zeta:  modal damping ratio identified
% phi:mode shape identified
% plotdata: structure data useful for stabilization diagram
% -------------------------------------------------------------------------
%  Syntax:
% [fn,zeta,phi] = SSICOV(y,fs,'Ts',30) specifies that the time lag
% has to be 30 seconds.
%
% [fn,zeta,phi] = SSICOV(y,fs,'Ts',30,'Nmin',5,'Nmax',40) specifies that the
% time lag has to be 30 seconds, with a system order ranging from 5 to 40.
%
% [fn,zeta,phi] = SSICOV(y,fs,'eps_cluster',0.05) specifies that the
% max distance inside each cluster is 0.05 hz.
%
% [fn,zeta,phi] = SSICOV(y,fs,'eps_freq',1e-2,'eps_MAC'.1e-2) changes the
% default accuracy for the stability checking procedure
%
% -------------------------------------------------------------------------
% Organization of the function:
% 6 steps:
% 1 - Claculation of cross-correlation function
% 2 - Block hankel assembling and SVD of the block-Hankel matrix
% 3 - Modal identification procedure
% 4 - Stability checking procedure
% 5 - Selection of stable poles only
% 6 - Cluster Algorithm
% -------------------------------------------------------------------------
% References:
% Magalhaes, F., Cunha, A., & Caetano, E. (2009).
% Online automatic identification of the modal parameters of a long span arch
% bridge. Mechanical Systems and Signal Processing, 23(2), 316-329.
%
% Magalh茫es, F., Cunha, 脕., & Caetano, E. (2008).
% Dynamic monitoring of a long span arch bridge. Engineering Structures,
% 30(11), 3034-3044.
% -------------------------------------------------------------------------
% Author: E Cheynet, Universitetet i Stavanger
% Last modified: 03/03/2019
% -------------------------------------------------------------------------
%
% see also plotStabDiag.m

%%
% options: default values
p = inputParser();
p.CaseSensitive = false;
p.addOptional('new_f',0);
p.addOptional('Ts',500/fs);
p.addOptional('methodCOV',1);
p.addOptional('Nmin',1);
p.addOptional('Nmax',50);
% 非绝对值精读，而是相对精度
p.addOptional('eps_freq',1e-2);
p.addOptional('eps_zeta',4e-2);
p.addOptional('eps_MAC',5e-3);
p.addOptional('eps_cluster',0.2);
% 滤波，通带范围
p.addOptional('filtering', [0,0]); 
% 是否用python作图
p.addOptional('draw',1);
% 是否用matlab作图
p.addOptional('draw_matlab',0);
% 作图范围
p.addOptional('Xrange',[0,0]);
% 是否取对数
p.addOptional('if_log',0);

p.parse(varargin{:});
Ts = p.Results.Ts;
draw = p.Results.draw;
Nmin = p.Results.Nmin ;
Nmax = p.Results.Nmax ;
new_f = p.Results.new_f ;
Xrange = p.Results.Xrange;
if_log = p.Results.if_log;
eps_MAC = p.Results.eps_MAC ;
eps_freq = p.Results.eps_freq ;
eps_zeta = p.Results.eps_zeta ;
methodCOV = p.Results.methodCOV;
filtering = p.Results.filtering;
eps_cluster = p.Results.eps_cluster;
draw_matlab = p.Results.draw_matlab;

% Number of outputs must be >=3 and <=4.
nargoutchk(3,4)
% 输入数据预处理
if size(y,2)>size(y,1)
    y=y';                             % 转成一个测点一列
end 
Nyy = size(y,2);
% 降采样相关设置
if new_f
    y=resample(y,new_f*1000,fs*1000); % 降采样,默认每列单独降采样
    fs=new_f;                         % 将频率替换成降采样频率
end
% 消除趋势项
y = detrend(y);                       % 默认每列单独进行
% 滤波
if sum(filtering ~= [0,0])
    fs2=fs/2;                         % 奈奎斯特频率
    Wp=filtering(1);                  % 通带频率（需手动调整）
    Ws=filtering(2);                  % 阻带频率（需手动调整）
    Wp=Wp/fs2;                        % 归一化通带频率
    Ws=Ws/fs2;                        % 归一化阻带频率
    Rp=1;                             % 通带波纹
    Rs=50;                            % 阻带衰减
    [jieshu,Wn]=buttord(Wp,Ws,Rp,Rs); % 求滤波器原型阶数和带宽
    [bn1,an1]=butter(jieshu,Wn);      % 求数字滤波器系数
    y=filter(bn1,an1,y);              % 对数据进行滤波，默认每列单独滤波
end
% 大致看下滤波效果，检验一下是否成功
if draw_matlab 
    [pxx,f] = pwelch(y(:,1),[],[],[],fs);
    plot(f,pxx)
end

%  Natural Excitation Technique (NeXT)
[IRF,~] = NExT(y,fs,Ts,methodCOV);
% Block Hankel computations
[U,S,V] = blockHankel(IRF);
if isnan(U)
    fn = nan;
    zeta = nan;
    phi = nan;
    return
end
% Stability check
kk=1;
for ii=Nmax:-1:Nmin % decreasing order of poles
    if kk==1
        [fn0,zeta0,phi0] = modalID(U,S,V,ii,Nyy,fs);
    else
        [fn1,zeta1,phi1] = modalID(U,S,V,ii,Nyy,fs);
        [a,b,c,d,e] = stabilityCheck(fn0,zeta0,phi0,fn1,zeta1,phi1,eps_freq,eps_zeta,eps_MAC);
        fn2{kk-1}=a;
        zeta2{kk-1}=b;
        phi2{kk-1}=c;
        MAC{kk-1}=d;
        stablity_status{kk-1}=e;
        fn0=fn1;
        zeta0=zeta1;
        phi0=phi1;
    end
    kk=kk+1;
end

% sort for increasing order of poles
stablity_status=fliplr(stablity_status);
fn2=fliplr(fn2);
zeta2=fliplr(zeta2);
phi2=fliplr(phi2);
MAC=fliplr(MAC);

% get only stable poles
[fnS,zetaS,phiS,~] = getStablePoles(fn2,zeta2,phi2,MAC,stablity_status);

if isempty(fnS)
    warning('No stable poles found');
    fn = nan;
    zeta = nan;
    phi = nan;
    return
end

% Hierarchical cluster
[fn3,zeta3,phi3] = myClusterFun(fnS,zetaS,phiS,eps_cluster,eps_MAC);
if isnumeric(fn3)
    warning('Hierarchical cluster failed to find any cluster');
    fn = nan;
    zeta = nan;
    phi = nan;
    return
end
save('clusterData.mat','fn3','zeta3')

% average the clusters to get the frequency and mode shapes
fn = zeros(1,numel(fn3));
zeta = zeros(1,numel(zeta3));
phi = zeros(numel(phi3), Nyy);
for ii=1:numel(fn3)
    fn(ii)=nanmean(fn3{ii});
    zeta(ii)=nanmean(zeta3{ii});
    phi(ii,:)=nanmean(phi3{ii},2);
end

% sort the eigen frequencies
[fn,indSort]=sort(fn);
zeta = zeta(indSort);
phi = phi(indSort,:);

% stabilization diagram
if nargout==4
    paraPlot.status=stablity_status;
    paraPlot.Nmin = Nmin;
    paraPlot.Nmax = Nmax;
    paraPlot.fn = fn2;
end

% 作图
if draw
    if Xrange(1) < Xrange(2)
        plotdata = plotStabDiag(paraPlot.fn,y,fs,paraPlot.status,paraPlot.Nmin,paraPlot.Nmax,'Xrange',Xrange,'if_log',if_log,'draw_matlab',draw_matlab);
    else
        plotdata = plotStabDiag(paraPlot.fn,y,fs,paraPlot.status,paraPlot.Nmin,paraPlot.Nmax,'if_log',if_log,'draw_matlab',draw_matlab);
    end
else
    plotdata = {};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 以下为子函数部分
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U,S,V] = blockHankel(h)
    %
    % [H1,U,S,V] = SSICOV(h) calculate the shifted block hankel matrix H1 and
    % the  result from the SVD of the block hankel amtrix H0
    %
    % Input:
    % h: 3D-matrix
    %
    % Outputs
    % H1: Shifted block hankel matrix
    % U : result from SVD of H0
    % S : result from SVD of H0
    % V : result from SVD of H0
    %%
    if or(size(h,1)~=size(h,2),ismatrix(h))
        error('the IRF must be a 3D matrix with dimensions <M x M x N> ')
    end
    % get block Toeplitz matrix
    N1 = round(size(h,3)/2)-1;
    M = size(h,2);
    clear H0
    for oo=1:N1
        for ll=1:N1
            T1((oo-1)*M+1:oo*M,(ll-1)*M+1:ll*M) = h(:,:,N1+oo-ll+1);
        end
    end
    if or(any(isinf(T1(:))),any(isnan(T1(:))))
        warning('Input to SVD must not contain NaN or Inf. ')
        U=nan;
        S=nan;
        V=nan;
        return
    else
        try
            [U,S,V] = svd(T1);
        catch exception
            warning(' SVD of the block-Toeplitz did not converge ');
            U=nan;
            S=nan;
            V=nan;
            return
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [IRF,t] = NExT(x,fs,Ts,method)
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
    % x: time series of ambient vibrations: vector of size [1xN]
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fn,zeta,phi] = modalID(U,S,V,Nmodes,Nyy,fs)
    %
    % [fn,zeta,phi] = modalID(H1,U,S,V,N,M) identify the modal propeties of the
    % system, given the shifted block hankel matrix H1, and the outputs of the
    % SVD of the vlock hankel matrix H0
    %----------------------------------
    % Input:
    % U: matrix obtained from [U,S,V]=svd(H0) is [N1 x N1]
    % S: matrix obtained from [U,S,V]=svd(H0) is [N1 x N1]
    % V: matrix obtained from [U,S,V]=svd(H0) is [N1 x N1]
    % N: Number of modes (or poles)
    % M: Number of DOF (or sensors)
    %----------------------------------
    % Outputs
    % H1: Shifted block hankel matrix
    % U : result from SVD of H0
    % S : result from SVD of H0
    % V : result from SVD of H0
    % fs: frequency
    %----------------------------------


    if Nmodes>=size(S,1)
        warning(['Nmodes is larger than the numer of row of S. I have to take Nmodes = ',num2str(size(S,1))]);
        % extended observability matrix
        O = U*sqrt(S);
        % extended controllability matrix
        GAMMA = sqrt(S)*V';
    else
        O = U(:,1:Nmodes)*sqrt(S(1:Nmodes,1:Nmodes));
        % extended controllability matrix
        GAMMA = sqrt(S(1:Nmodes,1:Nmodes))*V(:,1:Nmodes)';
    end
    % Get A and its eigen decomposition

    IndO = min(Nyy,size(O,1));
    C = O(1:IndO,:);
    jb = round(size(O,1)./IndO);
    A = pinv(O(1:IndO*(jb-1),:))*O(end-IndO*(jb-1)+1:end,:);
    [Vi,Di] = eig(A);

    mu = fs.*log(diag(Di)); % poles
    fn = abs(mu(2:2:end))./(2*pi);% eigen-frequencies
    zeta = -real(mu(2:2:end))./abs(mu(2:2:end)); % modal amping ratio
    phi = real(C(1:IndO,:)*Vi); % mode shapes
    phi = phi(:,2:2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fn,zeta,phi,MAC,stablity_status] = stabilityCheck(fn0,zeta0,phi0,fn1,zeta1,phi1,eps_freq,eps_zeta,eps_MAC)
    % [fn,zeta,phi,MAC,stablity_status] = stabilityCheck(fn0,zeta0,phi0,fn1,zeta1,phi1)
    % calculate the stability status of each mode obtained for
    % two adjacent poles (i,j).
    %
    % Input:
    % fn0: eigen frequencies calculated for pole i: vetor of N-modes [1 x N]
    % zeta0: modal damping ratio for pole i: vetor of N-modes [1 x N]
    % phi0: mode shape for pole i: vetor of N-modes [Nyy x N]
    % fn1: eigen frequencies calculated for pole j: vetor of N-modes [1 x N+1]
    % zeta1: modal damping ratio for pole j: vetor of N-modes [1 x N+1]
    % phi1: mode shape for pole j: vetor of N-modes [Nyy x N+1]
    %
    % Output:
    % fn: eigen frequencies calculated for pole j
    % zeta:  modal damping ratio for pole i
    % phi:mode shape for pole i
    % MAC: Mode Accuracy
    % stablity_status: stabilitystatus

    %% frequency stability
    N0 = numel(fn0);
    N1 = numel(fn1);
    fn = zeros(1,N0*N1);
    zeta = zeros(1,N0*N1);
    phi = zeros(size(phi1,1),N0*N1);
    MAC = zeros(1,N0*N1);
    stablity_status = zeros(1,N0*N1);

    for rr=1:N0
        for jj=1:N1
            stab_fn = errCheck(fn0(rr),fn1(jj),eps_freq);
            stab_zeta = errCheck(zeta0(rr),zeta1(jj),eps_zeta);
            [stab_phi,dummyMAC] = getMAC(phi0(:,rr),phi1(:,jj),eps_MAC);
            % get stability status
            if stab_fn==0
                stabStatus = 0; % new pole
            elseif stab_fn == 1 && stab_phi == 1 && stab_zeta == 1
                stabStatus = 1; % stable pole
            elseif stab_fn == 1 && stab_zeta == 0 && stab_phi == 1
                stabStatus = 2; % pole with stable frequency and vector
            elseif stab_fn == 1 && stab_zeta == 1 && stab_phi == 0
                stabStatus = 3; % pole with stable frequency and damping
            elseif stab_fn == 1 && stab_zeta == 0 && stab_phi == 0
                stabStatus = 4; % pole with stable frequency
            else
                error('Error: stablity_status is undefined')
            end
            fn((rr-1)*N1+jj) = fn1(jj);
            zeta((rr-1)*N1+jj) = zeta1(jj);
            phi(:,(rr-1)*N1+jj) = phi1(:,jj);
            MAC((rr-1)*N1+jj) = dummyMAC;
            stablity_status((rr-1)*N1+jj) = stabStatus;
        end
    end

    [fn,ind] = sort(fn);
    zeta = zeta(ind);
    phi = phi(:,ind);
    MAC = MAC(ind);
    stablity_status = stablity_status(ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = errCheck(x0,x1,eps)
    if or(numel(x0)>1,numel(x1)>1)
        error('x0 and x1 must be a scalar');
    end
    if abs(1-x0./x1)<eps % if frequency for mode i+1 is almost unchanged
        y = 1;
    else
        y = 0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fnS,zetaS,phiS,MACS] = getStablePoles(fn,zeta,phi,MAC,stablity_status)
    fnS = [];zetaS = [];phiS=[];MACS = [];
    
    for oo=1:numel(fn)
        for jj=1:numel(stablity_status{oo})
            if stablity_status{oo}(jj)==1
                fnS = [fnS,fn{oo}(jj)];
                zetaS = [zetaS,zeta{oo}(jj)];
                phiS = [phiS,phi{oo}(:,jj)];
                MACS = [MACS,MAC{oo}(jj)];
            end
        end
    end

    % remove negative damping
    fnS(zetaS<=0)=[];
    phiS(:,zetaS<=0)=[];
    MACS(zetaS<=0)=[];
    zetaS(zetaS<=0)=[];

    % Normalized mode shape
    for oo=1:size(phiS,2)
        phiS(:,oo)= phiS(:,oo)./max(abs(phiS(:,oo)));
        if diff(phiS(1:2,oo))<0
            phiS(:,oo)=-phiS(:,oo);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fn,zeta,phi] = myClusterFun(fn0,zeta0,phi0,eps_cluster,eps_MAC)

    [~,Nsamples] = size(phi0);
    pos = zeros(Nsamples,Nsamples);
    for i1=1:Nsamples
        for i2=1:Nsamples
            [~,MAC0] = getMAC(phi0(:,i1),phi0(:,i2),eps_MAC); % here, eps_MAC is not important.
            pos(i1,i2) = abs((fn0(i1)-fn0(i2))./fn0(i2)) +1-MAC0; % compute MAC number between the selected mode shapes   
        end

    end

    if numel(pos)==1
        warning('linkage failed: at least one distance (two observations) are required');
        fn = nan;
        zeta = nan;
        phi = nan;
        return
    else
        Z =  linkage(pos,'single','euclidean');
        myClus = cluster(Z,'Cutoff',eps_cluster,'Criterion','distance');
        Ncluster = max(myClus);

        ss=1;
        fn = {};
        for rr=1:Ncluster
            if numel(myClus(myClus==rr))>4
                dummyZeta = zeta0(myClus==rr);
                dummyFn = fn0(myClus==rr);
                dummyPhi = phi0(:,myClus==rr);
                valMin = max(0,(quantile(dummyZeta,0.25) - abs(quantile(dummyZeta,0.75)-quantile(dummyZeta,0.25))*1.5));
                valMax =quantile(dummyZeta,0.75) + abs(quantile(dummyZeta,0.75)-quantile(dummyZeta,0.25))*1.5;
                dummyFn(or(dummyZeta>valMax,dummyZeta<valMin)) = [];
                dummyPhi(:,or(dummyZeta>valMax,dummyZeta<valMin)) = [];
                dummyZeta(or(dummyZeta>valMax,dummyZeta<valMin)) = [];
                fn{ss} = dummyFn;
                zeta{ss} = dummyZeta;
                phi{ss} = dummyPhi;
                ss=ss+1;
            end
        end
        if isempty(fn)
            fn = nan;
            zeta = nan;
            phi = nan;
            return
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y,dummyMAC] = getMAC(x0,x1,eps)
    Num = abs(x0(:)'*x1(:)).^2;
    D1= x0(:)'*x0(:);
    D2= x1(:)'*x1(:);
    dummyMAC = Num/(D1.*D2);
    if dummyMAC >(1-eps)
        y = 1;
    else
        y = 0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [plotdata] = plotStabDiag(fn,Az,fs,stablity_status,Nmin,Nmax,varargin)
% -------------------------------------------------------------------------
% [h] = plotStabDiag(fn,Az,fs,stablity_status,Nmin,Nmax) plots the
% stabilization diagram of the identified eigen frequencies as a function
% of the model order, calculated with the SSI-COV method.
% -------------------------------------------------------------------------
% Input:
% fn: cell : eigen frequencies identified for multiple system orders.
% Az : vector: Time serie of acceleration response (illustrative purpose)
% fs: sampling frequency
% stablity_status: cell of stability status for each model order
% Nmin: scalar: minimal number of model order
% Nmax: scalar: maximal number of model order
% Output: h: handle of the figure
% -------------------------------------------------------------------------
% See also: SSICOV.m
% -------------------------------------------------------------------------
% Author: Etienne Cheynet, UIS
% Updated on: 08/03/2016
% -------------------------------------------------------------------------
p = inputParser();
p.CaseSensitive = false;
p.addOptional('Xrange',[0, max([fn{:}])*1.1]);
p.addOptional('if_log',0);
p.addOptional('draw_matlab',0);
p.parse(varargin{:});
Xrange = p.Results.Xrange;
if_log = p.Results.if_log;
draw_matlab = p.Results.draw_matlab;

% SSI作图数据
Npoles =Nmin:1:Nmax;
for jj=0:4
    y = [];
    x = [];
    for ii=1:numel(fn)
        ind = find(stablity_status{ii}==jj);
        x = [x;fn{ii}(ind)'];
        y = [y;ones(numel(ind),1).*Npoles(ii)];
    end
    x1{jj+1}=x;
    y1{jj+1}=y;
end

% PP作图数据
if_NExT = 0;
if if_NExT
    [IRF,~] = NExT(Az(:,1),fs,length(Az(:,1))/fs,1);
else    
    IRF = Az(:,1);
end
[Saz,f]=pwelch(IRF,[],[],[],fs);
% [Saz,f]=pwelch(Az(:,1),[],[],[],fs);

if if_log
    Saz = log10(Saz);
    Saz = Saz - min(Saz);
    Saz = Saz./max(Saz(Xrange(1)<f & f<Xrange(2))).*Nmax*0.8;
else
    Saz = Saz./max(Saz(Xrange(1)<f & f<Xrange(2))).*Nmax*0.8;
end

% x1,y1是SSI的作图数据，f,Saz是PP的作图数据
plotdata = {x1,y1,f',Saz'}; 

if draw_matlab
    figure;
    ax1 = axes;
    hold on;box on

    h1=plot(x1{1},y1{1},'k+','MarkerEdgeColor','#666666','markersize',5);                                   % new pole
    h2=plot(x1{2},y1{2},'o','MarkerEdgeColor','k','MarkerFaceColor','r','markersize',5,'LineWidth',0.1);    % stable pole
    h3=plot(x1{3},y1{3},'o','MarkerEdgeColor','#1679F0','markersize',4.5,'LineWidth',1);                    % pole with stable frequency and vector
    h4=plot(x1{4},y1{4},'sq','MarkerEdgeColor','#B003CA','markersize',5,'LineWidth',1.5);                   % pole with stable frequency and damping
    h5=plot(x1{5},y1{5},'x','MarkerEdgeColor','#2DF65B','markersize',4.5,'LineWidth',1);                    % pole with stable frequency
    if isempty(h1),        h1=0;
    elseif isempty(h2),    h2=0;
    elseif isempty(h3),    h3=0;
    elseif isempty(h4),    h4=0;
    elseif isempty(h5),    h5=0;
    end

    H = [h1(1),h2(1),h3(1),h4(1),h5(1)];
    legend(H,...
        'new pole',...
        'stable pole',...
        'stable freq. & MAC',...
        'stable freq. & damp.',...
        'stable freq.',...
        'location','Northoutside','orientation','horizontal');

    title('SSI随机子空间','FontName','华文仿宋','FontWeight','bold','FontSize',20,'LineWidth',2,'position',[mean(Xrange) 56])
    xlabel('f (Hz)','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2,'position',[mean(Xrange) -3])
    ylabel('number of poles','FontName','华文仿宋','FontWeight','bold','FontSize',15,'LineWidth',2)
    xlim([0,max([fn{:}])*1.1])
    hold off

    ax2 = axes('YAxisLocation', 'Right');
    linkaxes([ax1,ax2])
    plot(ax2,f,Saz,'Color','#4C78A8','LineWidth',1);
    ax2.YLim = [0,Nmax];
    ax2.XLim = [Xrange(1),Xrange(2)];
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    set(gcf,'color','w','unit','centimeters','position',[0 2 25 13]); % 控制出图背景色和大小
end
