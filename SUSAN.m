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

function [Corner_Location] = SUSAN( img )
%SUSAN Corner detection using SUSAN method.
%   [R C] = SUSAN(IMG)	Rows and columns of corner points are returned.
%	Edward @ THUEE, xjed09@gmail.com
img = im2double(img);
maskSz = [7 7];
fun = @(img) susanFun(img);
Corner = nlfilter(img,maskSz,fun); % 通用滑块邻域操作函数
[r,c] = find(Corner); 

% k=0;
Corner_Location = [r,c];
% corner_count = length(find(Corner));
% for i=1:nrow
%     for j=1:ncol
%         if Corner(i,j)==1
%             k=k+1;
%             Corner_Location(k,:)=[j,i];
%         end
%     end
% end


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


mask = [...
	0 0 1 1 1 0 0
	0 1 1 1 1 1 0
	1 1 1 1 1 1 1
	1 1 1 1 1 1 1
	1 1 1 1 1 1 1
	0 1 1 1 1 1 0
	0 0 1 1 1 0 0];

% uses 2 thresholds to distinguish corners from edges
thGeo = (nnz(mask)-1)*.3; % nnz: Number of nonzero matrix elements.
thGeo1 = (nnz(mask)-1)*.4;
thGeo2 = (nnz(mask)-1)*.4;
thT = .06;
thT1 = .04;

sz = size(img,1);
usan = ones(sz)*img(round(sz/2),round(sz/2)); %

similar = (abs(usan-img)<thT);
similar = similar.*mask;
res = sum(similar(:));
if res < thGeo
	dark = nnz((img-usan<-thT1).*mask);
	bright = nnz((img-usan>thT1).*mask);
	res = min(dark,bright)<thGeo1 && max(dark,bright)>thGeo2;

else
	res = 0;
end

end
