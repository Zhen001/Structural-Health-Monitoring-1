% function [Result]=ERA(Y,fs,ncols,nrows,inputs,cut,shift,EMAC_option)

%Inputs :

%Y: Free vibration output data in a form of Y=[Y1 Y2 ... Y_Ndata] Yi is Markov Parameter of size (outputs,inputs) and the total size is (outputs,inputs*Ndata)
%where outputs is the number of output channels, inputs is the number of inputs which equals to 1 unless free vibration data comes from Multi-reference channels NExT. 
%Ndata is the length of the data samples
%fs: Sampling frequency 
%ncols: The number of columns in hankel matrix (more than 2/3 of No. of data)
%nrows: The number of rows in hankel matrix (more than 20 * number of modes)
%inputs: The number of inputs which equals to 1 unless free vibration data comes from Multi-reference channels NExT 
%cut: cutoff value=2*no of modes
%shift: Shift value in the final row and column blocks (Increase EMAC sensitivity) usually =10
%EMAC_option: if this value equals to 1, EMAC will be independent of the number of columns (calculated only from observability matrix not from controllability) 

%Outputs :

%Result: A structure consist of the below components
%Parameters: NaFreq : Natural frequencies vector
%DampRatio: Damping ratios vector
%ModeShape: Mode shape matrix
%Indicators: MAmC : Modal Amplitude Coherence
%EMAC: Extended Modal Amplitude Coherence                                    
%MPC: Modal Phase Collinearity
%CMI: Consistent Mode Indicator
%partfac: Participation factor
%Matrices A,B,C: Discrete A,B and C matrices

%--------------------------------------------------------------------------

function [Result]=ERA(Y,fs,ncols,nrows,inputs,cut,shift,EMAC_option)

%--------------------------------------------------------------------------

[outputs,npts]=size(Y);       % Computes the size of matrix Y

if outputs > npts             % Check if Y matrix size is proper or should be transposed
    Y=Y';
    [outputs,npts]=size(Y);
end

%--------------------------------------------------------------------------
% Find block sizes

brows=fix(nrows/outputs);     % brows = how many output blocks.
nrows=outputs*brows;          % Redefine the row numbers.
bcols=fix(ncols/inputs);      % bcols = how many time steps.
ncols=inputs*bcols;           % Redefine the column numbers.
m=inputs;                     % inputs number.
q=outputs;                    % outputs number.


%--------------------------------------------------------------------------
% Form the Hankel matrix H(0).

H0=zeros(nrows,ncols);
for ii=1:brows
    for jj=1:bcols
        if ii==brows || jj==bcols
            sh=shift;
        else
            sh=1;
        end
             if ii==brows && jj==bcols
               sh=2*shift-1;
             end
                    
            H0([(ii-1)*q+1:ii*q] ,[(jj-1)*m+1:jj*m] )=Y(:,(sh-1+(jj-1)+ii-1)*m+1:(sh-1+(jj)+ii-1)*m); 
    end
end



%--------------------------------------------------------------------------
% Decompose the data matrix

[R1,Sigma1,S1]=svd(H0,0);
sv=diag(Sigma1);

%--------------------------------------------------------------------------
% Truncate the matrices using the cutoff

D=diag(sqrt(sv(1:cut)));      % build square root of the singular values.
Dinv=inv(D);				  % (sigma)^(-1/2)
Rn=R1(:,1:cut);               % use only the principal eigenvectors
Sn=S1(:,1:cut);               % use only the principal eigenvectors

%--------------------------------------------------------------------------
% Build the second Hankel matrix H(1).

H1=zeros(nrows,ncols);
for ii=1:brows
    for jj=1:bcols
        if (ii==brows || jj==bcols) 
            sh=shift;
        else
            sh=1;
        end
                 
            if ii==brows && jj==bcols
                sh=2*shift-1;
            end
        
                    
            H1([(ii-1)*q+1:ii*q] ,[(jj-1)*m+1:jj*m] )=Y(:,(sh-1+(jj-1)+ii)*m+1:(sh-1+(jj)+ii)*m); 
    end
end


%--------------------------------------------------------------------------
% Calculate the realization of A and find eigenvalues and eigenvectors

A=Dinv*Rn'*H1*Sn*Dinv;         % build A as per ERA. 
B=D*Sn';B=B(:,1:m);            % build B as per ERA.
C=Rn*D; C=C(1:q,:);            % build C as per ERA. 
clear H0 H1;

%--------------------------------------------------------------------------
% Extract the modal frequencis , damping ratios and natural frequencis

[Vectors,Values]=eig(A);       % Eigenvalues and Eigenvectors
Lambda=diag(Values);           % roots in the Z-plane
s=log(Lambda).*fs;             % Laplace roots 
zeta=-real(s)./abs(s)*100;     % damping ratios
fd=(imag(s)./2./pi);            
                               % damped natural freqs:
shapes=C*Vectors;              % Mode shapes.

%--------------------------------------------------------------------------
%  Calculate  Modal Participation factors

clear partfac

InvV=inv(Vectors);
partfac=InvV*D*Sn(1:m,:)';


%--------------------------------------------------------------------------
% Calculate MAmC values

Bhat=InvV*B;
Lambda=diag(Values);
qhati=zeros(1,ncols);qhat=zeros(cut,ncols); 

for ii=1:cut
    for jj=1:bcols 
        qhati(1,(jj-1)*m+1:jj*m)=Bhat(ii,:)*Lambda(ii)^(jj-1); 
    end
    qhat(ii,:)=qhati;
end

Qbar=InvV*D*Sn'; 

for ii=1:cut
    qbar(ii,:)=Qbar(ii,:);
end

