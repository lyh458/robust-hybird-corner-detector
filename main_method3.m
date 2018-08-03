%% This is the main file of the project with method 3. 
    % The intension is to use a SCL which only defined by Harris matched
    % corners.
% Author: Yihui Li
% Email: liyihui.ing@qq.com
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
newfilename = filename(1:end-4); % ���ں���ʵ������̬�����ļ���

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

%% Matlab�Դ��ı�Ե���
% bw=graythresh(img);
% bi=im2bw(img,bw);
% ed = edge(bi, 'canny', 0.5);

%% ���ø����ǵ����㷨��ǵ�
[Corner_harris,Harris_marked_img,CRF] = Harris(img,0.0001);

% Corner_harris = detectHarrisFeatures(gray_img);
% Matlab official Harris detector
corner_count_harris = length(Corner_harris);

% [Corner_SUSAN] = SUSAN(img);
% corner_count_SUSAN = length(Corner_SUSAN);

Corner_RCSS = RCSS(img,[]);
%   Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inputImage
% 	width
% 	height
% 	edParam1
% 	edParam2
% 	edParam3
% 	edParam4
% 	lowThr
% 	highThr
% 	lineFitThr
% 	maxLineLen
% 	angleThr
% 	gradMagThresh
% 	TJuncs

corner_count_RCSS = length(Corner_RCSS);

[Corner_CSS,CSS_marked_img,Angle] = CSS(img,[],[],[],[],[],1,[]);
%       Syntax :    
%       [cout,marked_img]=CSS(I,C,T_angle,sig,H,L,Endpiont,Gap_size)
%
%       Input :
%       I -  the input image, it could be gray, color or binary image. If I is
%           empty([]), input image can be get from a open file dialog box.
%       C -  denotes the minimum ratio of major axis to minor axis of an ellipse, 
%           whose vertex could be detected as a corner by proposed detector.  
%           The default value is 1.5.
%       T_angle -  denotes the maximum obtuse angle that a corner can have when 
%           it is detected as a true corner, default value is 162.
%       Sig -  denotes the standard deviation of the Gaussian filter when
%           computeing curvature. The default sig is 3.
%       H,L -  high and low threshold of Canny edge detector. The default value
%           is 0.35 and 0.
%       Endpoint -  a flag to control whether add the end points of a curve
%           as corner, 1 means Yes and 0 means No. The default value is 1.
%       Gap_size -  a paremeter use to fill the gaps in the contours, the gap
%           not more than gap_size were filled in this stage. The default 
%           Gap_size is 1 pixels.
%
%       Output :
%       cout -  a position pair list of detected corners in the input image.
%       marked_image -  image with detected corner marked.
%       Angle - The angle of corner except end points
%
%       Examples
%       -------
%       I = imread('alumgrns.tif');
%       cout = corner(I,[],[],[],0.2);
%
%       [cout, marked_image] = corner;
%
%       cout = corner([],1.6,155);

corner_count_CSS = length(Corner_CSS);

% global Corner_harris_pure;
% global Corner_RCSS_pure;
% 
% global Corner_harris_samewithintol;
% global Corner_RCSS_samewithintol;
% 
% global Corner_harris_diff;
% global Corner_RCSS_diff;

% Corner_HRS = HRS(img, Corner_harris, Corner_RCSS, Corner_SUSAN, CRF);
% corner_count_HRS = length(Corner_HRS);


%% Corner match
img_append = appendimages(CSS_marked_img,Harris_marked_img);
figure('Position', [0 0 size(img_append,2) size(img_append,1)]);
%figure(3);
colormap('gray');
imagesc(img_append);
hold on;

% Euclidean distance match and show
[Corner_CSS_matched,Corner_Harris_matched]=Corner_match_ED(Corner_CSS,Corner_harris);

row = size(CSS_marked_img,1);
for i = 1: length(Corner_CSS_matched)
        line([Corner_CSS_matched(i,2) Corner_Harris_matched(i,2)+row], ...
            [Corner_CSS_matched(i,1) Corner_Harris_matched(i,1)], 'Color', 'g');
end

% SVD match and show
% UU = Corner_match(gray_img,gray_img,Corner_harris,Corner_CSS);
% row = size(Harris_marked_img,1);
% for i = 1: size(UU,1)
%     if UU(i,1)>0
%         line([Corner_harris(UU(i,1),2) Corner_CSS(UU(i,2),2)+row], ...
%             [Corner_harris(UU(i,1),1) Corner_CSS(UU(i,2),1)], 'Color', 'g');
%     end
% end

