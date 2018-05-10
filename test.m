% img = rgb2gray(im2double(imread('corner2.gif')));
% img = im2double(imread('corner2.gif'));

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
newfilename = filename(1:end-4); % 用于动态保存文件名

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

% img = im2double(img);
% [Corner_SUSAN,Corner] = SUSAN(img);
% length(Corner_SUSAN)
% [Corner_SUSAN_test] = SUSAN2_test(img,15,0.8);
[Corner_Harris_test] = Harris_test(img);
length(Corner_Harris_test)
[Corner_Harris] = Harris(img);
length(Corner_Harris)

% function [ Corner_Location ] = SUSAN2_test(img,t,cnt)
% t：模板中心像素的灰度值与模板内其他像素灰度值的差，即灰度相似度
% c：若某个像素点的USAN值小于某一特定阈值，则该点被认为是初始角点，其中，g可以设定为USAN的最大面积的一半，此时c=0.5。值比较高时会提取出边缘。

% figure('Name','SUSAN')
% imshow(img),hold on
% plot(Corner_SUSAN(:,2),Corner_SUSAN(:,1),'go')

% figure('Name','SUSAN_test')
% imshow(img),hold on
% plot(Corner_SUSAN_test(:,2),Corner_SUSAN_test(:,1),'go')
% 
figure('Name','harris_test')
imshow(img),hold on
plot(Corner_Harris_test(:,2),Corner_Harris_test(:,1),'go')

figure('Name','harris')
imshow(img),hold on
plot(Corner_Harris(:,2),Corner_Harris(:,1),'go')