% A robust CSS corner detector based on the turning angle curvature of image gradients
%
%   Link:https://github.com/bbenligiray/robust-css-corners
%
%   Code used in the following paper:
%
%   C. Topal; K. ?zkan; B. Benligiray; C. Akinlar, "A robust CSS corner detector based on the turning angle curvature of image gradients," Proc. IEEE Int. Conf. Acoust., Speech and Signal Process. (ICASSP), 2013.
%
% RCSS code is implemented by Cihan Topal, and it is not open source. Run this build on a 64-bit Windows machine.

function [corners] = RCSS(I, params)
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

%   Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   type (2 for certaincorner, 1 for corner, 3 for T-corner and 0 for invalid corner)
% 	x
% 	y
% 	angle
% 	index
% 	segID

if isempty(params)
    params = [50,1,10,30,5,25,0.25,6,160,30,0];
end

% transpose the image because C/C++ uses row-major order
I = I';
[width, height] = size(I);
I = I(:);

res = EDCornersMex(I, width, height, params(1), params(2), params(3), params(4), params(5), params(6), params(7), params(8), params(9), params(10), params(11));

corners_temp = [];

for i = 1:size(res, 2)
    if (res(4, i) ~= 4)
        corners_temp(end + 1, :) = [res(2, i) res(3, i)];
    end
end
corners = [];
corners = [corners_temp(:,2),corners_temp(:,1)];
end