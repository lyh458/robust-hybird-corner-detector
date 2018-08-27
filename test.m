% step 1: 图像转换
% step 2: 计算角点
% step 3： 角点坐标系转换映射回原来坐标系
% step 4： 角点与原角点比较，计算matched/repeated的角点
[file_name, pathname] = uigetfile( ...
       {'*.bmp;*.tif;*.jpg;*.pcx;*.png;*.hdf;*.xwd;*.ras;*.pbm;*.pgm;*.ppm;*.pnm;*.gif', 'All MATLAB SUPPORTED IMAGE Files (*.bmp,*.tif,*.jpg,*.pcx,*.png,*.hdf,*.xwd,*.ras,*.pbm,.pgm,*.ppm,*.pnm,*.gif)'} ...
        ,'Pick a file');     % Load Image file and path names
newfilename = file_name(1:end-4); % 用于后面实验结果动态保存文件名
imgsrc = imread([pathname, file_name]);
k=1; 
th = 10; %Rotation angle
th=th*pi/180;
xscale = 1;
yscale = 1;
xshear = 0;
yshear = 0;
point_x = 10;
point_y = 10;
% d - yscale
TT=k*[cos(th) -sin(th); sin(th) cos(th)]*[xscale xshear; yshear yscale];
TTT=[ 1 0 0; 0 1 0; 0 0 1];
TTT(1:2,1:2)=TT;
% tform=maketform('affine',TTT);
% [image_2] = imtransform(image_1,tform);
tform=affine2d(TTT);
img = imwarp(imgsrc,tform);
[x,y] = transformPointsForward(tform,point_x,point_y);
[u,v] = transformPointsInverse(tform,x,y);
% X = [x1,x2]';
% Y = [y1,y2]';
% [U,V] = tforminv(tform,X,Y);

% imshow(img);