function [ Corner_final ] = False_corner_delete( gray_img, Corner_ori)
% %UNTITLED2 Summary of this function goes here
% %   Detailed explanation goes here
% Corner = [];
% img = im2double(gray_img);
% usan = [];
% t=20;
% for k=1:length(Corner_ori)
%     i = Corner_ori(k,1);
%     j = Corner_ori(k,2);
%     tmp = img(i-3:i+3,j-3:j+3);
%     c = 0;
%     for p=1:7
%         for q=1:7
%             if (p-4)^2+(q-4)^2<=12  %在其中筛选，最终模板类似一个圆形
%                 %   usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
%                 if abs(img(i,j)-tmp(p,q))<t;  %判断灰度是否相近，t是自己设置的
%                     c=c+1;
%                 end
%             end
%         end
%     end
%     usan = [usan;c]
% end
% % usan
% g=1*max(usan)/2; %确定角点提取的数量，值比较高时会提取出边缘，自己设置
% for i=1:length(usan)
%     if usan(i)<g
%         usan(i)=g-usan(i);
%     else
%         usan(i)=0;
%     end
% end
%
% j = 0;
% for i = 1:length(usan)
%     if(usan(i)>0)
%         j = j+1;
%         Corner(j,1) = Corner_ori(i,1);
%         Corner(j,2) = Corner_ori(i,2);
%     end
% end
img = im2double(gray_img);
maskSz = [7 7];
fun = @(img) susanFun(img);
Corner = nlfilter(img,maskSz,fun);
i = 0;
for j = 1:length(Corner_ori)
    
    if(Corner(Corner_ori(j,1),Corner_ori(j,2))~=0)
        i = i+1;
        Corner_final(i,1) = Corner_ori(j,1);
        Corner_final(i,2) = Corner_ori(j,2);
    end
end

% [r,c] = find(Corner);

% k=0;
% Corner_Location = [r,c];
% corner_count = length(find(Corner));

    function res = susanFun(img)
        % SUSANFUN  Determine if the center of the image patch IMG
        %	is corner(res = 1) or not(res = 0)
        
        
        mask = [...
            0 0 1 1 1 0 0
            0 1 1 1 1 1 0
            1 1 1 1 1 1 1
            1 1 1 1 1 1 1
            1 1 1 1 1 1 1
            0 1 1 1 1 1 0
            0 0 1 1 1 0 0];
        
        % uses 2 thresholds to distinguish corners from edges
        thGeo = (nnz(mask)-1)*.2; % Number of nonzero matrix elements.
        thGeo1 = (nnz(mask)-1)*.4;
        thGeo2 = (nnz(mask)-1)*.4;
        thT = .06;
        thT1 = .03;
        
        sz = size(img,1);
        usan = ones(sz)*img(round(sz/2),round(sz/2));
        
        similar = (abs(usan-img)<thT);
        similar = similar.*mask;
        res = sum(similar(:));
        if res < thGeo
            dark = nnz((img-usan<-thT1).*mask);
            bright = nnz((img-usan>thT1).*mask);
            res = min(dark,bright)<thGeo1 && max(dark,bright)>thGeo2;
            
        else
            res = 0;
        end
        
    end
end

