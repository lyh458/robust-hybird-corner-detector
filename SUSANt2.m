function [ Corner_Location, corner_count ] = SUSAN_corner_detect2( gray_img )
% clear all;
% close all;
% clc;
%
% img=imread('i.jpg');
% img=rgb2gray(img);
% imshow(img);
[nrow,ncol]=size(gray_img);
img=double(gray_img);

t=45;   %模板中心像素灰度和周围灰度差别的阈值，自己设置
usan=[]; %当前像素和周围在像素差别在t以下的个数
%这里用了37个像素的模板
for i=4:nrow-3         %没有在外围扩展图像，最终图像会缩小
    for j=4:ncol-3
        tmp=img(i-3:i+3,j-3:j+3);   %先构造7*7的模板，49个像素
        c=0;
        for p=1:7
            for q=1:7
                if (p-4)^2+(q-4)^2<=12  %在其中筛选，最终模板类似一个圆形
                    %   usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
                    if abs(img(i,j)-tmp(p,q))<t  %判断灰度是否相近，t是自己设置的
                        c=c+1;
                    end
                end
            end
        end
        usan=[usan c];
    end
end

g=2*max(usan)/3; %确定角点提取的数量，值比较高时会提取出边缘，自己设置
for i=1:length(usan)
    if usan(i)<g
        usan(i)=g-usan(i);
    else
        usan(i)=0;
    end
end
imgn=reshape(usan,[ncol-6,nrow-6])';
% figure;
% imshow(imgn)

%非极大抑制
[nrow,ncol]=size(imgn);
Corner=zeros(nrow,ncol);
count=0;
for i=2:nrow-1
    for j=2:ncol-1
        if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
            Corner(i,j)=1;
            count=count+1;
        else
            Corner(i,j)=0;
        end
    end
end

% figure;
% imshow(re==1);
corner_count=count;

k=0;
Corner_Location=[];
for i=1:nrow
    for j=1:ncol
        if Corner(i,j)==1
            k=k+1;
            Corner_Location(k,:)=[i,j];
        end
    end
end

% %去除密集角点，显示平均值
% k=0;
% boundary = 8;
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


