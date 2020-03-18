function [Dynamic_Mass_M,Modal_Mass_M,System_Eigenvalue,System_Modal_damper_angular_freqency,System_Modal_Angular_Freqency,System_Modal_Damper_Ratio, System_Modal_Shape,System_recession_coefficient,MAC,MPC]=ERA(YData,sampling_frequencyHz)
% this is a ERA algorithm funciton for Modal analysis
% Attention to the formate of input data
% YData is 1*n , sampling_frequencyHz is 1*1
% By Chen yi, Jan. 24th,2004
% State Key lab of Mechanical Transmission , Chonqqing University
% chen_yi2000@sina.com
YData=YData';

[MM,NN]=size(YData);
if MM~=1
    disp('The YData must be a vector (1*n)');
   return;
else
    disp('Input Data is ok....')
sampling_step=1/sampling_frequencyHz;
% generate hankel matrix    
H0=hankel([YData(1:NN-1)]);
H1=hankel([YData(2:NN)]);

[HankelMM,HankelNN]=size(H0);
[ElHankelMM,ElHankelNN]=size(H0(1,1));

[UU,SS,VV]=svd(H0,0);

EM=[eye(ElHankelMM),zeros(ElHankelMM,HankelMM-1)];
EL=[eye(ElHankelNN),zeros(ElHankelNN,HankelNN-1)];

%ERA_A1=inv(SS)*UU'*H1*VV;
%ERA_B1=VV'*EL';
%ERA_G=EM*UU*SS;

ERA_A1=SS^(-0.5)*UU'*H1*VV*SS^(-0.5);
ERA_B1=SS^(-0.5)*VV'*EL';
ERA_G=EM*UU*SS^(-0.5);
%
[Eigen_Vector_A1,Eigen_Value_A1]=eig(ERA_A1,'nobalance');
 System_Modal_Shape=ERA_G*Eigen_Vector_A1;
% System_Modal_Shape_Matrix=zeros(2*size(Eigen_Vector_A1,2),2*size(Eigen_Vector_A1,2));
 
System_Modal_damper_angular_freqency=zeros(1,2*size(Eigen_Vector_A1,2));
System_Modal_Angular_Freqency=zeros(1,2*size(Eigen_Vector_A1,2));
System_Eigenvalue=zeros(1,2*size(Eigen_Vector_A1,2));
System_Eigenvalue_Matrix=eye(2*size(Eigen_Vector_A1,2),2*size(Eigen_Vector_A1,2));
System_Modal_Damper_Ratio=zeros(1,2*size(Eigen_Vector_A1,2));
System_recession_coefficient=zeros(1,2*size(Eigen_Vector_A1,2));

disp('System Eigen Pairs are estmating.....')
for loop_eigen=1:size(Eigen_Vector_A1,2)
    %
    System_Eigenvalue(1,loop_eigen)=(log(Eigen_Value_A1(loop_eigen,loop_eigen))+2*pi*loop_eigen*1i)/sampling_step;
    System_Eigenvalue(1,size(Eigen_Vector_A1,2)+loop_eigen)=(log(Eigen_Value_A1(loop_eigen,loop_eigen))-2*pi*loop_eigen*1i)/sampling_step;
    System_Eigenvalue_Matrix(loop_eigen,loop_eigen)=System_Eigenvalue(1,loop_eigen);
    System_Eigenvalue_Matrix(size(Eigen_Vector_A1,2)+loop_eigen,size(Eigen_Vector_A1,2)+loop_eigen)=System_Eigenvalue(1,size(Eigen_Vector_A1,2)+loop_eigen);
     
%    System_Modal_Shape_Matrix(loop_eigen,loop_eigen)=System_Modal_Shape(1,loop_eigen);
%    System_Modal_Shape_Matrix(size(Eigen_Vector_A1,2)+loop_eigen,size(Eigen_Vector_A1,2)+loop_eigen)=System_Modal_Shape(1,size(Eigen_Vector_A1,2)+loop_eigen);
    % modal parameters
    
   System_Modal_damper_angular_freqency(1,loop_eigen)=imag(System_Eigenvalue(1,loop_eigen));
   System_Modal_damper_angular_freqency(1,size(Eigen_Vector_A1,2)+loop_eigen)=imag(System_Eigenvalue(1,size(Eigen_Vector_A1,2)+loop_eigen));
   
   System_recession_coefficient(1,loop_eigen)=abs(real(System_Eigenvalue(1,loop_eigen)));
   System_recession_coefficient(1,size(Eigen_Vector_A1,2)+loop_eigen)=abs((real(System_Eigenvalue(1,size(Eigen_Vector_A1,2)+loop_eigen))));
   
   System_Modal_Angular_Freqency(1,loop_eigen)=normest(System_Eigenvalue(1,loop_eigen));
   System_Modal_Angular_Freqency(1,size(Eigen_Vector_A1,2)+loop_eigen)=normest(System_Eigenvalue(1,size(Eigen_Vector_A1,2)+loop_eigen));
   
   System_Modal_Damper_Ratio(1,loop_eigen)=System_recession_coefficient(1,loop_eigen)/System_Modal_Angular_Freqency(1,loop_eigen);
   System_Modal_Damper_Ratio(1,size(Eigen_Vector_A1,2)+loop_eigen)=System_recession_coefficient(1,size(Eigen_Vector_A1,2)+loop_eigen)/System_Modal_Angular_Freqency(1,size(Eigen_Vector_A1,2)+loop_eigen);  

end  

%dy=Ay+Bf(t)
Statespace_B=ERA_A1^(-1)*ERA_B1;
%Statespace_A=System_Modal_Shape'.^(-1)*System_Eigenvalue(1:size(System_Modal_Shape,1),1:size(System_Modal_Shape,1))*System_Modal_Shape';

%
Dynamic_Mass_M=Statespace_B.^(-1);
%Dynamic_Stiffness_K=-Dynamic_Mass_M*Statespace_A(1:size(Statespace_B,2),1:size(Statespace_B,2));
%Dynamic_Damping_C=-Dynamic_Mass_M*Statespace_A(size(Statespace_B,2):2*size(Statespace_B,2),size(Statespace_B,2):2*size(Statespace_B,2));
%
Modal_Mass_M=conj(System_Modal_Shape)*Dynamic_Mass_M*System_Modal_Shape;
%Modal_Stiffness_K=conj(System_Modal_Shape')*Dynamic_Stiffness_K*System_Modal_Shape;
%Modal_Damping_C=conj(System_Modal_Shape')*Dynamic_Damping_C*System_Modal_Shape;

System_Modal_damper_angular_freqency=sort(System_Modal_damper_angular_freqency,2);
System_Modal_Damper_Ratio=sort(System_Modal_Damper_Ratio);
System_Modal_Angular_Freqency=sort(System_Modal_Angular_Freqency);
System_recession_coefficient=sort(System_recession_coefficient,2);
%MAC &MPC
disp('System Eigen Pairs are ok....')
ERA_B0=((Eigen_Vector_A1^(-1))*ERA_B1)';
[~,ERA_B0MM]=size(ERA_B0);
theory_qq=zeros(ERA_B0MM,HankelNN);
MAC=ones(1,ERA_B0MM);

practice_qq=conj(((Eigen_Vector_A1^(-1))*SS^(0.5)*VV')');

for loop_B0=1:ERA_B0MM
    for loop_qq=1:HankelNN
    theory_qq(loop_B0,loop_qq)=exp((loop_B0-1)*sampling_step*loop_qq)*ERA_B0(loop_qq);
end
MAC(loop_B0)=normest(theory_qq(loop_B0)*practice_qq(loop_B0))/(normest(theory_qq(loop_B0)*practice_qq(loop_B0))*normest(conj(theory_qq(loop_B0))*conj(practice_qq(loop_B0))))^0.5;
end

[M,N]=size(System_Modal_Shape);
OneElement=ones(1,N);
Pusi=ones(1,N);
DeltaPusi=ones(M,N);
MPC=ones(1,N);

for loop_M=1:M
Pusi(loop_M)=(System_Modal_Shape(loop_M,:)*OneElement')/M;
DeltaPusi(loop_M,:)= System_Modal_Shape(loop_M,:)-(Pusi(loop_M)*OneElement);
Pusirr=normest(real(DeltaPusi(loop_M,:)))^2;

Pusiri=real(DeltaPusi(loop_M,:))*imag(DeltaPusi(loop_M,:))';
Pusiii=normest(imag(DeltaPusi(loop_M,:)))^2;
ee=(Pusiii-Pusirr)/((2*Pusiri)+.000001);
seta=atan(ee+sign(ee)*sqrt(1+ee^2));
MPC(loop_M)=(Pusirr+Pusiri*(2*(ee^2+1)*sin(seta)^2-1)/(ee))/(Pusiii+Pusirr);
end
disp('MAC &MPC is ok....')
end