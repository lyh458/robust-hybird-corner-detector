%% This is the main file of the project with method 2.
% Author: Yihui Li
% Email: liyihui.ing@qq.com
%% 清理数据
close all;
clear all;
clear;
clc;
%% 读进图像
[filename, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'}, '选择图片');

%没有图像
if filename == 0
    return;
end
newfilename = filename(1:end-4); % 用于后面实验结果动态保存文件名

imgsrc = imread([pathname, filename]);
% imgsrc = checkerboard;
% [y, x, dim] = size(imgsrc);

% 判断图像是否为灰度图像
if (size(imgsrc,3) ~= 1)
    gray_img = rgb2gray(imgsrc);
else
    gray_img = imgsrc;
end

%% 图像滤波、平滑
sigma = 1;
gausFilter = fspecial('gaussian', [3,3], sigma);
img= imfilter(gray_img, gausFilter, 'replicate');

if ~isempty(strfind(filename,'demo'))
    level = graythresh(img);%%matlab 自带的自动确定阈值的方法，大津法，类间方差
    img = im2bw(img,level);%%用得到的阈值直接对图像进行二值化
end

if isa(img, 'uint8')
    img = img; 
else
    img = im2uint8(img);
end  

%% Matlab自带的边缘检测
% bw=graythresh(img);
% bi=im2bw(img,bw);
% ed = edge(bi, 'canny', 0.5);

%% 调用各个角点检测算法求角点
[Corner_harris,CRF] = Harris(img,0.0001);

% Corner_harris = detectHarrisFeatures(gray_img);
% Matlab official Harris detector
corner_count_harris = length(Corner_harris);

% [Corner_SUSAN] = SUSAN(img);
% corner_count_SUSAN = length(Corner_SUSAN);

Corner_RCSS = RCSS(img, []);
corner_count_RCSS = length(Corner_RCSS);

% global Corner_harris_pure;
% global Corner_RCSS_pure;
% 
% global Corner_harris_samewithintol;
% global Corner_RCSS_samewithintol;
% 
% global Corner_harris_diff;
% global Corner_RCSS_diff;

Corner_HRS = HRS(img, Corner_harris, Corner_RCSS, Corner_SUSAN, CRF);
corner_count_HRS = length(Corner_HRS);

set(gcf,'color','white','paperpositionmode','auto');

%% Harris_unofficial角点检测并在原图像显示角点
figure('Name','harris corner')
% subplot(3,2,1);
imshow(imgsrc);%原图
hold on;
% toc(t1)
disp('Harris角点个数_unofficial');
disp(corner_count_harris);
%所有角点显示
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
%% 显示坐标
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner_harris(:, 2), Corner_harris(:, 1), 'go');
saveas(gcf,['.\experiments\',newfilename,'_harris.eps'],'psc2');
% text(Corner_harris(:, 2),Corner_harris(:, 1),cellstr(str1),'FontSize',5);

% if(~isempty(Corner_harris_diff))
%     plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'ro');
% end

% subplot(3,2,2);
% imshow(imgsrc);%原图
% hold on;
% plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'g.');

