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

%% Matlab自带的边缘检测
% bw=graythresh(img);
% bi=im2bw(img,bw);
% ed = edge(bi, 'canny', 0.5);

%% 调用各个角点检测算法求角点
[Corner_harris, corner_count_harris, CRFmax] = Harris_corner_detect(img);

[Corner_SUSAN, corner_count_SUSAN] = SUSAN_corner_detect(img);

Corner_RCSS_temp = RCSS(img, []);
Corner_RCSS = [Corner_RCSS_temp(:,2),Corner_RCSS_temp(:,1)];
corner_count_RCSS = length(Corner_RCSS);

% Corner_harris_official = detectHarrisFeatures(gray_img);

%% 去除重复角点
%利用uniquetol（容差范围内的唯一值）
DS = [1 1];
tol = 3;
m=0;
Corner_harris_pure = [];
Corner_RCSS_pure = [];

[C_harris,IA_harris]=uniquetol(Corner_harris, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
for m = 1:length(IA_harris)
    M_temp = [];
    if(length(IA_harris{m})==1)
        Corner_harris_pure(m,1) = Corner_harris(IA_harris{m},1);
        Corner_harris_pure(m,2) = Corner_harris(IA_harris{m},2);
    else
        Corner_harris_pure(m,1) = round(mean(Corner_harris(IA_harris{m},1)));
        Corner_harris_pure(m,2) = round(mean(Corner_harris(IA_harris{m},2)));
    end
end

[C_RCSS,IA_RCSS]=uniquetol(Corner_RCSS, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);

for m = 1:length(IA_RCSS)
     M_temp = [];
    W2 = [];
    l = length(IA_RCSS{m});
    loc_mat = [];
    if(l==1)
        Corner_RCSS_pure(m,1) = Corner_RCSS(IA_RCSS{m},1);
        Corner_RCSS_pure(m,2) = Corner_RCSS(IA_RCSS{m},2);
    else
        loc_mat = [Corner_RCSS(IA_RCSS{m}(:),1),Corner_RCSS(IA_RCSS{m}(:),2)]; %[l 2]
        W2 = gray_value_weight(gray_img,loc_mat); %[1 l]
        loc_temp = W2*loc_mat;
        Corner_RCSS_pure(m,1) = round(loc_temp(1,1)); %W2*loc_mat(1,1)得到[1 2]的矩阵
        Corner_RCSS_pure(m,2) = round(loc_temp(1,2));
    
%     M_temp = [];
%     if(length(IA_RCSS{m})==1)
%         Corner_RCSS_pure(m,1) = Corner_RCSS(IA_RCSS{m},1);
%         Corner_RCSS_pure(m,2) = Corner_RCSS(IA_RCSS{m},2);
%     else
%         Corner_RCSS_pure(m,1) = round(mean(Corner_RCSS(IA_RCSS{m},1)));
%         Corner_RCSS_pure(m,2) = round(mean(Corner_RCSS(IA_RCSS{m},2)));

    end
end

%% 角点匹配
% ismembertol(A,B)找出RCSS在Harris角点中的相同部分；
% LIR：返回与Corner_RCSS_pure相同行数的*1的逻辑矩阵，当Corner_RCSS_pure中元素能在Corner_harris_pure中找到容差tol范围内的元素时，LIR对应行赋值为1，否则为0；
% LocH：返回与Corner_RCSS_pure相同行数的*1的元胞矩阵，
%   当Corner_RCSS_pure中元素a能在Corner_harris_pure_pure中找到容差tol范围内的元素时，LocH对应行的值为Corner_harris中所有与a符合容差tol范围的值的索引；否则为0
[LIR,LocH] = ismembertol(Corner_harris_pure,Corner_RCSS_pure,tol,'ByRows',true,'OutputAllIndices',true,'DataScale',DS);

i=0;
j=0;
Corner_harris_diff = [];
Corner_RCSS_diff = [];
Corner_RCSS_samewithintol = [];
Corner_final = [];
% lambda_RCSS_samewithintol = []; % Harris算法中矩阵M的特征值λ1，λ2
% lambda_harris_pure = [];
for k = 1:length(LocH)
    % 找出Corner_harris_pure中孤立的角点（与Corner_RCSS_pure没有交集的点）
    if(LocH{k} == 0)
        i=i+1;
        Corner_harris_diff(i,1)=Corner_harris_pure(k,1);
        Corner_harris_diff(i,2)=Corner_harris_pure(k,2);
        % 找出Corner_harris_pure中与Corner_RCSS_pure存在交集的角点
        Corner_harris_samewithintol = setdiff(Corner_harris_pure, Corner_harris_diff, 'rows');
        % 找出Corner_RCSS_pure中与Corner_harris_pure存在交集的角点
    else
        for l=1:length(LocH{k})
            j=j+1;
            Corner_RCSS_samewithintol(j,1)=Corner_RCSS_pure(LocH{k}(l),1);
            Corner_RCSS_samewithintol(j,2)=Corner_RCSS_pure(LocH{k}(l),2);
            % 匹配角点响应函数值归一化，作为位置权重
            [CRF1,D1] = Corner_response_func(gray_img, Corner_RCSS_samewithintol(j,1),Corner_RCSS_samewithintol(j,2));
            [CRF2,D2] = Corner_response_func(gray_img, Corner_harris_pure(k,1),Corner_harris_pure(k,2));
%             lambda_RCSS_samewithintol = [lambda_RCSS_samewithintol;D1(1,1),D1(2,2)];
%             lambda_harris_pure = [lambda_harris_pure;D2(1,1),D2(2,2)];
            CRF(j,1) = CRF1;
            CRF(j,2) = CRF2;
            CRF_harris(j,1) = CRF1;
            CRF_RCSS(j,1) = CRF2;
            if(CRF1<0)
                w1 = 0;
                w2 = 1;
            else
                w1 = CRF_weight(CRF1,CRF2);
                w2 = CRF_weight(CRF2,CRF1);
            end
            Corner_temp(j,1) = round(w1*Corner_RCSS_samewithintol(j,1)+w2*Corner_harris_pure(k,1));
            Corner_temp(j,2) = round(w1*Corner_RCSS_samewithintol(j,2)+w2*Corner_harris_pure(k,2));
            W(j,1) = w1;
            W(j,2) = w2;
        end
    end
end

% 角点交集中可能存在相同的点，清除之
Corner_RCSS_samewithintol_pure = [];
[C_s,IA_s,IC_s]=uniquetol(Corner_RCSS_samewithintol,'ByRows',true);
Corner_RCSS_samewithintol_pure = C_s;
% 找出Corner_RCSS_pure中孤立的角点（与Corner_harris_pure没有交集的点）
Corner_RCSS_diff = setdiff(Corner_RCSS_pure, Corner_RCSS_samewithintol_pure, 'rows');

CRF_RCSS_diff = [];
Corner_RCSS_diff_final = [];
CRF3 = 0;
t = 0.001;
CRF_threshold = t*CRFmax;
% CRF_threshold = 0;
% lambda_RCSS_diff = [];
for l = 1:length(Corner_RCSS_diff)
    [CRF3,D3] = Corner_response_func(gray_img, Corner_RCSS_diff(l,1),Corner_RCSS_diff(l,2));
%     lambda_RCSS_diff = [lambda_RCSS_diff;D3(1,1),D3(2,2)];
    CRF_RCSS_diff = [CRF_RCSS_diff; CRF3];
    if CRF3 > CRF_threshold
        Corner_RCSS_diff_final = [Corner_RCSS_diff_final; Corner_RCSS_diff(l,1),Corner_RCSS_diff(l,2)];
    end
end

% 加权后Corner_diff的并集
if (~isempty(Corner_RCSS_diff)) && (~isempty(Corner_harris_diff))
    Corner_diff_temp = union(Corner_RCSS_diff,Corner_harris_diff,'rows');
else
    Corner_diff_temp = [Corner_RCSS_diff;Corner_harris_diff];
end


% USAN清除非角点,得到最终角点
% Corner_final = False_corner_delete(gray_img, Corner_temp1);
tol1 = 7;
[LIR1,LocH1] = ismembertol(Corner_diff_temp,Corner_SUSAN,tol,'ByRows',true,'OutputAllIndices',true,'DataScale',DS);
LIR1_temp = find(LIR1);
Corner_diff_final = [Corner_diff_temp(LIR1_temp,1),Corner_diff_temp(LIR1_temp,2)];
if (~isempty(Corner_temp)) && (~isempty(Corner_diff_final))
    Corner_temp2 = union(Corner_temp,Corner_diff_final,'rows');
else
    Corner_temp2 =[Corner_temp; Corner_diff_final];
end

% Corner_final = Corner_temp2;
%% 非极大值抑制方法清除冗余角点
tol2 = 6;
[C_final,IA_final]=uniquetol(Corner_temp2, tol2, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
for m = 1:length(IA_final)
    M_temp = [];
    W2 = [];
    l = length(IA_final{m});
    loc_mat = [];
    if(l==1)
        Corner_final(m,1) = Corner_temp2(IA_final{m},1);
        Corner_final(m,2) = Corner_temp2(IA_final{m},2);
    else
        loc_mat = [Corner_temp2(IA_final{m}(:),1),Corner_temp2(IA_final{m}(:),2)]; %[l 2]
        W2 = gray_value_weight(gray_img,loc_mat); %[1 l]
        loc_temp = W2*loc_mat;
        Corner_final(m,1) = round(loc_temp(1,1)); %W2*loc_mat(1,1)得到[1 2]的矩阵
        Corner_final(m,2) = round(loc_temp(1,2));
%         Corner_final(m,1) = round(mean(Corner_temp2(IA_final{m},1)));
%         Corner_final(m,2) = round(mean(Corner_temp2(IA_final{m},2)));
    end
end

corner_count_HRS = length(Corner_final);

% for l=1:length(Corner_temp2)
%     i=Corner_temp2(l,1);
%     j=Corner_temp2(l,2);
%     x=i-tol1:i+tol1;
%     y=j-tol1:j+tol1;
%         if gray_img(i,j)>= max(gray_img(x,y)) && ((i-x)*(j-y)~=0)
%            
%         end
%     end
% end
%% 计算diff角点领域内的响应值
% % CRF_diff = {};
% CRF_diff = [];
% CRF_diff_temp =[];
% for l =1:length(Corner_diff_temp)
%     CRF_diff_temp =[];
%     i=Corner_diff_temp(l,1);
%     j=Corner_diff_temp(l,2);
%     for r=i-tol:i+tol
%         for c=j-tol:j+tol
%             CRF_diff_temp = [CRF_diff_temp;Corner_response_func(gray_img,r,c)];
%         end
%     end
%     CRF_diff = [CRF_diff, CRF_diff_temp];
% %     CRF_diff_temp = reshape(CRF_diff_temp,[2*tol+1,2*tol+1]);
% %     CRF_diff_temp = CRF_diff_temp';
% %     CRF_diff{l} = CRF_diff_temp;
% end

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
plot(Corner_final(:,2),Corner_final(:,1),'go');
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