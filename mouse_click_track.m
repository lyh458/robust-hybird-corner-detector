% % %% ����ͼƬ����ʾ
% % %% �����꣬���ص��λ�����꣬����ͼ�б��
% % 
% % function mouse_click_track()
% % clear;clc;
% % [file_name, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    'ѡ��ͼƬ');
% % im = imread([pathname, file_name]);
% % % im=imread('trees.tif');      %trees.tif�Ƕ����ͼƬ��
% % imshow(im);                  %��ʾͼƬ
% % set(gcf,'WindowButtonDownFcn',@MouseClickFcn);
% % Location 
% % 
% % 
% % function MouseClickFcn(src,event)
% % i=0;
% % pt=get(gca,'CurrentPoint');     %�ڵ�ǰ�������л�ȡ�����������λ��
% % x=pt(1,1);
% % y=pt(1,2);
% % plot(x,y,'p', 'MarkerSize', 15, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'g');
% % global location = [y,x]
% 
% % clear all;clc;
% close all;
% [file_name, pathname] = uigetfile({'*.gif'; '*.bmp'; '*.jpg';'*.png'},    'ѡ��ͼƬ');
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