%% SUNSAN1角点检测并在原图像显示角点
% subplot(3,2,2);
figure('name','SUSAN corner');
imshow(imgsrc);%原图
hold on;
% toc(t1)
disp('SUNSAN角点个数');
disp(corner_count_SUSAN);
%所有角点显示
plot(Corner_SUSAN(:,2),Corner_SUSAN(:,1),'go');
saveas(gcf,['.\experiments\',newfilename,'_SUSAN.eps'],'psc2');

%% RCSS角点检测并在原图像显示角点
figure('Name','RCSS corner')
% subplot(3,2,2);
disp('RCSS角点个数');
disp(corner_count_RCSS);
imshow(imgsrc);
hold on;
% plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'g.');
%% 显示坐标
% str2=[repmat('  X:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 2)) repmat(', Y:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 1))];
plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'go');
saveas(gcf,['.\experiments\',newfilename,'_RCSS.eps'],'psc2');
% text(Corner_RCSS(:, 2),Corner_RCSS(:, 1),cellstr(str2),'FontSize',5);
% plot(Corner_RCSS_diff(:, 2), Corner_RCSS_diff(:, 1), 'ro');
% if(~isempty(Corner_RCSS_diff_final))
%     plot(Corner_RCSS_diff_final(:,2),Corner_RCSS_diff_final(:,1),'ro');
% end

%% harris_official角点检测并在原图像显示角点
% subplot(3,2,4);
% % Corner_harris_official = detectHarrisFeatures(gray_img);
% % Corner_harris_official = detectHarrisFeatures(gray_img,'MinQuality',0.1,'FilterSize',5,'ROI',[8,8,size(gray_img,2)-8,size(gray_img,1)-8]);
% disp('Harris_official角点个数');
% disp(length(Corner_harris_official));
% imshow(imgsrc);
% hold on;
% plot(Corner_harris_official.Location(:, 1),Corner_harris_official.Location(:, 2),'g.');
% plot(Corner_harris_official.selectStrongest(50));
%% points = detectHarrisFeatures(I,Name,Value)
% Name-Value Pair Arguments
% Specify optional comma-separated pairs of Name,Value arguments. Name is the argument name and Value is the corresponding value. Name must appear inside single quotes (' '). You can specify several name and value pair arguments in any order as Name1,Value1,...,NameN,ValueN.
%
% Example: 'MinQuality','0.01','ROI', [50,150,100,200] specifies that the detector must use a 1% minimum accepted quality of corners within the designated region of interest. This region of interest is located at x=50, y=150. The ROI has a width of 100 pixels and a height of 200 pixels.
% 'MinQuality' — Minimum accepted quality of corners
% 0.01 (default)
% Minimum accepted quality of corners, specified as the comma-separated pair consisting of 'MinQuality' and a scalar value in the range [0,1].
%
% The minimum accepted quality of corners represents a fraction of the maximum corner metric value in the image. Larger values can be used to remove erroneous corners.
%
% Example: 'MinQuality', 0.01
%
% Data Types: single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64
%
% 'FilterSize' — Gaussian filter dimension
% 5 (default)
% Gaussian filter dimension, specified as the comma-separated pair consisting of 'FilterSize' and an odd integer value in the range [3, min(size(I))].
%
% The Gaussian filter smooths the gradient of the input image.
%
% The function uses the FilterSize value to calculate the filter's dimensions, FilterSize-by-FilterSize. It also defines the standard deviation of the Gaussian filter as FilterSize/3.
%
% Example: 'FilterSize', 5
%
% Data Types: single | double | int8 | int16 | int32 | int64 | uint8 | uint16 | uint32 | uint64
%
% 'ROI' — Rectangular region
% [1 1 size(I,2) size(I,1)] (default) | vector
% Rectangular region for corner detection, specified as a comma-separated pair consisting of 'ROI' and a vector of the format [x y width height]. The first two integer values [x y] represent the location of the upper-left corner of the region of interest. The last two integer values represent the width and height.
%
% Example: 'ROI', [50,150,100,200]

%% Eigenvalue Algorithm角点检测并在原图像显示角点
% subplot(3,2,5);
% Corner_MiniEigen = detectMinEigenFeatures(gray_img);
% % Corner_harris_official = detectMiniEigen(gray_img,'MinQuality',0.1,'FilterSize',5,'ROI',[8,8,size(gray_img,2)-8,size(gray_img,1)-8]);
% disp('MinEigen角点个数');
% disp(length(Corner_MiniEigen));
% imshow(imgsrc);
% hold on;
% plot(Corner_MiniEigen.Location(:, 1),Corner_MiniEigen.Location(:, 2),'g.');
% plot(Corner_MiniEigen.selectStrongest(50));

%% 显示边缘图像
% subplot(3,2,4);
% imshow(ed);%Matlab自带边缘检测


%% 计算
figure('Name','HRS corner')
% subplot(3,2,3);
imshow(imgsrc);
disp('HRS角点个数');
disp(corner_count_HRS);
hold on;
%% 显示坐标
% str3=[repmat('  X:',length(Corner_final),1) num2str(Corner_final(:, 2)) repmat(', Y:',length(Corner_final),1) num2str(Corner_final(:, 1))];
plot(Corner_HRS(:,2),Corner_HRS(:,1),'go');
% text(Corner_final(:, 2),Corner_final(:, 1),cellstr(str3),'FontSize',5);
saveas(gcf,['.\experiments\',newfilename,'_HRS.eps'],'psc2');

%% 
% figure('Name','test')
% % subplot(3,2,4);
% imshow(imgsrc);%原图
% hold on;
% plot(Corner_diff_temp(:,2),Corner_diff_temp(:,1),'g.');
% plot(Corner_diff_final(:,2),Corner_diff_final(:,1),'ro');


% plot(Corner_final(:,2),Corner_final(:,1),'g.');
% for k = 1:length(ia1)
%     %     M_RCSS2harris=[Corner_RCSS(ia1{k},1),Corner_RCSS(ia1{k},2)];
%     plot(Corner_RCSS(ia1{k},1),Corner_RCSS(ia1{k},2),'g.');
% end
% 找出Harris在RCSS角点中的相同部分；
% [C2,ia12] = ismembertol(Corner_RCSS,Corner_harris,tol,'ByRows',true,'OutputAllIndices',true,'DataScale',DS);
% for k = 1:length(ia2)
%     M_harris2RCSS=[Corner_harris(ia2{k},1),Corner_harris(ia2{k},2)];
% end

%% localization Error

%% Average Repeatability