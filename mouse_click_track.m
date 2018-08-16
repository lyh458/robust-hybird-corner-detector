% % %% 读入图片并显示
% % %% 点击鼠标，返回点击位置坐标，并在图中标出
% % 
% % function mouse_click_track()
% % clear;clc;
% % [file_name, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    '选择图片');
% % im = imread([pathname, file_name]);
% % % im=imread('trees.tif');      %trees.tif是读入的图片名
% % imshow(im);                  %显示图片
% % set(gcf,'WindowButtonDownFcn',@MouseClickFcn);
% % Location 
% % 
% % 
% % function MouseClickFcn(src,event)
% % i=0;
% % pt=get(gca,'CurrentPoint');     %在当前坐标轴中获取鼠标点击的坐标位置
% % x=pt(1,1);
% % y=pt(1,2);
% % plot(x,y,'p', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'g');
% % global location = [y,x]
% 
% % clear all;clc;
% close all;
% [file_name, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    '选择图片');
% im = imread([pathname, file_name]);
% imshow(im); 
% hold on;
% [X,Y] = ginput;
% Location =[X,Y];
% plot(X(:,1),Y(:,1),'ro');

for i=1:length(Location)
    plot(Location(i,1),Location(i,2),'ro');
    str2=[repmat('  P',1,1) num2str(i)];
%     str2=[repmat('  X:',1,1) num2str(Location(i,1)) repmat(', Y:',1,1) num2str(Location(i,2))];
    text(Location(i,1),Location(i,2),cellstr(str2),'FontSize',5);
    pause(0.2)
end
% Location_round = round(Location);
