clear all;
close all;
clc;
f=imread('corner2.gif');
figure(1);
imshow(f)
if (size(f,3) ~= 1)
    img = rgb2gray(f);
else
    img = f;
end
[m n]=size(img);
disp('m='),disp(m);
disp('n='),disp(n);
img=double(img);
usan=zeros(size(img));
zxx=zeros(size(img));
zxy=zeros(size(img));
colorlevel=256;
t=25;
%膨胀和腐蚀预处理
SE=strel('line',5,5);
img=imerode(img,SE);
img=imdilate(img,SE);
for ii=4:m-3
    for jj=4:n-3
        k=0;
        x=0;
        y=0;
        c=0;
       % SUSAN
             for i=-3:3
                 for j=-3:3
                    if abs(i)+abs(j)<4
                       c=exp(-((img(ii+i,jj+j)-img(ii,jj))/t)^6);
                         k=k+c;   
   
                         %伪角点去除-重心
                    if c>0.1
                        x=x+ii+i;
                        y=y+jj+j;
                    end    
                    end
            
             usan(ii,jj) = k ;
             if usan(ii,jj)==1
                 zxx(ii,jj)=ii;
                 zxy(ii,jj)=jj;
             else
             x=x/k;
             y=y/k;
             zxx(ii,jj)=x;
             zxy(ii,jj)=y;
             end
                 end
             end
    end
        end
   
   figure(2);
   imshow(uint8(usan));  
   y=max(max(usan));
   g=y/2;
%初始角响应  
  R=zeros(size(usan));
   for ii=4:m-3    
       for jj=4:n-3
           if usan(ii,jj)<=g
               r=g-usan(ii,jj);
           else 
               r=0;
           end
           R(ii,jj)=r;
       end
   end
figure(3);
imshow(uint8(R));
[v,c]=size(R);
im_mixmum=zeros(v,c);
T=y/4;
%非极大值抑制
for i=3:v-2
    for j=3:c-2;
        matrixS=R(i-2:i+2,j-2:j+2);
        maxV=max(max(matrixS));
        pp=size(find(matrixS==maxV));
        if R(i,j)==maxV&maxV>T&pp==1
            im_mixmum(i,j)=1;
        end
    end
end
%重心
for i=3:v-2
    for j=3:c-2
        if im_mixmum(i,j)==1
            if abs(i-zxx(i,j))<=1
                if abs(j-zxy(i,j))<=1
                    im_mixmum(i,j)=0;
                end
            end
        end
    end
end
cx=zeros(size(img));
%几何关系
for i=4:v-3
    for j=11:c-10
        m=0;
        n=0;
  %左右
        if im_mixmum(i,j)==1
            for ii=-3:3
                for jj=-10:0
                    if im_mixmum(i+ii,j+jj)==1
                        m=m+1;
                    end
                end
            end
            for ii=-3:3
                for jj=1:10
                    if im_mixmum(i+ii,j+jj)==1
                        n=n+1;
                    end
                end
            end
          
            if m>=2&n>=1
                cx(i,j)=1;
            end
           
                    
        end
    end
end
for i=11:v-10
    for j=11:c-10
        m=0;
        n=0;
       p=0;
       q=0;
        if im_mixmum(i,j)==1
            for ii=-8:0
                for jj=-10:0
                    if im_mixmum(i+ii,j+jj)==1
                        m=m+1;
                    end
                end
            end
            for ii=0:8
                for jj=0:10
                    if im_mixmum(i+ii,j+jj)==1
                        n=n+1;
                    end
                end
            end
          for ii=-8:0
                for jj=1:10
                    if im_mixmum(i+ii,j+jj)==1
                        q=q+1;
                    end
                end
          end
            for ii=0:8
                for jj=-10:-1
                    if im_mixmum(i+ii,j+jj)==1
                        p=p+1;
                    end
                end
            end
            if m>=2&n>=2
                cx(i,j)=1;
            end
            if p>=1&q>=1
                cx(i,j)=1;
            end
             
           
                    
        end
    end
end
            
for i=3:v-2
    for j=3:c-2
        if cx(i,j)==1
           im_mixmum(i,j)=0;
        end
    end
end
       
   [corner_rr,corner_cc]=find(im_mixmum==1);
   figure(1);
   hold on;
   plot(corner_cc,corner_rr,'r.');
   hold off;
