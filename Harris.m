%Source Code: http://blog.csdn.net/anymake_ren/article/details/21298807

function [Corner_Location, CRF] = Harris( gray_img )
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

%参数t:点(i,j)八邻域的“相似度”参数，只有中心点与邻域其他八个点的像素值之差在
%（-t,+t）之间，才确认它们为相似点，相似点不在候选角点之列
t=20;

%我并没有全部检测图像每个点，而是除去了边界上boundary个像素，也就是从第8行第8列开始遍历。
%因为我们感兴趣的角点并不出现在边界上
%个人觉得这一部分是的主要目的是找出可能是角点的点，缩小范围，加快运算速度。
%具体思想是如果中心点（i,j）周围8个点中有7、8个点灰度值与之相似，那么该中心点应该处于平坦区域，不可能为角点，
%如果中心点（i,j）周围只有1个点或者没有点与之相似，那么该中心点也不可能为角点。
boundary=2;
for i=boundary:nrow-boundary+1
    for j=boundary:ncol-boundary+1
        nlike=0; %相似点个数
        if img(i-1,j-1)>img(i,j)-t && img(i-1,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i-1,j)>img(i,j)-t && img(i-1,j)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i-1,j+1)>img(i,j)-t && img(i-1,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i,j-1)>img(i,j)-t && img(i,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i,j+1)>img(i,j)-t && img(i,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j-1)>img(i,j)-t && img(i+1,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j)>img(i,j)-t && img(i+1,j)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j+1)>img(i,j)-t && img(i+1,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if nlike>=2 && nlike<=6
            Corner(i,j)=1;%如果周围有2~6个相似点，那(i,j)就是角点
        end;
    end;
end;
CRF = zeros(nrow,ncol);    % CRF用来保存角点响应函数值,初值全零
CRFmax = 0;                % 图像中角点响应函数的最大值，作阈值之用
m=0.05; %一般取值为0.04~0.06
% 计算CRF
% 工程上常用CRF(i,j) =det(M)/trace(M)计算CRF，那么此时应该将下面第105行的
% 比例系数k设置大一些，k=0.1对采集的这几幅图像来说是一个比较合理的经验值
for i = boundary:nrow-boundary+1
    for j = boundary:ncol-boundary+1
        if Corner(i,j)==1  %只关注候选点
            M = [A(i,j) C(i,j);
                C(i,j) B(i,j)];
            %角点响应函数
            CRF(i,j) = det(M)-m*(trace(M))^2;
            if CRF(i,j) > CRFmax
                CRFmax = CRF(i,j);
            end;
        end
    end;
end;
% CRFmax
t=0.01; 
CRF_threshold = t*CRFmax;
% CRF是正直且很大的时候是角点，CRFR是正直且很小是平坦区域，那么怎么界定很大和很小？
% 这就是t的作用，设置t如果比较大些，可以起到宁可错杀一千不可放过一个的效果
% 下面通过一个3*3的窗口来判断当前位置是否为角点
for i = boundary:nrow-boundary+1
    for j = boundary:ncol-boundary+1
        if Corner(i,j)==1  % 只关注候选点的八邻域(非极大值抑制，3*3窗口)
            if CRF(i,j) > CRF_threshold && CRF(i,j) >CRF(i-1,j-1) ......%?????为什么要CRF(i,j) > t*CRFmax啊？求大神告知
                    && CRF(i,j) > CRF(i-1,j) && CRF(i,j) > CRF(i-1,j+1) ......
                    && CRF(i,j) > CRF(i,j-1) && CRF(i,j) > CRF(i,j+1) ......
                    && CRF(i,j) > CRF(i+1,j-1) && CRF(i,j) > CRF(i+1,j)......
                    && CRF(i,j) > CRF(i+1,j+1)
%                 count=count+1;%这个是角点，count加1
%                 CRF(i,j)
%                 t*CRFmax
            else % 如果当前位置（i,j）不是角点，则在Corner(i,j)中删除对该候选角点的记录
                Corner(i,j) = 0;
            end;
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

% %去除密集角点，显示平均值
% k=0;
% for i=boundary:nrow-boundary+1
%     for j=boundary:ncol-boundary+1
%         column_ave=0;
%         row_ave=0;
%         m=0;
%         if Corner(i,j)==1
%             for x=i-3:i+3  %7*7邻域
%                 for y=j-3:j+3
%                     if Corner(x,y)==1
%                         % 用算术平均数作为角点坐标，如果改用几何平均数求点的平均坐标，对角点的提取意义不大
%                         row_ave=row_ave+x;
%                         column_ave=column_ave+y;
%                         m=m+1;
%
%                     end
%                 end
%             end
%         end
%         if m>0 %周围不止一个角点
%             k=k+1;
%             Corner_Location(k,:) = [column_ave/m,row_ave/m];
%         end
%     end;
% end;

end

