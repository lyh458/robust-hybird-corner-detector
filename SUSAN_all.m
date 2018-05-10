%% SUSAN 1
% close all;
% clc;
% 
% img=imread('lab.gif');
% if (size(img,3) ~= 1)
%     img = rgb2gray(img);
% else
%     img = img;
% end
% imshow(img);
% [m n]=size(img);
% img=double(img);
% 
% t=45;   %ģ���������ػҶȺ���Χ�ҶȲ�����ֵ���Լ�����
% usan=[]; %��ǰ���غ���Χ�����ز����t���µĸ���
% %��������37�����ص�ģ��
% for i=4:m-3         %û������Χ��չͼ������ͼ�����С
%    for j=4:n-3
%         tmp=img(i-3:i+3,j-3:j+3);   %�ȹ���7*7��ģ�壬49������
%         c=0;
%         for p=1:7
%            for q=1:7
%                 if (p-4)^2+(q-4)^2<=12  %������ɸѡ������ģ������һ��Բ��
%                    %   usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
%                     if abs(img(i,j)-tmp(p,q))<t  %�жϻҶ��Ƿ������t���Լ����õ�
%                         c=c+1;
%                     end
%                 end
%            end
%         end
%         usan=[usan c];
%    end
% end
% 
% g=2*max(usan)/3; %ȷ���ǵ���ȡ��������ֵ�Ƚϸ�ʱ����ȡ����Ե���Լ�����
% for i=1:length(usan)
%    if usan(i)<g
%        usan(i)=g-usan(i);
%    else
%        usan(i)=0;
%    end
% end
% imgn=reshape(usan,[n-6,m-6])';
% figure;
% imshow(imgn)
% 
% %�Ǽ�������
% [m n]=size(imgn);
% re=zeros(m,n);
% for i=2:m-1
%    for j=2:n-1
%         if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
%             re(i,j)=1;
%         else
%             re(i,j)=0;
%         end
%    end
% end
% 
% figure;
% imshow(re==1);

%% SUSAN 2
% im=imread('.\Datasets\corner2.gif');
% 
% threshold =0.25;
% 
% % image_out = susan(im,0.25);
% 
% % ���ܣ�ʵ������SUNSAN���ӽ��б�Ե���
% % ���룺image_in-����Ĵ�����ͼ��
% %       threshold-��ֵ
% % �����image_out-����Ե���Ķ�ֵͼ��
% 
% % �������ͼ�����ת����double��
% d = length(size(im));
% if d==3
%     image=double(rgb2gray(im));
% elseif d==2
%     image=double(im);
% end
% 
% % ����SUSANģ��
% 
% mask = ([ 0 0 1 1 1 0 0 ;
%     0 1 1 1 1 1 0;
%     1 1 1 1 1 1 1;
%     1 1 1 1 1 1 1;
%     1 1 1 1 1 1 1;
%     0 1 1 1 1 1 0;
%     0 0 1 1 1 0 0]);
% 
% R=zeros(size(image));
% % ����USAN ����
% nmax = 3*37/4;
% 
% % ���Ǳ�ԵЧӦ��������չ��ͼ��
%  [a b]=size(image);
% new=zeros(a+7,b+7);
% [c d]=size(new);
% 
% % ͼ���Ե��չ��3��0����
% new(4:c-4,4:d-4)=image;
% 
% for i=4:c-4
% 
%     for j=4:d-4
% 
%         current_image = new(i-3:i+3,j-3:j+3);
%         current_masked_image = mask.*current_image;
% 
%         %   ����susan_threshold����������ֵ�Ƚϴ���
% 
%         [a b]=size(image);
%         intensity_center = image(round((a+1)/2),round((b+1)/2));
% 
%         temp1 = (image-intensity_center)/threshold;
%         temp2 = temp1.^6;
%         current_thresholded = exp(-1*temp2);
%         g=sum(current_thresholded(:));
% 
%         if nmax<g
%             R(i,j) = g-nmax;
%         else
%             R(i,j) = 0;
%         end
%     end
% end
% 
% image_out=R(4:c-4,4:d-4);
% imshow(image_out);

%% SUSAN3 �ǵ������ӵ� MATLAB ʵ��
clc;
clear;
clear all;

[filename,pathname,~]=uigetfile('*.gif','*.jpg' , ' ѡ�� JPG ��ʽͼƬ ' );

if ~ischar(filename)
    
    return
    
end

str=[pathname filename];

pic=imread(str);

if length(size(pic))==3
    
    img=rgb2gray(pic);
else
    img = pic;
    
end

img=double(img);

if isa(img, 'uint8')
    img = img; 
else
    img = im2uint8(img);
end 

[a,b]=size(img);

timg=zeros(a+6,b+6);

[c,d] = size(timg);

timg(4:c-3,4:d-3)=img; %��չͼ���Ե3������,�ܱ�3������Ϊ0

% img=timg;

t=20; %��ֵ

