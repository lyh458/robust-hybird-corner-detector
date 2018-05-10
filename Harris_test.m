%Source Code: http://blog.csdn.net/anymake_ren/article/details/21298807

function [Corner_Location,CRF] = Harris_test( gray_img )
%%%Prewitt Operator Corner Detection.m
%%%时间优化--相邻像素用取差的方法求Harris角点
%%
img = im2uint8(gray_img);

dx = [-1 0 1;-1 0 1;-1 0 1];  %dx：横向Prewitt差分模版
Ix2 = filter2(dx,img).^2;
Iy2 = filter2(dx',img).^2;
Ixy = filter2(dx,img).*filter2(dx',img);

%生成 9*9高斯窗口。窗口越大，探测到的角点越少。
h= fspecial('gaussian',9,2);
A = filter2(h,Ix2);       % 用高斯窗口差分Ix2得到A
B = filter2(h,Iy2);
C = filter2(h,Ixy);
[nrow,ncol] = size(img);
Corner = zeros(nrow,ncol); %zeros用来产生一个全零矩阵，故矩阵Corner用来保存候选角点位置,初值全零，值为1的点是角点

CRF = zeros(nrow,ncol);    % CRF用来保存角点响应函数值,初值全零
CRFmax = 0;                % 图像中角点响应函数的最大值，作阈值之用
m=0.05; %一般取值为0.04~0.06
% 计算CRF
% 工程上常用CRF(i,j) =det(M)/trace(M)计算CRF，那么此时应该将下面第105行的
% 比例系数k设置大一些，k=0.1对采集的这几幅图像来说是一个比较合理的经验值
for i = 1:nrow
    for j = 1:ncol
        M = [A(i,j) C(i,j);
            C(i,j) B(i,j)];
        %角点响应函数
        CRF(i,j) = det(M)-m*(trace(M))^2;
        if CRF(i,j) > CRFmax
            CRFmax = CRF(i,j);
        end;
    end;
end;
% CRFmax
t=0.01;
CRF_threshold = t*CRFmax;
% CRF是正直且很大的时候是角点，CRFR是正直且很小是平坦区域，那么怎么界定很大和很小？
% 这就是t的作用，设置t如果比较大些，可以起到宁可错杀一千不可放过一个的效果
% 下面通过一个3*3的窗口来判断当前位置是否为角点
for i = 2:nrow-1
    for j = 2:ncol-1
        if CRF(i,j) > CRF_threshold &&  CRF(i,j)>max([max(CRF(i-1,j-1:j+1)) CRF(i,j-1) CRF(i,j+1) max(CRF(i+1,j-1:j+1))]);
            Corner(i,j) = 1;
        else % 如果当前位置（i,j）不是角点，则在Corner(i,j)中删除对该候选角点的记录
            Corner(i,j) = 0;
        end;
        
    end;
end;
% disp('角点个数');
% disp(count)
% corner_count = count;

k=0;
Corner_Location=[];
% 矩阵里面，m是行数，图像的H方向，n是列数，图像的W方向,实际对应坐标时则是x=n，y=m.

[Corner_Location(:,1),Corner_Location(:,2)]=find(Corner==1);

end

