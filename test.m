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

corners = RCSS(img, []);

[Corner_harris, corner_count_harris, CRFmax] = Harris_corner_detect( img);

Corner_harris_official = detectHarrisFeatures(img);

[Corner_SUSAN, corner_count_SUSAN] = SUSAN_corner_detect( img);

Corner_RCSS_temp = RCSS(img, []);
Corner_RCSS = [Corner_RCSS_temp(:,2),Corner_RCSS_temp(:,1)];
corner_count_RCSS = length(Corner_RCSS);




imshow(img);
hold on;
scatter(corners(:, 1), corners(:, 2), 'MarkerEdgeColor',[0 1 0]);