USAN=[]; %���ڴ�� USAN
for i=4:c-3
    for j=4:d-3
        tmp=timg(i-3:i+3,j-3:j+3); % ��Χ��7X7����
        cnt=0; %����ר��, ͳ�� Բ���������������������ص����
        for p=1:7 
            for q=1:7
                if (p-4)^2+(q-4)^2<=12 %�뾶һ ���� 3~4֮��   
                    if abs(timg(i,j)-tmp(p,q))<t
                        cnt=cnt+1;
                    end
                    
                end
                
            end
        end
        USAN=[USAN cnt];
    end   
end

g=1*max(USAN)/2; %��������ֵ

for k=1:length(USAN)
    
    if USAN(k)<g
        
        USAN(k)=g-USAN(k); %�������,ʹ�� USAN ȡ�ֲ���� 
    else 
        USAN(k)=0;
        
    end
    
end

imgn=reshape(USAN,[a,b])'; % USAN�����ųɶ�άͼ��

% imgn=fliplr(imrotate(imgn,-90)); %����ͼ��
% loc=[];
% for i=2:a-1
%     for j=2:b-1
%         sq=imgn(i-1:i+1,j-1:j+1);
%         sq=reshape(sq,1,9); 
%         sq=[sq(1:4),sq(6:9)];
%         if imgn(i,j)>sq %�ֲ��Ǽ���ֵ����  
%             loc=[loc;[j,i]];
%         end     
%     end  
% end
% figure('name','SUSAN corner');
% imshow(pic);%ԭͼ
% hold on;
% plot(loc(:,1),loc(:,2),'go');

[M,N] = size(imgn);

re = zeros(M,N);
for i=2:M-1
   for j=2:N-1 
        if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
            re(i,j)=1;
        else
            re(i,j)=0;
        end
   end
end

figure('name','SUSAN corner');
imshow(pic)
hold on;
% [x,y]=find(re==1);
% plot(y,x,'go')
[Corner_Location(:,1),Corner_Location(:,2)]=find(re==1);
plot(Corner_Location(:,2),Corner_Location(:,1),'go')


% figure(6)
% imshowpair(pic,pic,'montage' );
% hold on
% plot(loc(:,1)+size(pic,2),loc(:,2),'*');
% hold off
% figure(6)
% imshowpair(pic,pic,'montage' );
% hold on;
% str1=[repmat('  X:',length(loc)) num2str(loc(:,1)) repmat(', Y:',length(loc)) num2str(loc(:,2))];
% plot(loc(:,1)+size(pic,2),loc(:,2),'*');
% text(loc(:,1)+size(pic,2),loc(:,2),cellstr(str1),'FontSize',5);


%% SUSAN 4 Ч������
% clear;
% clc;
% % ��ȡͼ��
% Image=imread('Corner2.gif');
% if (size(Image,3) ~= 1)
%     Image = rgb2gray(Image);
% else
%     Image = Image;
% end
% % ת��Ϊ�Ҷ�ͼ��
% %Image=rgb2gray(Image);
% % ��ʾͼ��
% %imshow(Image);
% % ��ȡͼ��߿����ң�
% [ImageHeight,ImageWidth]=size(Image);
% % ��һ��û̫���Ҫ
% %Image=double(Image);
% % �жϻҶ��������ֵ
% threshold=45;  
% % ��ǰ���غʹ��������ز����t���µĸ����������Ƶĸ���
% usan=[];
% % ����������Ϊ���ĵĴ����ڰ�����
% % ����37�����ص�Բ���ڣ����Ϊ12*pi=37���������sqrt��12��Ϊ�뾶��ԭ
% % û������Χ��չͼ������ͼ�����С
% for i=4:ImageHeight-3         
%    for j=4:ImageWidth-3 
%         %��ԭͼ�н�ȡ7*7����������������ѡԲ��
%         tmp=Image(i-3:i+3,j-3:j+3);  
%         %c��ʾ�Ҷ�ֵ����ĳ̶ȣ�Խ��Խ���
%         c=0;
%         for p=1:7
%            for q=1:7
%                %��7*7��������ѡȡԲ������������
%                 if (p-4)^2+(q-4)^2<=12 
%                     %usan(k)=usan(k)+exp(-(((img(i,j)-tmp(p,q))/t)^6));
%                     %�жϻҶ��Ƿ������t���Լ����õ�
%                     if abs(Image(i,j)-tmp(p,q))<threshold  
%                         c=c+1;
%                     end
%                 end
%            end
%         end
%         usan=[usan c];
%    end
% end
% %�൱�ڽ�һ��������ֵ����threshold�Ļ����Ͻ�һ�����ٽǵ����
% g=2*max(usan)/3;
% for i=1:length(usan)
%    if usan(i)<g 
%        usan(i)=g-usan(i);
%    else
%        usan(i)=0;
%    end
% end
% % ����usan��һά�ģ�����Ҫ���±任Ϊ��ά����Ӧͼ��λ��
% imgn=reshape(usan,[ImageWidth-6,ImageHeight-6])';
% %figure;
% %imshow(imgn)
% %�Ǽ�������
% [m n]=size(imgn);
% re=zeros(m,n);
% for i=2:m-1
%    for j=2:n-1 
%         if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
%             re(i,j)=1;
%         else
%             re(i,j)=0;
%         end
%    end
% end
% figure;
% imshow(Image)
% hold on;
% [x,y]=find(re==1);
% plot(y,x,'*')