EMAC=[];
for ii=1:cut
    qhati=qhat(ii,:); 
    qbari=qbar(ii,:);
    EMAC(ii,1)=abs(qbari*qhati')/sqrt(abs(qbari*qbari')*abs(qhati*qhati'))*100; 
end

%--------------------------------------------------------------------------
% Calculate EMAC values

Con=D*Sn';   Con=Con(:,1:m);    %Con=Con(:,ncols-2*m+1:ncols-m); 
partinput22=InvV*A^(bcols+shift-2)*B;                                 
partinput2=InvV*D*Sn'; partinput2=partinput2(:,ncols-m+1:ncols);


partoutput22=(C*A^(brows+shift-2)*Vectors)';   %partoutput22=(Rn(nrows-2*q+1:nrows-q,:)*D*A^shift*Vectors)';
partoutput2=(Rn(nrows-q+1:nrows,:)*D*Vectors)';



for i=1:1:cut
    
    sum1=0;
    sum2=0; 
    
    for j=1:1:m
        for k=1:1:q
            
            Rij=abs(partinput22(i,j))/abs(partinput2(i,j));
            if Rij>1
                Rij=1/Rij;
            end
            Wij=1-(4/pi)*abs(angle(partinput22(i,j)/partinput2(i,j)));
            
            if Wij<0
                Wij=0;
            end
            
            EMACin=Rij*Wij;
            
            if EMAC_option==1
                EMACin=1;        %we assume that in order to make value independent of number of columns
            end
            
            Rik=abs(partoutput22(i,k))/abs(partoutput2(i,k));
            if Rik>1
                Rik=1/Rik;
            end
            Wik=1-(4/pi)*abs(angle(partoutput22(i,k)/partoutput2(i,k)));       
            
            if Wik<0
                Wik=0;
            end
            
            EMACout=Rik*Wik;
            
            EMACijk=EMACin*EMACout;
            sum1=sum1+EMACijk*(abs(partinput2(i,j)))^2*(abs(partoutput2(i,k)))^2*100;
            sum2=sum2+(abs(partinput2(i,j)))^2*(abs(partoutput2(i,k)))^2;
        end
    end
    EMACC(i)=sum1/sum2;
end

%--------------------------------------------------------------------------
% Calculate MPC values
 
clear MPC
for ii=1:1:cut
    
cd=sum(shapes(:,ii))/q;
cj=shapes(:,ii);

Sxx=(real(cj-cd))'*(real(cj-cd));
Sxy=(real(cj-cd))'*(imag(cj-cd));
Syy=(imag(cj-cd))'*(imag(cj-cd));

mu=(Syy-Sxx)/(2*Sxy);
Beta=mu+sign(Sxy)*sqrt(mu^2+1);
Tau=atan(Beta);

l1=Sxx+(Sxy*(2*(mu^2+1)*(sin(Tau))^2-1))/mu;
l2=Syy-(Sxy*(2*(mu^2+1)*(sin(Tau))^2-1))/mu;

MPC(ii)=100*(2*(l1/(l1+l2)-0.5))^2;

end

%--------------------------------------------------------------------------
% Sort into ascending order

[fd,I]=sort(fd);
zeta=zeta(I);
shapes=shapes(:,I);
s=s(I); 
partfac=partfac(I,:);
EMAC=EMAC(I);
EMACC=EMACC(I);
MPC=MPC(I);
%--------------------------------------------------------------------------
% Remove the negative frequencies and frequencies>fs/2

lower=1;
upper=cut;
for ii=1:cut
    if fd(ii) <= 0
        lower=ii+1;
    end
    if fd(cut-ii+1) >= 0.499*fs
        upper=cut-ii;
    end
end

fd1=fd(lower:upper); 
zeta1=zeta(lower:upper);
fd1=fd1./sqrt(1-(zeta1/100).^2); % Calculate the undamped natural frequency
Lambda1=s(lower:upper);
shapes=shapes(:,lower:upper);
partfac=partfac(lower:upper,:);
EMAC1=EMAC(lower:upper);
EMACC1=EMACC(lower:upper);
MPC1=MPC(lower:upper);
% Sort again
%--------------------------------------------------------------------------

[fd1,ii]=sort(fd1); 
zeta1=zeta1(ii); 
EMAC1=EMAC1(ii);
EMACC1=EMACC1(ii);
MPC1=MPC1(ii);
shapes=shapes(:,ii); 
partfac=partfac(ii,:);
Lambda1=Lambda1(ii);

% Normalize modeshapes and process them
%--------------------------------------------------------------------------
Phi=shapes;
HH = size(Phi);
[C1,II] = max(abs(Phi));
    for jj = 1:HH(2)
        b = -angle(Phi(II(jj),jj));
        ModeShapeS(:,jj) = real(Phi(:,jj)*exp(1i*b));
        ModeShapeS(:,jj) = ModeShapeS(:,jj)/norm(ModeShapeS(:,jj));
    end
shapes=ModeShapeS;



%--------------------------------------------------------------------------

MAmC=EMAC1;
EMAC=EMACC1';
MPC=MPC1';
CMI=EMAC.*MPC/100;

%--------------------------------------------------------------------------

%*********************
%   Output format    *
%*********************

NaFreq=fd1;             % Natural frequencies vector
DampRatio=zeta1;        % Damping ratios vector
ModeShape=shapes;       % Mode shape matrix

%Froming Result structure
%------------------------

Result.Parameters.NaFreq=NaFreq;
Result.Parameters.DampRatio=DampRatio;
Result.Parameters.ModeShape=ModeShape;

Result.Indicators.MAmC=MAmC;
Result.Indicators.EMAC=EMAC;
Result.Indicators.MPC=MPC;
Result.Indicators.CMI=CMI;
Result.Indicators.partfac=partfac;

Result.Matrices.A=A;
Result.Matrices.B=B;
Result.Matrices.C=C;

end