function ROI=LabelBox(filename)
Mat=imread(filename);
imshow(Mat);
mouse=imrect;
pos=getPosition(mouse);% x1 y1 w h
ROI=[pos(1) pos(2) pos(1)+pos(3) pos(2)+pos(4)]; 
end
% 
% function BoxTable=getAllbox(folder)
% fileFolder=fullfile(folder);
% dirOutput=dir(fullfile(fileFolder,'*.jpg'));
% filenames={dirOutput.name}'; %апоРа©
% rois=[];
% for i=1:length(filenames)
%     roi=LabelBox(filenames{i});
%     rois=[rois;roi];
% end
% BoxTable=table(filenames,rois);
% end