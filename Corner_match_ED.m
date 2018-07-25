function  [Corner_match1,Corner_match2] =Corner_match_ED(Corner1,Corner2)
% Match corner between two corner sets with Euclidean distance
%   Input:
%   Corner1 - corner set 1,
%   Corner2 - corner set 2,
%   Outout:
%   Corner_match1 - matched corners coordinate in orner set 1,
%   Corner_match1 - matched corners coordinate in orner set 2.
Corner_match1=[];
Corner_match2=[];
for i=1:length(Corner1)
    D = sqrt((Corner2(:,1)-Corner1(i,1)).^2+(Corner2(:,2)-Corner1(i,2)).^2);
    [minD,j] = min(D);
    if minD < 4
        Corner_match1 = [Corner_match1;Corner1(i,1),Corner1(i,2)];
        Corner_match2 = [Corner_match2;Corner2(j,1),Corner2(j,2)];
    end
end