%% leak detection
% we define Self-confident Level for Harris and CSS corners.
% Self-confident Level for Harri corners.

% mean CRF of matched corner 
CRF_matched_Harris = []; % CRF of each matched Harris corner
for i = 1:length(Corner_Harris_matched)
    CRF_matched_Harris_temp = CRF(Corner_Harris_matched(i,1),Corner_Harris_matched(i,2));
    CRF_matched_Harris = [CRF_matched_Harris,CRF_matched_Harris_temp];
end

CRF_mean = mean(CRF_matched_Harris); % mean CRF of matched Harris corner
CRF_min = min(CRF_matched_Harris);

Corner_harris_diff = setdiff(Corner_harris, Corner_Harris_matched, 'rows'); % Corners except matched in Harris corner

Corner_CSS_nonendpoints = Corner_CSS(1:length(Angle),:);
Corner_CSS_endpoints = setdiff(Corner_CSS,Corner_CSS_nonendpoints,'rows');
Corner_CSS_diff = setdiff(Corner_CSS_nonendpoints,Corner_CSS_matched,'rows'); % ���˵����CSS��û��ƥ���ϵĵ�

Corner_diff = [Corner_harris_diff;Corner_CSS_diff];

SCL_diff = []; % Self-confident Level of Corner_harris_diff
for i = 1:length(Corner_diff)
    SCL_temp = CRF(Corner_diff(i,1),Corner_diff(i,2))/CRF_min;
%     SCL_Harris_temp = CRF(Corner_harris_diff(i,1),Corner_harris_diff(i,2))/CRF_min;
    SCL_diff = [SCL_diff,SCL_temp];
end
Corner_leak_index = find(SCL_diff>=1); % if the Self-confident Level of Corner_harris_diff is larger than the mean, then this point is a corner

if isempty(Corner_leak_index)
    Corner_leak_index = [];
else
    Corner_leak = Corner_diff(Corner_leak_index,:); % missed Harris corners 
end
Corner = [Corner_CSS_matched;Corner_leak;Corner_CSS_endpoints];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������Harris_diff�ǵ��SCL%%%%%%%%%%%%%%%%%%%%
% % mean CRF of matched corner 
% CRF_matched_Harris = []; % CRF of each matched Harris corner
% for i = 1:length(Corner_Harris_matched)
%     CRF_matched_Harris_temp = CRF(Corner_Harris_matched(i,1),Corner_Harris_matched(i,2));
%     CRF_matched_Harris = [CRF_matched_Harris,CRF_matched_Harris_temp];
% end
% 
% CRF_mean = mean(CRF_matched_Harris); % mean CRF of matched Harris corner
% CRF_min = min(CRF_matched_Harris);
% 
% Corner_harris_diff = setdiff(Corner_harris, Corner_Harris_matched, 'rows'); % Corners except matched in Harris corner
% 
% Corner_CSS_nonendpoints = Corner_CSS(1:length(Angle),:);
% Corner_CSS_endpoints = setdiff(Corner_CSS,Corner_CSS_nonendpoints,'rows');
% Corner_CSS_diff = setdiff(Corner_CSS_nonendpoints,Corner_CSS_matched,'rows'); % ���˵����CSS��û��ƥ���ϵĵ�
% 
% Corner_diff = [Corner_harris_diff;Corner_CSS_diff];
% 
% SCL_Harris_diff = []; % Self-confident Level of Corner_harris_diff
% for i = 1:length(Corner_harris_diff)
%     SCL_Harris_temp = CRF(Corner_harris_diff(i,1),Corner_harris_diff(i,2))/CRF_mean;
% %     SCL_Harris_temp = CRF(Corner_harris_diff(i,1),Corner_harris_diff(i,2))/CRF_min;
%     SCL_Harris_diff = [SCL_Harris_diff,SCL_Harris_temp];
% end
% Corner_Harris_leak_index = find(SCL_Harris_diff>=1); % if the Self-confident Level of Corner_harris_diff is larger than the mean, then this point is a corner
% 
% if isempty(Corner_Harris_leak_index)
%     Corner_Harris_leak_index = [];
% else
%     Corner_Harris_leak = Corner_harris_diff(Corner_Harris_leak_index,:); % missed Harris corners 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����������岻��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Self-confident Level for CSS corners.
% Corner_CSS_nonendpoints = Corner_CSS(1:length(Angle),:);
% % Corner_CSS_endpoints = setdiff(Corner_CSS,Corner_CSS_nonendpoints,'rows');
% Corner_CSS_endpoints = Corner_CSS((length(Angle)+1):corner_count_CSS,:);
% 
% Angle_CSS_matched = []; % note that not all matched corners are belong to non-endpoints, several matched corner may be endpoints.
% Corner_CSS_index_matched = find(ismember(Corner_CSS_nonendpoints,Corner_CSS_matched,'rows')); % Index of Corner_CSS_matched in Corner_CSS_nonendpoints
% Angle_CSS_matched = Angle(Corner_CSS_index_matched); % endpoints are removed
% 
% % Corner_CSS_diff = setdiff(Corner_CSS_nonendpoints,Corner_CSS_matched,'rows');
% Corner_CSS_index_diff = find(~ismember(Corner_CSS_nonendpoints,Corner_CSS_matched,'rows'));
% Angle_CSS_diff = Angle(Corner_CSS_index_diff); % û��ƥ���Ͻǵ�ĽǶȣ����˵��⣩
% 
% n_obtuse = length(find(Angle_CSS_matched>=180));
% Angle_mean = (sum(Angle_CSS_matched)-180*n_obtuse)/length(Angle_CSS_matched); % consider angle>180
% Angle_min = min(Angle_CSS_matched);
% 
% SCL_CSS_diff = Angle_CSS_diff/Angle_mean;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gcf,'color','white','paperpositionmode','auto');

