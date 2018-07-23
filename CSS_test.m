clear;
close all;
FileInfo1 = imfinfo('.\Datasets\corner2.gif');
[ImageData1,map1] = imread('.\Datasets\corner2.gif');
FileInfo2 = imfinfo('.\Datasets\corner2.gif');
[ImageData2,map2] = imread('.\Datasets\corner2.gif');
if(strcmp('truecolor',FileInfo1.ColorType) == 1)
   ImageData1 = im2uint8(rgb2gray(ImageData1));
elseif(strcmp('indexed',FileInfo1.ColorType) == 1)
   ImageData1 = im2uint8(ind2gray(ImageData1,map1));  
end  
if(strcmp('truecolor',FileInfo2.ColorType) == 1)
   ImageData2 = im2uint8(rgb2gray(ImageData2));
elseif(strcmp('indexed',FileInfo2.ColorType) == 1)
   ImageData2 = im2uint8(ind2gray(ImageData2,map2));  
end  
ori_im1 = ImageData1;
ori_im2 = ImageData2;
%imgauss1 = bilateralfilter(ori_im1, [3 3], 6, 0.2);%%Ë«ÏòÂË²¨
%imgauss2 = imfilter(ori_im1, fspecial('gaussian',[3 3], 6),'conv');


%[x y z]=size(imgauss1);
%if z==1
   % rslt=edge(imgauss2,'canny');
%elseif z==3
 %   img1=rgb2ycbcr(imgauss1);
  
 %dx1=edge(img1(:,:,1),'canny');
  %  dx1=(dx1*255);
   % img2(:,:,1)=dx1;
    %img2(:,:,2)=img1(:,:,2);
    %img2(:,:,3)=img1(:,:,3);
    %rslt=ycbcr2rgb(uint8(img2));
%end
%R=rslt;

%figure(); 
%imshow(ImageData1,[]); title('Original Image');
%figure(); 
 %imshow(imgauss1,[]); title('Gaussian1 Filted Image');
 %figure(); 
 %imshow(imgauss2,[]); title('Gaussian2 Filted Image');
 %figure(); 
 % imshow(rslt,[]); title('canny filter');
 [cout1,marked_img1] = CSS(ori_im1,[],[],[],0.2);
 size(cout1,1)
% descriptor1= vl_siftdescriptor(ori_im1, cout1);
 figure(1);
imshow(marked_img1);
title('Detected corners 1');
imwrite(marked_img1,'corner1.jpg');
[cout2,marked_img2] = CSS(ori_im2,[],[],[],0.2);
% [cout2,marked_img2] = CSS(ori_im2);
 size(cout2,1)
 %cout2(1,2)
  figure(2);
imshow(marked_img2);
title('Detected corners 2');
imwrite(marked_img2,'corner2.jpg');



%distRatio = 0.6;
%cout2t = cout2';
%dotprods=zeros(1,size(cout2,1));
%for i = 1 : size(cout1,1)
   % for j = 1:size(cout2,1)
        
  % dotprods(1,j) = sqrt((cout1(i,1)- cout2(j,1))^2+(cout1(i,2)- cout2(j,2))^2);        % Computes vector of dot products
     % Take inverse cosine and sort results\
    %end
    %[vals,indx] = sort(dotprods);
%vals
   % Check if nearest neighbor has angle less than distRatio times 2nd.

  % if (vals(1) < distRatio * vals(2))
%      match(i) = indx(1);
   %else
    %  match(i) = 0;
  % end
%end
%match
im3 = appendimages(marked_img1,marked_img2);
figure('Position', [0 0 size(im3,2) size(im3,1)]);
%figure(3);
colormap('gray');
imagesc(im3);
hold on;
%size(ori_im1,2)
%size(ori_im2,2)
%cols1 = size(marked_img1,1);
%for i = 1: size(cout1,1)
 % if (match(i) > 0)
  %  line([cout1(i,2) cout2(match(i),2)], ...
   %      [cout1(i,1) cout2(match(i),1)+cols1], 'Color', 'c');
  %end
%end
 %result = match(ori_im1,cout1,ori_im2,cout2);
   % result(1,intersect(find(result(1,:) > 0),find(result(2,:) == 0))) = 0;
    %result
    %pause;
    %while(length(find(result(1,:)>0)) > 3)     
