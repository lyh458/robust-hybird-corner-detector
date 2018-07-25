close all;
clear;
I = imread('barn.jpg');
[corners] = RCSS(rgb2gray(I), []);

imshow(I);
hold on;
scatter(corners(:, 1), corners(:, 2), 'MarkerEdgeColor',[0 1 0]);


