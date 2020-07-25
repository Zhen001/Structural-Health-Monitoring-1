%此程序用于提取随机子空间法的阻尼和频率，即对应频率的对应阻尼，得到ssitiqu矩阵
%此程序在运行了SSI_zht之后运行
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
        %当两频率差大于0.1，认为阶数上升一阶
        shumu=m_jie-n_jie+1;        
        temp=tiqu1(n_jie:m_jie,:);
        juzhen_tiqu(1:shumu,2*jieshu-1:2*jieshu)=temp;
        %每一阶的频率和阻尼比矩阵
        pingjun2=mean(temp,1);
        juzhen_pingjun(2*jieshu-1:2*jieshu)=pingjun2;
        %求每一阶的平均频率和平均阻尼比
        shumu_tiqu(2*jieshu-1:2*jieshu)=[shumu shumu];            %求每一阶的稳定点数目
        jieshu_tiqu(2*jieshu-1:2*jieshu)=[jieshu jieshu];
        biaozhuncha_tiqu(2*jieshu-1)=sqrt(sum((temp(:,1)-pingjun2(1)).^2)/shumu);  %频率标准差
        biaozhuncha_tiqu(2*jieshu)=sqrt(sum((temp(:,2)-pingjun2(2)).^2)/shumu); %阻尼标准差
        n_jie=m_jie+1;
        jieshu=jieshu+1;
    end
end
zonghe=[shumu_tiqu;juzhen_pingjun;biaozhuncha_tiqu;juzhen_tiqu]; %稳定点数目，频率和阻尼平均数，标注差，每一阶的数据
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
    % 为提取的数据，共四列，第一列为序数，第二列为识别的频率，
    % 第三列为频率的标准差，第四列为识别的阻尼比，
    % 第五列为阻尼标准差，第六列为识别的点数。
    ssitiquxibu=zonghe;

    

    
        
