%% This is the main file of the project with method 2.
% Author: Yihui Li
% Email: liyihui.ing@qq.com
%% 清理数据
close all;
clear all;
clear;
clc;

%% 图像处理
% % one by one
% [file_name, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'}, '选择图片');
% newfilename = file_name(1:end-4); % 用于后面实验结果动态保存文件名
% imgsrc = imread([pathname, file_name]);
% if file_name == 0
%             return;
%         end
file_path =  './experiments/original/';% 图像文件夹路径
% file_path =  './experiments/original/Corner_detection_dataset/';% 图像文件夹路径
img_path_list1 = dir(strcat(file_path,'*.gif'));%获取该文件夹中所有jpg格式的图像
img_num1 = length(img_path_list1);
img_path_list2 = dir(strcat(file_path,'*.png'));
img_num2 = length(img_path_list2);
img_path_list = img_path_list1;
for i=1:img_num2
    img_path_list(img_num1+i) = img_path_list2(i);
end
img_num = length(img_path_list);%获取图像总数量
LE_harris = [];
LE_RCSS = [];
LE_ECSS = [];
LE_final = [];
ACU_harris = [];
ACU_RCSS = [];
ACU_ECSS = [];
ACU_final = [];
TPR_harris = [];
TPR_RCSS = [];
TPR_ECSS = [];
TPR_final = [];
FPR_harris = [];
FPR_RCSS = [];
FPR_ECSS = [];
FPR_final = [];
if img_num > 0 %有满足条件的图像
    for j = 1:img_num %逐一读取图像
        file_name = img_path_list(j).name;% 图像名
        
        %         fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));% 显示正在处理的图像名
        %没有图像
        if ~isempty(file_name) && ~strncmp(file_name,'.',1)
            imgsrc =  imread(strcat(file_path,file_name));
            newfilename = file_name(1:end-4); % 用于后面实验结果动态保存文件名
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
            
            %             if ~isempty(strfind(file_name,'demo'))
            %                 level = graythresh(img);%%matlab 自带的自动确定阈值的方法，大津法，类间方差
            %                 img = im2bw(img,level);%%用得到的阈值直接对图像进行二值化
            %                 imwrite(img,'flower.gif');
            %             end
            
            if isa(img, 'uint8')
                img = img;
            else
                img = im2uint8(img);
            end
            
            %% Matlab自带的边缘检测
            % bw=graythresh(img);
            % bi=im2bw(img,bw);
            % ed = edge(bi, 'canny', 0.5);
            
            %% Harris
            % [Corner_harris,Harris_marked_img,CRF] = Harris(img,0.01);
            [Corner_harris,Harris_marked_img,CRF] = Harris(img,0.0001);
            [Corner_harris_default,Harris_marked_img_default,CRF_default] = Harris(img,0.01);
            
            % Corner_harris = detectHarrisFeatures(gray_img);
            % Matlab official Harris detectcloseor
            corner_count_harris = length(Corner_harris);
            
            % [Corner_SUSAN] = SUSAN(img);
            % corner_count_SUSAN = length(Corner_SUSAN);
            
            %% RCSS
            Corner_RCSS = RCSS(img,[]);
            RCSS_marked_img = imgsrc;
            for i=1:length(Corner_RCSS)
                RCSS_marked_img = mark(RCSS_marked_img,Corner_RCSS(i,1),Corner_RCSS(i,2),5);
            end
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
            
            %% ECSS
            [Corner_ECSS,ECSS_marked_img,Angle] = ECSS(img,[],175,[],0.4,0,1,1);
            [Corner_ECSS_default,ECSS_marked_img_default,Angle_default] = ECSS(img,[],[],[],[],[],[],[]);
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
            
            corner_count_ECSS = length(Corner_ECSS);
            
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
            % Euclidean distance match and show
            [Corner_matched,Corner_ECSS_matched,Corner_Harris_matched]=Corner_match_ED(Corner_ECSS,Corner_harris);
            
            % SVD match and show
            % UU = Corner_match(gray_img,gray_img,Corner_harris,Corner_ECSS);
            % row = size(Harris_marked_img,1);
            % for i = 1: size(UU,1)
            %     if UU(i,1)>0
            %         line([Corner_harris(UU(i,1),2) Corner_ECSS(UU(i,2),2)+row], ...
            %             [Corner_harris(UU(i,1),1) Corner_ECSS(UU(i,2),1)], 'Color', 'g');
            %     end
            % end
            
            %% leak detection
            % we define Self-confident Level for Harris and CSS corners.
            % Self-confident Level for Harri corners.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%单纯计算Harris_diff角点的SCL%%%%%%%%%%%%%%%%%%%%
            if ~isempty(Corner_Harris_matched)
                % mean CRF of matched corner
                CRF_matched_Harris = []; % CRF of each matched Harris corner
                for i = 1:length(Corner_Harris_matched)
                    CRF_matched_Harris_temp = CRF(Corner_Harris_matched(i,1),Corner_Harris_matched(i,2));
                    CRF_matched_Harris = [CRF_matched_Harris,CRF_matched_Harris_temp];
                end
                
                CRF_mean = mean(CRF_matched_Harris); % mean CRF of matched Harris corner
                CRF_min = min(CRF_matched_Harris);
                
                Corner_harris_diff = setdiff(Corner_harris, Corner_Harris_matched, 'rows'); % Corners except matched in Harris corner
                
                Corner_ECSS_nonendpoints = Corner_ECSS(1:length(Angle),:);
                Corner_ECSS_endpoints = setdiff(Corner_ECSS,Corner_ECSS_nonendpoints,'rows');
                Corner_ECSS_diff = setdiff(Corner_ECSS_nonendpoints,Corner_ECSS_matched,'rows'); % 除端点外的CSS中没有匹配上的点
                
                Corner_diff = [Corner_harris_diff;Corner_ECSS_diff];
                
                SCL_Harris_diff = []; % Self-confident Level of Corner_harris_diff
                for i = 1:length(Corner_harris_diff)
                    SCL_Harris_temp = CRF(Corner_harris_diff(i,1),Corner_harris_diff(i,2))/CRF_min;
                    %     SCL_Harris_temp = CRF(Corner_harris_diff(i,1),Corner_harris_diff(i,2))/CRF_min;
                    SCL_Harris_diff = [SCL_Harris_diff,SCL_Harris_temp];
                end
                Corner_Harris_leak_index = find(SCL_Harris_diff>=1); % if the Self-confident Level of Corner_harris_diff is larger than the mean, then this point is a corner
                
                if isempty(Corner_Harris_leak_index)
                    Corner_Harris_leak = [];
                else
                    Corner_Harris_leak = Corner_harris_diff(Corner_Harris_leak_index,:); % missed Harris corners
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%CSS角点的SCL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Self-confident Level for CSS corners.
                Corner_ECSS_nonendpoints = Corner_ECSS(1:length(Angle),:);
                % Corner_ECSS_endpoints = setdiff(Corner_ECSS,Corner_ECSS_nonendpoints,'rows');
                Corner_ECSS_endpoints = Corner_ECSS((length(Angle)+1):corner_count_ECSS,:);
                
                Angle_ECSS_matched = []; % note that not all matched corners are belong to non-endpoints, several matched corner may be endpoints.
                Corner_ECSS_index_matched = find(ismember(Corner_ECSS_nonendpoints,Corner_ECSS_matched,'rows')); % Index of Corner_ECSS_matched in Corner_ECSS_nonendpoints
                Angle_ECSS_matched = Angle(Corner_ECSS_index_matched); % endpoints are removed
                
                Corner_ECSS_diff = setdiff(Corner_ECSS_nonendpoints,Corner_ECSS_matched,'rows');
                
                Corner_ECSS_index_diff = find(~ismember(Corner_ECSS_nonendpoints,Corner_ECSS_matched,'rows'));
                
                Angle_ECSS_diff = Angle(Corner_ECSS_index_diff); % 没有匹配上角点的角度（除端点外）
                
                n_obtuse = length(find(Angle_ECSS_matched>=180));
                Angle_mean = (sum(Angle_ECSS_matched)-180*n_obtuse)/length(Angle_ECSS_matched); % consider angle>180
                Angle_min = min(Angle_ECSS_matched);
                Angle_max = max(Angle_ECSS_matched(find(Angle_ECSS_matched<180)));
                SCL_ECSS_diff = Angle_ECSS_diff/Angle_max;
                Corner_ECSS_leak = Corner_ECSS_diff(find(SCL_ECSS_diff<=1),:);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                Corner_leak_temp = [Corner_Harris_leak;Corner_ECSS_leak];
                
                Corner_leak = [];
                DS = [1 1];
                tol = 10;
                [C,IA]=uniquetol(Corner_leak_temp, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
                for m = 1:length(IA)
                    if(length(IA{m})==1)
                        Corner_leak(m,1) = Corner_leak_temp(IA{m},1);
                        Corner_leak(m,2) = Corner_leak_temp(IA{m},2);
                    else
                        Corner_leak(m,1) = round(mean(Corner_leak_temp(IA{m},1)));
                        Corner_leak(m,2) = round(mean(Corner_leak_temp(IA{m},2)));
                    end
                end
                if ~isempty(Corner_leak)
                    for i=1:length(Corner_matched)
                        D = sqrt((Corner_leak(:,1)-Corner_matched(i,1)).^2+(Corner_leak(:,2)-Corner_matched(i,2)).^2);
                        J = find(D<10);
                        Corner_leak(J,:)=[];
                    end
                end
                %                 Corner = [Corner_matched;Corner_leak;Corner_ECSS_endpoints];
                Corner_temp = [Corner_matched;Corner_leak;Corner_ECSS_endpoints];
                Corner = [];
                DS = [1 1];
                tol = 3;
                [C,IA]=uniquetol(Corner_temp, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
                for m = 1:length(IA)
                    if(length(IA{m})==1)
                        Corner(m,1) = Corner_temp(IA{m},1);
                        Corner(m,2) = Corner_temp(IA{m},2);
                    else
                        Corner(m,1) = round(mean(Corner_temp(IA{m},1)));
                        Corner(m,2) = round(mean(Corner_temp(IA{m},2)));
                    end
                end
            else
                Corner = Corner_ECSS;
            end
            
            % set(gcf,'color','white','paperpositionmode','auto');
            set (gcf,'Position',[0,0,500,500]);
            Final_marked_img = imgsrc;
            for i=1:length(Corner)
                Final_marked_img = mark(Final_marked_img,Corner(i,1),Corner(i,2),5);
            end
            %% 原显示方式
            %   %% Harris角点检测并在原图像显示角点
            % figure('Name','harris corner')
            % % subplot(3,2,1);
            % % img_Harris=mark(imgsrc,Corner_harris(i,1),Corner_harris(i,2),5);
            % % imshow(img_Harris);
            % imshow(imgsrc,'border','tight');
            % axis image;
            % hold on;
            % % toc(t1)
            % disp('Harris角点个数');
            % disp(corner_count_harris);
            % plot(Corner_harris(:, 2), Corner_harris(:, 1), 'go');
            % % if ~isempty(Corner_Harris_matched)
            % %     plot(Corner_Harris_matched(:, 2), Corner_Harris_matched(:, 1), 'bo');
            % % end
            % % plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
            % saveas(gcf,['.\experiments\',newfilename,'_harris.eps'],'psc2');
            % saveas(gcf,['.\experiments\',newfilename,'_harris.png']);
            % % text(Corner_harris(:, 2),Corner_harris(:, 1),cellstr(str1),'FontSize',5);
            %
            % % if(~isempty(Corner_harris_diff))
            % %     plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'ro');
            % % end
            %
            % % subplot(3,2,2);
            % % imshow(imgsrc);%原图
            % % hold on;
            % % plot(Corner_harris_diff(:,2),Corner_harris_diff(:,1),'g.');
            %
            %
            % %% RCSS角点检测并在原图像显示角点
            % figure('Name','RCSS corner')
            % % subplot(3,2,2);
            % disp('RCSS角点个数');
            % disp(corner_count_RCSS);
            % imshow(imgsrc,'border','tight');
            % axis image;
            % hold on;
            % % plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'g.');
            % % 显示坐标
            % % str2=[repmat('  X:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 2)) repmat(', Y:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 1))];
            % plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'go');
            % saveas(gcf,['.\experiments\',newfilename,'_RCSS.eps'],'psc2');
            % saveas(gcf,['.\experiments\',newfilename,'_RCSS.png']);
            % % text(Corner_RCSS(:, 2),Corner_RCSS(:, 1),cellstr(str2),'FontSize',5);
            % % plot(Corner_RCSS_diff(:, 2), Corner_RCSS_diff(:, 1), 'ro');
            % % if(~isempty(Corner_RCSS_diff_final))
            % %     plot(Corner_RCSS_diff_final(:,2),Corner_RCSS_diff_final(:,1),'ro');
            % % end
            %
            % %% CSS角点检测并在原图像显示角点
            % figure('Name','CSS corner')
            % % subplot(3,2,1);
            % imshow(imgsrc,'border','tight');
            % axis image;
            % hold on;
            % % toc(t1)
            % disp('CSS角点个数');
            % disp(corner_count_ECSS);
            % %所有角点显示
            % % plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
            % % 显示坐标
            % % str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
            % plot(Corner_ECSS(:, 2), Corner_ECSS(:, 1), 'go');
            % % if ~isempty(Corner_ECSS_matched)
            % %     plot(Corner_ECSS_matched(:, 2), Corner_ECSS_matched(:, 1), 'bo');
            % % end
            % % plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
            % saveas(gcf,['.\experiments\',newfilename,'_ECSS.eps'],'psc2');
            % saveas(gcf,['.\experiments\',newfilename,'_ECSS.png']);
            %
            % %% Corner matching show
            % img_append = appendimages(CSS_marked_img,Harris_marked_img);
            % % figure('Position', [0 0 size(img_append,2) size(img_append,1)]);
            % figure('Name','Corner matching');
            % %figure(3);
            % colormap('gray');
            % % imagesc(img_append);
            % imshow(img_append,'border','tight');
            % axis image;
            % hold on;
            % row = size(CSS_marked_img,1);
            % for i = 1: length(Corner_ECSS_matched)
            %     line([Corner_ECSS_matched(i,2) Corner_Harris_matched(i,2)+row], ...
            %         [Corner_ECSS_matched(i,1) Corner_Harris_matched(i,1)], 'Color', 'g');
            % end
            % saveas(gcf,['.\experiments\',newfilename,'_corner_matching.eps'],'psc2');
            % saveas(gcf,['.\experiments\',newfilename,'_corner_matching.png']);
            %
            % %% 最终角点检测并在原图像显示角点
            % figure('Name','Final corner')
            % % subplot(3,2,1);
            % imshow(imgsrc,'border','tight');
            % axis image;
            % % axis normal;
            % hold on;
            % % toc(t1)
            % disp('最终角点个数');
            % disp(length(Corner));
            % %所有角点显示
            % % plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
            % % 显示坐标
            % % str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
            % plot(Corner(:, 2), Corner(:, 1), 'go');
            % % if ~isempty(Corner_ECSS_matched)
            % %     %     plot(Corner_ECSS_matched(:, 2), Corner_ECSS_matched(:, 1), 'bo');
            % %     plot(Corner_matched(:, 2), Corner_matched(:, 1), 'bo');
            % %     plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
            % % end
            % saveas(gcf,['.\experiments\',newfilename,'_final.eps'],'psc2');
            % saveas(gcf,['.\experiments\',newfilename,'_final.png']);
            
            %% 新显示方式，更新对比度
%             % %% Harris角点检测并在原图像显示角点
%             figure('Name','harris corner')
%             %             Harris_marked_img = imgsrc;
%             %             for i=1:length(Corner_harris)
%             %                 Harris_marked_img = mark(Harris_marked_img,Corner_harris(i,1),Corner_harris(i,2),5);
%             %             end
%             imshow(Harris_marked_img_default);
%             disp('Harris角点个数');
%             disp(corner_count_harris);
%             
%             % %% RCSS角点检测并在原图像显示角点
%             figure('Name','RCSS corner')
%             imshow(RCSS_marked_img);
%             disp('RCSS角点个数');
%             disp(corner_count_RCSS);
%             
%             % %% ECSS角点检测并在原图像显示角点
%             figure('Name','ECSS corner')
%             imshow(ECSS_marked_img_default);
%             disp('ECSS角点个数');
%             disp(corner_count_ECSS);
%             
%             % %% 最终角点检测并在原图像显示角点
%             figure('Name','Final corner')
%             imshow(Final_marked_img);
%             disp('最终角点个数');
%             disp(length(Corner));
%             save(['.\experiments\result',newfilename,'.mat'],'Corner_harris','Corner_ECSS','Corner_RCSS','Corner');
%             %% Show matched corners of 'blocks.gif'
%             if strcmp(file_name,'blocks.gif')
%                 % %% Corner matching show
%                 img_append = appendimages(ECSS_marked_img,Harris_marked_img);
%                 % figure('Position', [0 0 size(img_append,2) size(img_append,1)]);
%                 figure('Name','Corner matching');
%                 %figure(3);
%                 colormap('gray');
%                 % imagesc(img_append);
%                 imshow(img_append,'border','tight');
%                 axis image;
%                 hold on;
%                 row = size(ECSS_marked_img,1);
%                 for i = 1: length(Corner_ECSS_matched)
%                     line([Corner_ECSS_matched(i,2) Corner_Harris_matched(i,2)+row], ...
%                         [Corner_ECSS_matched(i,1) Corner_Harris_matched(i,1)], 'Color', 'g');
%                 end
%                 % saveas(gcf,['.\experiments\',newfilename,'_corner_matching.eps'],'psc2');
%                 saveas(gcf,['.\experiments\',newfilename,'_corner_matching.png']);
%             end
            %% Save images
            imwrite(Harris_marked_img_default,['.\experiments\result\',newfilename,'_Harris.png']);
%             save(['.\experiments\result\',newfilename,'_Harris.mat'],'Corner_harris_default');
            
            imwrite(RCSS_marked_img,['.\experiments\result\',newfilename,'_RCSS.png']);
%             save(['.\experiments\result\',newfilename,'_RCSS.mat'],'Corner_RCSS');
            
            imwrite(ECSS_marked_img_default,['.\experiments\result\',newfilename,'_ECSS.png']);
%             save(['.\experiments\result\',newfilename,'_ECSS.mat'],'Corner_ECSS_default');
            
            imwrite(Final_marked_img,['.\experiments\result\',newfilename,'_final.png']);
%             save(['.\experiments\result\',newfilename,'_final.mat'],'Corner');
            %% Experiments
            % Import ground truth
            load(['.\experiments\ground truth\Location_',newfilename,'.mat']);
            Location_temp = [Location(:,2),Location(:,1)];
            [tpr_harris, fpr_harris, acu_harris, le_harris] = TP_FP(Corner_harris, Location_temp, imgsrc);
            [tpr_RCSS, fpr_RCSS, acu_RCSS, le_RCSS] = TP_FP(Corner_RCSS, Location_temp, imgsrc);
            [tpr_ECSS, fpr_ECSS, acu_ECSS, le_ECSS] = TP_FP(Corner_ECSS, Location_temp, imgsrc);
            [tpr_final, fpr_final, acu_final, le_final] = TP_FP(Corner, Location_temp, imgsrc);
            % Receiver Operating Characteristic
        end
        % 储存数据
        Image_name{j,1}=newfilename;
        LE_harris = [LE_harris;le_harris];
        LE_RCSS = [LE_RCSS;le_RCSS];
        LE_ECSS = [LE_ECSS;le_ECSS];
        LE_final = [LE_final;le_final];
        ACU_harris = [ACU_harris;acu_harris];
        ACU_RCSS = [ACU_RCSS;acu_RCSS];
        ACU_ECSS = [ACU_ECSS;acu_ECSS];
        ACU_final = [ACU_final;acu_final];
        TPR_harris = [TPR_harris;tpr_harris];
        TPR_RCSS = [TPR_RCSS;tpr_RCSS];
        TPR_ECSS = [TPR_ECSS;tpr_ECSS];
        TPR_final = [TPR_final;tpr_final];
        FPR_harris = [FPR_harris;fpr_harris];
        FPR_RCSS = [FPR_RCSS;fpr_RCSS];
        FPR_ECSS = [FPR_ECSS;fpr_ECSS];
        FPR_final = [FPR_final;fpr_final];
    end
end
%% LE - Localization error
LE = table(Image_name,LE_harris,LE_RCSS,LE_ECSS,LE_final);
writetable(LE,'./experiments/result/LE.xlsx');

%% ACU
ACU = table(Image_name,ACU_harris,ACU_RCSS,ACU_ECSS,ACU_final);
writetable(ACU,'./experiments/result/ACU.xlsx');

%% TPR
TPR = table(Image_name,TPR_harris,TPR_RCSS,TPR_ECSS,TPR_final);
writetable(TPR,'./experiments/result/TPR.xlsx');

%% FPR
FPR = table(Image_name,FPR_harris,FPR_RCSS,FPR_ECSS,FPR_final);
writetable(FPR,'./experiments/result/FPR.xlsx');

%% Receiver Operating Characteristic


%% Average Repeatability