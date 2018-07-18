% Copyright (c) 2011, Wiggin
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% LINK: https://cn.mathworks.com/matlabcentral/fileexchange/30789-corner-detection-using-susan-operator

function [Corner_Location,Corner] = SUSAN( img )
%SUSAN Corner detection using SUSAN method.
%   [R C] = SUSAN(IMG)	Rows and columns of corner points are returned.
%	Edward @ THUEE, xjed09@gmail.com
img = im2double(img); %% 将图像转换为双精度，即gray_value/255
maskSz = [7 7];
fun = @(img) susanFun(img);
Corner = nlfilter(img,maskSz,fun); % 通用滑块邻域操作函数

Corner_Location = [];
[Corner_Location(:,1),Corner_Location(:,2)] = find(Corner);

end

% function [ map r c ] = susanCorner( img )
% %SUSAN Corner detection using SUSAN method.
% %   [R C] = SUSAN(IMG)	Rows and columns of corner points are returned.
% %	Edward @ THUEE, xjed09@gmail.com
%
% maskSz = [7 7];
% fun = @(img) susanFun(img);
% map = nlfilter(img,maskSz,fun);
% [r c] = find(map);
%
% end

function res = susanFun(img)
% SUSANFUN  Determine if the center of the image patch IMG
%	is corner(res = 1) or not(res = 0)
% img相当于模板了


mask = [...
    0 0 1 1 1 0 0
    0 1 1 1 1 1 0
    1 1 1 1 1 1 1
    1 1 1 1 1 1 1
    1 1 1 1 1 1 1
    0 1 1 1 1 1 0
    0 0 1 1 1 0 0];

% uses 2 thresholds to distinguish corners from edges
thGeo = (nnz(mask)-1)*.2; % nnz: Number of nonzero matrix elements. (nnz(mask)-1)可看作最大面积
thGeo1 = (nnz(mask)-1)*.7;
thGeo2 = (nnz(mask)-1)*.7;
thT = .062; % 对应到的灰度值17.85
thT1 = .04; % 对应到的灰度值10.2

sz = size(img,1);
usan = ones(sz)*img(round(sz/2),round(sz/2)); % 使得每一个矩阵元素都是模板中心元素的灰度值
similar = abs(usan-img)<thT; % 逻辑矩阵
similar = similar.*mask; % 逻辑矩阵

% global usan;
% global similar1;
% usan = ones(sz)*img(round(sz/2),round(sz/2)); % 使得每一个矩阵元素都是模板中心元素的灰度值
% similar1 = abs(usan-img)<thT;
% similar = similar1.*mask;

res = sum(similar(:)); % 得出来的灰度值差的和，相当于sum(c(r,r0))
if res < thGeo %% 当核心在区域边缘时，USAN区域面积是模板面积的一半
    % 	dark = nnz((img-usan<-thT1).*mask);
    % 	bright = nnz((img-usan>thT1).*mask);
    % 	res = min(dark,bright)<thGeo1 && max(dark,bright)>thGeo2; % 与运算
    res = 1;
else
    res = 0;
end

end