%        result
      %  draw2(ImageData1,ImageData2,cout1,cout2,result);
        %find(result(1,:)>0)
       % pause;
        %[index index] = max(result(2,:));
       % result(1,index(1)) = 0;
       % result(2,index(1)) = 0;
        %result(1,I(1)) = result(2,I(1)) = 0
   % end
   % draw2(ImageData1,ImageData2,cout1,cout2,result);
%[pCornerMatch1,pCornerMatch2] = RegisterBasedConner(ori_im1,ori_im2,size(ori_im1,2),size(ori_im1,1),cout1,cout2);
%cols1 = size(marked_img1,1);
%for i = 1: size(cout2,1)
  %if (result(1,i) > 0)
  % line([cout1(result(1,i),2) cout2(i,2)], ...
   %     [cout1(result(1,i),1) cout2(i,1)+cols1], 'Color', 'g');
 % end
%end

UU = Corner_match(ori_im1,ori_im2,cout1,cout2);
cols1 = size(marked_img1,1);
for i = 1: size(UU,1)
   
    if UU(i,1)>0
  line([cout1(UU(i,1),2) cout2(UU(i,2),2)+cols1], ...
       [cout1(UU(i,1),1) cout2(UU(i,2),1)], 'Color', 'g');
    end
 
end
% for i = 1: size(UU,1)
%    
%     if UU(i,1)>0
%   line([cout1(UU(i,1),2) cout2(UU(i,2),2)], ...
%        [cout1(UU(i,1),1) cout2(UU(i,2),1)+cols1], 'Color', 'g');
%     end
%  
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%[ss1,tt1]=match2(ori_im1,size(cout1,1),cout1,ori_im2,size(cout2,1),cout2);
%[tt2,ss2]=match2(ori_im2,size(cout2,1),cout2,ori_im1,size(cout1,1),cout1);
%SmiliarJac1(ori_im1,ori_im2,cout1,cout2);
%cols1 = size(marked_img1,1);
%point = [];
%for ii = 1: size(ss1,1)
 %   mm = ss1(ii,1);
  %  nn = tt1(ii,1);
   % for jj = 1:size(ss2,1)
    %if tt2(ii,1)==nn&&ss2(jj,1) ==mm
     %   point(1,jj) = mm;
      %  point(2,jj) = nn;
    %else
     %   point(1,jj) =0;
      %  point(2,jj) =0;
    %end
    %end
%end
    
%for i = 1: size(point,2)
   
 %   if point(1,i)>0
  % line([cout1(point(1,i),2) cout2(point(2,i),2)], ...
   %     [cout1(point(1,i),1) cout2(point(2,i),1)+cols1], 'Color', 'g');
    %end
 
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%[ss1,tt1]=match2(ori_im1,size(cout1,1),cout1,ori_im2,size(cout2,1),cout2);
%cols1 = size(marked_img1,1);
%for i = 1: size(ss1,1)
   
 % line([cout1(ss1(i,1),2) cout2(tt1(i,1),2)], ...
  %     [cout1(ss1(i,1),1) cout2(tt1(i,1),1)+cols1], 'Color', 'g');
    
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%size(res2,2)
%res2
%res1 = match1(ori_im2,size(cout2,1),cout2,ori_im1,size(cout1,1),cout1);
%size(res1,2)
%for i=1:size(res2,2)
 %   idx = res2(1,i);
  %      if res1(1,idx)==i
   %         res2(1,i)=idx;
    %    else

     %        res2(1,i) = 0;
      %  end
    %end
  
%res2
%cols1 = size(marked_img1,1);
%for i = 1: size(res2,2)
 %  mm =  res2(1,i);
 
  %if (mm > 0)
   %line([cout1(i,2) cout2(mm,2)], ...
  %      [cout1(i,1) cout2(mm,1)+cols1], 'Color', 'g');
  %end
%end
%delt = uint8(size(ori_im1,1)/4.0);

%cout1 = cout1';
%cout2 = cout2';
%[m1,m2,cormat] = matchbycorrelation(marked_img1, cout1, marked_img2, cout2, 15, delt);
%m1
%m2
%cols1 = size(ImageData1,1);
%for i = 1: size(m1,2)

  
 %  line([m1(2,i) m2(2,i)], ...
  %     [m1(1,i) m2(1,i)+cols1], 'Color', 'g');
  
%end


hold off;

%num = sum(match > 0);
%fprintf('Found %d matches.\n', num);
