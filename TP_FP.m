% function [ TPR, FPR, ACU, LE ] = TP_FP( Location, Location_ground_truth,img )
function [ TP, TPR, FP, FPR, ACU, LE ] = TP_FP( Location, Location_ground_truth,img )
True_corner =[];
Ground_truth_temp = [];
for i=1:length(Location)
    D = [];
    for j=1:length(Location_ground_truth)
        d_temp=norm(Location(i,:)-round(Location_ground_truth(j,:)));
        D = [D;d_temp];
    end
    [minD,Flag_ground_truth(i)] = min(D);
    if minD<4
        % true corner(true positive)
        True_corner = [True_corner;Location(i,:)];
        Ground_truth_temp = [Ground_truth_temp;Location_ground_truth(Flag_ground_truth(i),:)];
        Flag(i) = 1;
    else
        % false corner(false positive)
        Flag(i) = 0;
    end
end
[True_corner,ia,ic] = unique(True_corner,'rows');
Ground_truth_temp = Ground_truth_temp(ia,:);
[Ground_truth_temp,ia1,ic1] = unique(Ground_truth_temp,'rows');
True_corner = True_corner(ia1,:);
[row,col] = size(img);
TP = length(True_corner);
FP = length(Location)-length(True_corner);
TN = row*col-length(Location)-(length(Location_ground_truth)-TP); % 真负类：负类被识别成负类
FN = length(Location_ground_truth)-TP;% 假负类：正类被识别成负类
% TPR: true positive rate
TPR = TP/(TP+FN);
% FPR: false positive rate
FPR = FP/(FP+TN);

% ACU
ACU = (TP/length(Location)+TP/length(Location_ground_truth))*0.5;
% localization erros
D=[];
for i=1:length(True_corner)
    d_temp = norm(True_corner(i,:)-round(Ground_truth_temp(i,:)));
    D = [D,d_temp];
end
LE = sum(D)/TP;


