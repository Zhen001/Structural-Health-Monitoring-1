%�˳���������ȡ����ӿռ䷨�������Ƶ�ʣ�����ӦƵ�ʵĶ�Ӧ���ᣬ�õ�ssitiqu����
%�˳�����������SSI_zht֮������
[hang,lie]=size(FFF);
pn=1;
for hang1=1:hang
    for lie1=1:lie
        if FFF(hang1,lie1)>0
            pn=1+pn;
            pinlv(pn)=FFF(hang1,lie1);
            zuni(pn)=DAMP1(hang1,lie1);
        end
    end
end
tiqu0=[pinlv;zuni];
tiqu1=sortrows(tiqu0');

n_jie=1;
m_jie=1;
jieshu=1; 
flag=length(tiqu1);
for m_jie=1:flag
    if m_jie==flag||tiqu1(m_jie+1,1)-tiqu1(m_jie,1)>0.2  
        %����Ƶ�ʲ����0.1����Ϊ��������һ��
        shumu=m_jie-n_jie+1;        
        temp=tiqu1(n_jie:m_jie,:);
        juzhen_tiqu(1:shumu,2*jieshu-1:2*jieshu)=temp;
        %ÿһ�׵�Ƶ�ʺ�����Ⱦ���
        pingjun2=mean(temp,1);
        juzhen_pingjun(2*jieshu-1:2*jieshu)=pingjun2;
        %��ÿһ�׵�ƽ��Ƶ�ʺ�ƽ�������
        shumu_tiqu(2*jieshu-1:2*jieshu)=[shumu shumu];            %��ÿһ�׵��ȶ�����Ŀ
        jieshu_tiqu(2*jieshu-1:2*jieshu)=[jieshu jieshu];
        biaozhuncha_tiqu(2*jieshu-1)=sqrt(sum((temp(:,1)-pingjun2(1)).^2)/shumu);  %Ƶ�ʱ�׼��
        biaozhuncha_tiqu(2*jieshu)=sqrt(sum((temp(:,2)-pingjun2(2)).^2)/shumu); %�����׼��
        n_jie=m_jie+1;
        jieshu=jieshu+1;
    end
end
zonghe=[shumu_tiqu;juzhen_pingjun;biaozhuncha_tiqu;juzhen_tiqu]; %�ȶ�����Ŀ��Ƶ�ʺ�����ƽ��������ע�ÿһ�׵�����
zonghe2=zeros(jieshu-1,5);
zonghe2(:,1)=1:jieshu-1;
for flag2=1:jieshu-1
    zonghe2(flag2,2)=juzhen_pingjun(flag2*2-1);
    zonghe2(flag2,3)=biaozhuncha_tiqu(flag2*2-1);
    zonghe2(flag2,4)=juzhen_pingjun(flag2*2);
    zonghe2(flag2,5)=biaozhuncha_tiqu(flag2*2);
    zonghe2(flag2,6)=shumu_tiqu(flag2*2-1);
end

    ssitiqu=zonghe2; 
    % Ϊ��ȡ�����ݣ������У���һ��Ϊ�������ڶ���Ϊʶ���Ƶ�ʣ�
    % ������ΪƵ�ʵı�׼�������Ϊʶ�������ȣ�
    % ������Ϊ�����׼�������Ϊʶ��ĵ�����
    ssitiquxibu=zonghe;

    

    
        
