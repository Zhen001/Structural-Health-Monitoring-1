Eigensystem realization Algorithm - ERA Demo



����ϵͳʵ�ַ�(Eigensystem realization algorithm,ERA)�㷨toolbox for matlab Demo ver

%   By Yi, Chen -  24th Jan.,2004
%  State Key lab of Mechanical Transmission , Chonqqing University
%  leo.chen.yi@gmail.com

#Input Data

1. YData ----------------------M*N��������Ӧ����
                                (MIMO) �磺һ������Ӧ��Ϊ1*n��ʱ������
2. sampling_time---------------����ʱ��
3. sampling_frequencyHz--------����Ƶ��

# Output Data

4. System_Eigenvalue-----------��ERA�㷨�õ���ϵͳ��������
5. System_Shape----------------��ERA�㷨�õ���ϵͳ����
6. MAC----------------------------------ģ̬��ֵ���ϵ����[0,1], MAC(I)-->1 ������I��ϵͳģ̬;��MAC(I)-->0����������ģ̬;
7.MPC-----------------------------------ģ̬��λ������,[0,1], MPC(I)-->1 ������I��ϵͳģ̬(С����);��MPC(I)-->0����������ģ̬��ģ̬(������);
#m.files
8.ERA-----------------------------------ERA ʵ�ֺ���
9. ERA_StartDemo-------------------- ERA ������
10. sindata_generater------------------��9.���׵������źŲ������Գ���
