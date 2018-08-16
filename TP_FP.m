function [ TPR, FPR, ACU, LE ] = TP_FP( Location, Location_ground_truth,img )
for i=1:length(Location)
    D = [];
    for j=1:length(Location_ground_truth)
        d_temp=norm(Location(i,:)-round(Location_ground_truth(j,:)));
        D = [D;d_temp];
    end
    [minD,Flag_ground_truth(i)] = min(D);
    if minD<=4
        % true corner(true positive)
        Flag(i) = 1;
    else
        % false corner(false positive)
        Flag(i) = 0;
    end
end
[row,col] = size(img);
TP = length(find(Flag));
FP = length(Location)-length(find(Flag));
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
for i=1:length(Flag)
    d_temp = Flag(i)*norm(Location(i,:)-Location_ground_truth(Flag_ground_truth(i),:));
    D = [D,d_temp];
end
LE = sum(D)/TP;


