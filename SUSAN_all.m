%% SUSAN 1
% close all;
% clc;
% 
% img=imread('lab.gif');
% if (size(img,3) ~= 1)
%     img = rgb2gray(img);
% else
%     img = img;
% end
% imshow(img);
% [m n]=size(img);
% img=double(img);
% 
% t=45;   %模板中心像素灰度和周围灰度差别的阈值，自己设置
% usan=[]; %当前像素和周围在像素差别在t以下的个数
% %这里用了37个像素的模板
% for i=4:m-3         %没有在外围扩展图像，最终图像会缩小
%    for j=4:n-3
%         tmp=img(i-3:i+3,j-3:j+3);   %先构造7*7的模板，49个像素
%         c=0;
%         for p=1:7
%            for q=1:7
%                 if (p-4)^2+(q-4)^2<=12  %在其中筛选，最终模板类似一个圆形
%                    %   usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
%                     if abs(img(i,j)-tmp(p,q))<t  %判断灰度是否相近，t是自己设置的
%                         c=c+1;
%                     end
%                 end
%            end
%         end
%         usan=[usan c];
%    end
% end
% 
% g=2*max(usan)/3; %确定角点提取的数量，值比较高时会提取出边缘，自己设置
% for i=1:length(usan)
%    if usan(i)<g
%        usan(i)=g-usan(i);
%    else
%        usan(i)=0;
%    end
% end
% imgn=reshape(usan,[n-6,m-6])';
% figure;
% imshow(imgn)
% 
% %非极大抑制
% [m n]=size(imgn);
% re=zeros(m,n);
% for i=2:m-1
%    for j=2:n-1
%         if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
%             re(i,j)=1;
%         else
%             re(i,j)=0;
%         end
%    end
% end
% 
% figure;
% imshow(re==1);

%% SUSAN 2
% im=imread('.\Datasets\corner2.gif');
% 
% threshold =0.25;
% 
% % image_out = susan(im,0.25);
% 
% % 功能：实现运用SUNSAN算子进行边缘检测
% % 输入：image_in-输入的待检测的图像
% %       threshold-阈值
% % 输出：image_out-检测边缘出的二值图像
% 
% % 将输入的图像矩阵转换成double型
% d = length(size(im));
% if d==3
%     image=double(rgb2gray(im));
% elseif d==2
%     image=double(im);
% end
% 
% % 建立SUSAN模板
% 
% mask = ([ 0 0 1 1 1 0 0 ;
%     0 1 1 1 1 1 0;
%     1 1 1 1 1 1 1;
%     1 1 1 1 1 1 1;
%     1 1 1 1 1 1 1;
%     0 1 1 1 1 1 0;
%     0 0 1 1 1 0 0]);
% 
% R=zeros(size(image));
% % 定义USAN 区域
% nmax = 3*37/4;
% 
% % 考虑边缘效应，所以扩展了图像
%  [a b]=size(image);
% new=zeros(a+7,b+7);
% [c d]=size(new);
% 
% % 图像边缘扩展了3个0像素
% new(4:c-4,4:d-4)=image;
% 
% for i=4:c-4
% 
%     for j=4:d-4
% 
%         current_image = new(i-3:i+3,j-3:j+3);
%         current_masked_image = mask.*current_image;
% 
%         %   调用susan_threshold函数进行阈值比较处理
% 
%         [a b]=size(image);
%         intensity_center = image(round((a+1)/2),round((b+1)/2));
% 
%         temp1 = (image-intensity_center)/threshold;
%         temp2 = temp1.^6;
%         current_thresholded = exp(-1*temp2);
%         g=sum(current_thresholded(:));
% 
%         if nmax<g
%             R(i,j) = g-nmax;
%         else
%             R(i,j) = 0;
%         end
%     end
% end
% 
% image_out=R(4:c-4,4:d-4);
% imshow(image_out);

%% SUSAN3 角点检测算子的 MATLAB 实现
clc;
clear;
clear all;

[filename,pathname,~]=uigetfile('*.gif','*.jpg' , ' 选择 JPG 格式图片 ' );

if ~ischar(filename)
    
    return
    
end

str=[pathname filename];

pic=imread(str);

if length(size(pic))==3
    
    img=rgb2gray(pic);
else
    img = pic;
    
end

img=double(img);

if isa(img, 'uint8')
    img = img; 
else
    img = im2uint8(img);
end 

[a,b]=size(img);

timg=zeros(a+6,b+6);

[c,d] = size(timg);

timg(4:c-3,4:d-3)=img; %扩展图像边缘3个像素,周边3个像素为0

% img=timg;

t=20; %阈值

