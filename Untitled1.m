% A=[1,2,3,4,1;5,6,7,8,1;9,10,11,12,1;13,14,15,16,1;1,2,3,4,1];
% [r,c]=size(A);
% z=0;
% i=3;
% Aj=3;
% x=i-2:i+2;
% y=j-2:j+2;
% if (i-x)(j-y)~=0
%     z=z+1;
% end

figure(5)
imshow(imgsrc);%ԭͼ
hold on;
y=(Corner_diff_temp(:,1));
x=(Corner_diff_temp(:,2));
str=[repmat('  X:',length(x),1) num2str(x) repmat(', Y:',length(x),1) num2str(y)];
plot(x,y,'ro');
text(x,y,cellstr(str),'FontSize',5);

