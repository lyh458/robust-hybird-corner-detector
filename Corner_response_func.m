function [ CRF ] = Corner_response_func( gray_img, lr , lc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Image = im2uint8(gray_img);

dx = [-1 0 1;-1 0 1;-1 0 1];  %dx：横向Prewitt差分模版
Ix2 = filter2(dx,Image).^2;
Iy2 = filter2(dx',Image).^2;
Ixy = filter2(dx,Image).*filter2(dx',Image);

%生成 9*9高斯窗口。窗口越大，探测到的角点越少。
h= fspecial('gaussian',9,2);
A = filter2(h,Ix2);       % 用高斯窗口差分Ix2得到A
B = filter2(h,Iy2);
C = filter2(h,Ixy);

m=0.05; %论文是0.06
M = [A(lr,lc) C(lr,lc);
    C(lr,lc) B(lr,lc)];
% [V,D] = eig(M);
% 角点响应函数
CRF = det(M)-m*(trace(M))^2;
end

