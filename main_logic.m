%% This is the main file of the project with method 2.
% Author: Yihui Li
% Email: liyihui.ing@qq.com
%% 清理数据
close all;
clear all;
clear;
clc;

batch = 0; % Handle image together or one-by -one, 1 is together, 0 is one-by-one
if ~batch
    % one by one
    [file_name, file_path] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    '选择图片');
    %     imgsrc = imread([file_path, file_name]);
    [Corner_final,Corner_harris,Corner_RCSS,Corner_ECSS] = the_proposed_method(file_path,file_name);
else
    file_path =  './experiments/original/';% 图像文件夹路径
    img_path_list = dir(strcat(file_path,'*'));%获取该文件夹中所有jpg格式的图像
    img_num = length(img_path_list);%获取图像总数量
    if img_num > 0 %有满足条件的图像
        for j = 1:img_num %逐一读取图像
            file_name = img_path_list(j).name;% 图像名
            [Corner_final,Corner_harris,Corner_RCSS,Corner_ECSS] = the_proposed_method(file_path,file_name);
            %         fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));% 显示正在处理的图像名
            %没有图像
            
        end
    end
end

%% localization Error

%% Average Repeatability