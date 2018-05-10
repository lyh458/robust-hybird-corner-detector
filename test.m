% img = rgb2gray(im2double(imread('corner2.gif')));
% img = im2double(imread('corner2.gif'));

%% ��������
close all;
clear all;
clear;
clc;
%% ����ͼ��
[filename, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'}, 'ѡ��ͼƬ');

%û��ͼ��
if filename == 0
    return;
end
newfilename = filename(1:end-4); % ���ڶ�̬�����ļ���

imgsrc = imread([pathname, filename]);
% imgsrc = checkerboard;
% [y, x, dim] = size(imgsrc);

% �ж�ͼ���Ƿ�Ϊ�Ҷ�ͼ��
if (size(imgsrc,3) ~= 1)
    gray_img = rgb2gray(imgsrc);
else
    gray_img = imgsrc;
end

%% ͼ���˲���ƽ��
sigma = 1;
gausFilter = fspecial('gaussian', [3,3], sigma);
img= imfilter(gray_img, gausFilter, 'replicate');

if ~isempty(strfind(filename,'demo'))
    level = graythresh(img);%%matlab �Դ����Զ�ȷ����ֵ�ķ�������򷨣���䷽��
    img = im2bw(img,level);%%�õõ�����ֱֵ�Ӷ�ͼ����ж�ֵ��
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
% t��ģ���������صĻҶ�ֵ��ģ�����������ػҶ�ֵ�Ĳ���Ҷ����ƶ�
% c����ĳ�����ص��USANֵС��ĳһ�ض���ֵ����õ㱻��Ϊ�ǳ�ʼ�ǵ㣬���У�g�����趨ΪUSAN����������һ�룬��ʱc=0.5��ֵ�Ƚϸ�ʱ����ȡ����Ե��

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