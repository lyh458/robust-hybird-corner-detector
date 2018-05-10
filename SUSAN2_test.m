function [ Corner_Location ] = SUSAN2_test(img,t,c)
% t��ģ���������صĻҶ�ֵ��ģ�����������ػҶ�ֵ�Ĳ���Ҷ����ƶ�
% c����ĳ�����ص��USANֵС��ĳһ�ض���ֵ����õ㱻��Ϊ�ǳ�ʼ�ǵ㣬���У�g�����趨ΪUSAN����������һ�룬��ʱc=0.5��ֵ�Ƚϸ�ʱ����ȡ����Ե��
% clear all;
% close all;
% clc;
%
% img=imread('i.jpg');
% img=rgb2gray(img);
% imshow(img);
[nrow,ncol]=size(img);
img=double(img);

%% ��չͼ��
img_tmp = zeros(nrow+6,ncol+6);
[nrow_tmp,ncol_tmp] = size(img_tmp);
img_tmp(4:nrow_tmp-3,4:ncol_tmp-3) = img; %��չͼ���Ե3������,�ܱ�3������Ϊ0

% t=20;   %ģ���������ػҶȺ���Χ�ҶȲ�����ֵ���Լ�����
usan=[]; %��ǰ���غ���Χ�����ز����t���µĸ���
%��������37�����ص�ģ��
for i=4:nrow_tmp-3         
    for j=4:ncol_tmp-3
        tmp=img_tmp(i-3:i+3,j-3:j+3);   %�ȹ���7*7��ģ�壬49������
        cnt=0;
        for p=1:7
            for q=1:7
                if (p-4)^2+(q-4)^2<=12  %������ɸѡ������ģ������һ��Բ��
                    %   usan(k)=usan(k)+exp(-(((img_tmp(i,j)-tmp(p,q))/t)^6));
                    if abs(img_tmp(i,j)-tmp(p,q))<t  %�жϻҶ��Ƿ������t���Լ����õ�
                        cnt=cnt+1;
                    end
                end
            end
        end
        usan=[usan cnt];
    end
end

g=c*max(usan); %ȷ���ǵ���ȡ��������ֵ�Ƚϸ�ʱ����ȡ����Ե���Լ�����
for i=1:length(usan)
    if usan(i)<g
        usan(i)=g-usan(i);
    else
        usan(i)=0;
    end
end
imgn=reshape(usan,[ncol,nrow])';
% figure;
% imshow(imgn)

%�Ǽ�������
[nrow,ncol]=size(imgn);
Corner=zeros(nrow,ncol);

for i=2:nrow-1
    for j=2:ncol-1
        if imgn(i,j)>max([max(imgn(i-1,j-1:j+1)) imgn(i,j-1) imgn(i,j+1) max(imgn(i+1,j-1:j+1))]);
            Corner(i,j)=1;
        else
            Corner(i,j)=0;
        end
    end
end

% figure;
% imshow(re==1);

Corner_Location=[];

[Corner_Location(:,1),Corner_Location(:,2)]=find(Corner==1);

% for i=1:nrow
%     for j=1:ncol
%         if Corner(i,j)==1
%             k=k+1;
%             Corner_Location(k,:)=[i,j];
%         end
%     end
% end

% %ȥ���ܼ��ǵ㣬��ʾƽ��ֵ
% k=0;
% boundary = 8;
% for i=boundary:nrow-boundary+1
%     for j=boundary:ncol-boundary+1
%         column_ave=0;
%         row_ave=0;
%         m=0;
%         if Corner(i,j)==1
%             for x=i-3:i+3  %7*7����
%                 for y=j-3:j+3
%                     if Corner(x,y)==1
%                         % ������ƽ������Ϊ�ǵ����꣬������ü���ƽ��������ƽ�����꣬�Խǵ����ȡ���岻��
%                         row_ave=row_ave+x;
%                         column_ave=column_ave+y;
%                         m=m+1;
%                         
%                     end
%                 end
%             end
%         end
%         if m>0 %��Χ��ֹһ���ǵ�
%             k=k+1;
%             Corner_Location(k,:) = [column_ave/m,row_ave/m];
%         end
%     end;
% end;

end


