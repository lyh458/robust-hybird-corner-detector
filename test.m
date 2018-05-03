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


