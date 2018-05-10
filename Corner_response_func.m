function [ CRF ] = Corner_response_func( gray_img, lr , lc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Image = im2uint8(gray_img);

dx = [-1 0 1;-1 0 1;-1 0 1];  %dx������Prewitt���ģ��
Ix2 = filter2(dx,Image).^2;
Iy2 = filter2(dx',Image).^2;
Ixy = filter2(dx,Image).*filter2(dx',Image);

%���� 9*9��˹���ڡ�����Խ��̽�⵽�Ľǵ�Խ�١�
h= fspecial('gaussian',9,2);
A = filter2(h,Ix2);       % �ø�˹���ڲ��Ix2�õ�A
B = filter2(h,Iy2);
C = filter2(h,Ixy);

m=0.05; %������0.06
M = [A(lr,lc) C(lr,lc);
    C(lr,lc) B(lr,lc)];
% [V,D] = eig(M);
% �ǵ���Ӧ����
CRF = det(M)-m*(trace(M))^2;
end