USAN=[]; %用于存放 USAN
for i=4:c-3
    for j=4:d-3
        tmp=timg(i-3:i+3,j-3:j+3); % 周围的7X7领域
        cnt=0; %计数专用, 统计 圆形邻域内满足条件的像素点个数
        for p=1:7 
            for q=1:7
                if (p-4)^2+(q-4)^2<=12 %半径一 般在 3~4之间   
                    if abs(timg(i,j)-tmp(p,q))<t
                        cnt=cnt+1;
                    end
                    
                end
                
            end
        end
        USAN=[USAN cnt];
    end   
end

g=1*max(USAN)/2; %给定的阈值

for k=1:length(USAN)
    
    if USAN(k)<g
        
        USAN(k)=g-USAN(k); %反向相减,使得 USAN 取局部最大 
    else 
        USAN(k)=0;
        
    end
    
end

imgn=reshape(USAN,[a,b])'; % USAN向量张成二维图像

% imgn=fliplr(imrotate(imgn,-90)); %调整图像
% loc=[];
% for i=2:a-1
%     for j=2:b-1
%         sq=imgn(i-1:i+1,j-1:j+1);
%         sq=reshape(sq,1,9); 
%         sq=[sq(1:4),sq(6:9)];
%         if imgn(i,j)>sq %局部非极大值抑制  
%             loc=[loc;[j,i]];
%         end     
%     end  
% end
% figure('name','SUSAN corner');
% imshow(pic);%原图
% hold on;
% plot(loc(:,1),loc(:,2),'go');

[M,N] = size(imgn);

re = zeros(M,N);
for i=2:M-1
   for j=2:N-1 
        if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
            re(i,j)=1;
        else
            re(i,j)=0;
        end
   end
end

figure('name','SUSAN corner');
imshow(pic)
hold on;
% [x,y]=find(re==1);
% plot(y,x,'go')
[Corner_Location(:,1),Corner_Location(:,2)]=find(re==1);
plot(Corner_Location(:,2),Corner_Location(:,1),'go')


% figure(6)
% imshowpair(pic,pic,'montage' );
% hold on
% plot(loc(:,1)+size(pic,2),loc(:,2),'*');
% hold off
% figure(6)
% imshowpair(pic,pic,'montage' );
% hold on;
% str1=[repmat('  X:',length(loc)) num2str(loc(:,1)) repmat(', Y:',length(loc)) num2str(loc(:,2))];
% plot(loc(:,1)+size(pic,2),loc(:,2),'*');
% text(loc(:,1)+size(pic,2),loc(:,2),cellstr(str1),'FontSize',5);


%% SUSAN 4 效果不好
% clear;
% clc;
% % 读取图像
% Image=imread('Corner2.gif');
% if (size(Image,3) ~= 1)
%     Image = rgb2gray(Image);
% else
%     Image = Image;
% end
% % 转化为灰度图像
% %Image=rgb2gray(Image);
% % 显示图像
% %imshow(Image);
% % 获取图像高宽（行烈）
% [ImageHeight,ImageWidth]=size(Image);
% % 这一步没太大必要
% %Image=double(Image);
% % 判断灰度相近的阈值
% threshold=45;  
% % 当前像素和窗体内像素差别在t以下的个数，即相似的个数
% usan=[];
% % 计算以像素为中心的窗体内包含的
% % 包含37个像素的圆窗口，面积为12*pi=37，因此是以sqrt（12）为半径的原
% % 没有在外围扩展图像，最终图像会缩小
% for i=4:ImageHeight-3         
%    for j=4:ImageWidth-3 
%         %从原图中截取7*7的区域再在其中挑选圆窗
%         tmp=Image(i-3:i+3,j-3:j+3);  
%         %c表示灰度值相近的程度，越大越相近
%         c=0;
%         for p=1:7
%            for q=1:7
%                %在7*7的区域中选取圆窗包含的像素
%                 if (p-4)^2+(q-4)^2<=12 
%                     %usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
%                     %判断灰度是否相近，t是自己设置的
%                     if abs(Image(i,j)-tmp(p,q))<threshold  
%                         c=c+1;
%                     end
%                 end
%            end
%         end
%         usan=[usan c];
%    end
% end
% %相当于进一步调整阈值，在threshold的基础上进一步减少角点个数
% g=2*max(usan)/3;
% for i=1:length(usan)
%    if usan(i)<g 
%        usan(i)=g-usan(i);
%    else
%        usan(i)=0;
%    end
% end
% % 由于usan是一维的，所以要重新变换为二维，对应图像位置
% imgn=reshape(usan,[ImageWidth-6,ImageHeight-6])';
% %figure;
% %imshow(imgn)
% %非极大抑制
% [m n]=size(imgn);
% re=zeros(m,n);
% for i=2:m-1
%    for j=2:n-1 
%         if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
%             re(i,j)=1;
%         else
%             re(i,j)=0;
%         end
%    end
% end
% figure;
% imshow(Image)
% hold on;
% [x,y]=find(re==1);
% plot(y,x,'*')