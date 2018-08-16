%% This is the main file of the project with method 2.
% Author: Yihui Li
% Email: liyihui.ing@qq.com
%% ��������
close all;
clear all;
clear;
clc;

batch = 0; % Handle image together or one-by -one, 1 is together, 0 is one-by-one
if ~batch
    % one by one
    [file_name, file_path] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    'ѡ��ͼƬ');
    %     imgsrc = imread([file_path, file_name]);
    [Corner_final,Corner_harris,Corner_RCSS,Corner_ECSS] = the_proposed_method(file_path,file_name);
else
    file_path =  './experiments/original/';% ͼ���ļ���·��
    img_path_list = dir(strcat(file_path,'*'));%��ȡ���ļ���������jpg��ʽ��ͼ��
    img_num = length(img_path_list);%��ȡͼ��������
    if img_num > 0 %������������ͼ��
        for j = 1:img_num %��һ��ȡͼ��
            file_name = img_path_list(j).name;% ͼ����
            [Corner_final,Corner_harris,Corner_RCSS,Corner_ECSS] = the_proposed_method(file_path,file_name);
            %         fprintf('%d %d %s\n',i,j,strcat(file_path,image_name));% ��ʾ���ڴ����ͼ����
            %û��ͼ��
            
        end
    end
end

%% localization Error

%% Average Repeatability