%% Harris�ǵ��Ⲣ��ԭͼ����ʾ�ǵ�
figure('Name','harris corner')
% subplot(3,2,1);
imshow(imgsrc);%ԭͼ
hold on;
% toc(t1)
disp('Harris�ǵ����');
disp(corner_count_harris);
%���нǵ���ʾ
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
% ��ʾ����
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner_harris(:, 2), Corner_harris(:, 1), 'go');
plot(Corner_Harris_matched(:, 2), Corner_Harris_matched(:, 1), 'bo');
% plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
saveas(gcf,['.\experiments\',newfilename,'_harris.eps'],'psc2');
% text(Corner_harris(:, 2),Corner_harris(:, 1),cellstr(str1),'FontSize',5);

% if(~isempty(Corner_harris_diff))
%     plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'ro');
% end

% subplot(3,2,2);
% imshow(imgsrc);%ԭͼ
% hold on;
% plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'g.');

%% RCSS�ǵ��Ⲣ��ԭͼ����ʾ�ǵ�
figure('Name','RCSS corner')
% subplot(3,2,2);
disp('RCSS�ǵ����');
disp(corner_count_RCSS);
imshow(imgsrc);
hold on;
% plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'g.');
% ��ʾ����
% str2=[repmat('  X:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 2)) repmat(', Y:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 1))];
plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'go');
saveas(gcf,['.\experiments\',newfilename,'_RCSS.eps'],'psc2');
% text(Corner_RCSS(:, 2),Corner_RCSS(:, 1),cellstr(str2),'FontSize',5);
% plot(Corner_RCSS_diff(:, 2), Corner_RCSS_diff(:, 1), 'ro');
% if(~isempty(Corner_RCSS_diff_final))
%     plot(Corner_RCSS_diff_final(:,2),Corner_RCSS_diff_final(:,1),'ro');
% end

%% CSS�ǵ��Ⲣ��ԭͼ����ʾ�ǵ�
figure('Name','CSS corner')
% subplot(3,2,1);
imshow(imgsrc);%ԭͼ
hold on;
% toc(t1)
disp('CSS�ǵ����');
disp(corner_count_CSS);
%���нǵ���ʾ
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
% ��ʾ����
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner_CSS(:, 2), Corner_CSS(:, 1), 'go');
% plot(Corner_CSS_matched(:, 2), Corner_CSS_matched(:, 1), 'bo');
% plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
saveas(gcf,['.\experiments\',newfilename,'_CSS.eps'],'psc2');

%% ���սǵ���ԭͼ����ʾ�ǵ�
figure('Name','Final corner')
% subplot(3,2,1);
imshow(imgsrc);%ԭͼ
hold on;
% toc(t1)
disp('���սǵ����');
disp(length(Corner));
%���нǵ���ʾ
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
% ��ʾ����
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner(:, 2), Corner(:, 1), 'go');
% saveas(gcf,['.\experiments\',newfilename,'_CSS.eps'],'psc2');

%% localization Error

%% Average Repeatability