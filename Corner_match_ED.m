function  [Corner_match,Corner_match1,Corner_match2] =Corner_match_ED(Corner1,Corner2)
% Match corner between two corner sets with Euclidean distance
%   Input:
%   Corner1 - corner set 1,
%   Corner2 - corner set 2,
%   Outout:
%   Corner_match1 - matched corners coordinate in orner set 1,
%   Corner_match1 - matched corners coordinate in orner set 2.
Corner_match1=[];
Corner_match2=[];
Corner_match_temp=[];
for i=1:length(Corner1)
    D = sqrt((Corner2(:,1)-Corner1(i,1)).^2+(Corner2(:,2)-Corner1(i,2)).^2);
    [minD,j] = min(D);
    if minD < 5
        Corner_match1 = [Corner_match1;Corner1(i,1),Corner1(i,2)];
        Corner_match2 = [Corner_match2;Corner2(j,1),Corner2(j,2)];
        Corner_match_temp = [Corner_match_temp;round((Corner1(i,1)+Corner2(j,1))/2),round((Corner1(i,2)+Corner2(j,2))/2)];
    end
end

Corner_match = [];
DS = [1 1];
tol = 5;
[C,IA]=uniquetol(Corner_match_temp, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
for m = 1:length(IA)
    if(length(IA{m})==1)
        Corner_match(m,1) = Corner_match_temp(IA{m},1);
        Corner_match(m,2) = Corner_match_temp(IA{m},2);
    else
        Corner_match(m,1) = round(mean(Corner_match_temp(IA{m},1)));
        Corner_match(m,2) = round(mean(Corner_match_temp(IA{m},2)));
    end
end
% for i=1:length(Corner_match_temp)
%     for j=1:length(Corner_match_temp)
%         d = sqrt((Corner_match_temp(i,1)-Corner1(j,1)).^2+(Corner2(i,2)-Corner1(j,2)).^2);
%         if d<5 && i~=j
%             
%         else
%             
%         end
%     end
% end