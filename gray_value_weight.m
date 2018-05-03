function [ W ] = gray_value_weight( gray_img,location_mat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
W = [];
gray_value = [];
l = length(location_mat);
for i=1:l
    gray_value(i) = gray_img(location_mat(i,1),location_mat(i,2));
end
gray_value_sum = sum(gray_value);
for j=1:l
    gray_value(j) = gray_img(location_mat(j,1),location_mat(j,2));
    w(j) = gray_value(j)/gray_value_sum;
    W=[W,w(j)];
end

