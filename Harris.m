%Source Code: http://blog.csdn.net/anymake_ren/article/details/21298807

function [Corner_Location, CRF] = Harris( gray_img )
%%%Prewitt Operator Corner Detection.m
%%%ʱ���Ż�--����������ȡ��ķ�����Harris�ǵ�
%%
img = im2uint8(gray_img);

dx = [-1 0 1;-1 0 1;-1 0 1];  %dx������Prewitt���ģ��
Ix2 = filter2(dx,img).^2;
Iy2 = filter2(dx',img).^2;
Ixy = filter2(dx,img).*filter2(dx',img);

%���� 9*9��˹���ڡ�����Խ��̽�⵽�Ľǵ�Խ�١�
h= fspecial('gaussian',9,2);
A = filter2(h,Ix2);       % �ø�˹���ڲ��Ix2�õ�A
B = filter2(h,Iy2);
C = filter2(h,Ixy);
[nrow,ncol] = size(img);
Corner = zeros(nrow,ncol); %zeros��������һ��ȫ����󣬹ʾ���Corner���������ѡ�ǵ�λ��,��ֵȫ�㣬ֵΪ1�ĵ��ǽǵ�

%����t:��(i,j)������ġ����ƶȡ�������ֻ�����ĵ������������˸��������ֵ֮����
%��-t,+t��֮�䣬��ȷ������Ϊ���Ƶ㣬���Ƶ㲻�ں�ѡ�ǵ�֮��
t=20;

%�Ҳ�û��ȫ�����ͼ��ÿ���㣬���ǳ�ȥ�˱߽���boundary�����أ�Ҳ���Ǵӵ�8�е�8�п�ʼ������
%��Ϊ���Ǹ���Ȥ�Ľǵ㲢�������ڱ߽���
%���˾�����һ�����ǵ���ҪĿ�����ҳ������ǽǵ�ĵ㣬��С��Χ���ӿ������ٶȡ�
%����˼����������ĵ㣨i,j����Χ8��������7��8����Ҷ�ֵ��֮���ƣ���ô�����ĵ�Ӧ�ô���ƽ̹���򣬲�����Ϊ�ǵ㣬
%������ĵ㣨i,j����Χֻ��1�������û�е���֮���ƣ���ô�����ĵ�Ҳ������Ϊ�ǵ㡣
boundary=2;
for i=boundary:nrow-boundary+1
    for j=boundary:ncol-boundary+1
        nlike=0; %���Ƶ����
        if img(i-1,j-1)>img(i,j)-t && img(i-1,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i-1,j)>img(i,j)-t && img(i-1,j)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i-1,j+1)>img(i,j)-t && img(i-1,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i,j-1)>img(i,j)-t && img(i,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i,j+1)>img(i,j)-t && img(i,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j-1)>img(i,j)-t && img(i+1,j-1)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j)>img(i,j)-t && img(i+1,j)<img(i,j)+t
            nlike=nlike+1;
        end
        if img(i+1,j+1)>img(i,j)-t && img(i+1,j+1)<img(i,j)+t
            nlike=nlike+1;
        end
        if nlike>=2 && nlike<=6
            Corner(i,j)=1;%�����Χ��2~6�����Ƶ㣬��(i,j)���ǽǵ�
        end;
    end;
end;
CRF = zeros(nrow,ncol);    % CRF��������ǵ���Ӧ����ֵ,��ֵȫ��
CRFmax = 0;                % ͼ���нǵ���Ӧ���������ֵ������ֵ֮��
m=0.05; %һ��ȡֵΪ0.04~0.06
% ����CRF
% �����ϳ���CRF(i,j) =det(M)/trace(M)����CRF����ô��ʱӦ�ý������105�е�
% ����ϵ��k���ô�һЩ��k=0.1�Բɼ����⼸��ͼ����˵��һ���ȽϺ���ľ���ֵ
for i = boundary:nrow-boundary+1
    for j = boundary:ncol-boundary+1
        if Corner(i,j)==1  %ֻ��ע��ѡ��
            M = [A(i,j) C(i,j);
                C(i,j) B(i,j)];
            %�ǵ���Ӧ����
            CRF(i,j) = det(M)-m*(trace(M))^2;
            if CRF(i,j) > CRFmax
                CRFmax = CRF(i,j);
            end;
        end
    end;
end;
% CRFmax
t=0.01; 
CRF_threshold = t*CRFmax;
% CRF����ֱ�Һܴ��ʱ���ǽǵ㣬CRFR����ֱ�Һ�С��ƽ̹������ô��ô�綨�ܴ�ͺ�С��
% �����t�����ã�����t����Ƚϴ�Щ�����������ɴ�ɱһǧ���ɷŹ�һ����Ч��
% ����ͨ��һ��3*3�Ĵ������жϵ�ǰλ���Ƿ�Ϊ�ǵ�
for i = boundary:nrow-boundary+1
    for j = boundary:ncol-boundary+1
        if Corner(i,j)==1  % ֻ��ע��ѡ��İ�����(�Ǽ���ֵ���ƣ�3*3����)
            if CRF(i,j) > CRF_threshold && CRF(i,j) >CRF(i-1,j-1) ......%?????ΪʲôҪCRF(i,j) > t*CRFmax����������֪
                    && CRF(i,j) > CRF(i-1,j) && CRF(i,j) > CRF(i-1,j+1) ......
                    && CRF(i,j) > CRF(i,j-1) && CRF(i,j) > CRF(i,j+1) ......
                    && CRF(i,j) > CRF(i+1,j-1) && CRF(i,j) > CRF(i+1,j)......
                    && CRF(i,j) > CRF(i+1,j+1)
%                 count=count+1;%����ǽǵ㣬count��1
%                 CRF(i,j)
%                 t*CRFmax
            else % �����ǰλ�ã�i,j�����ǽǵ㣬����Corner(i,j)��ɾ���Ըú�ѡ�ǵ�ļ�¼
                Corner(i,j) = 0;
            end;
        end;
    end;
end;
% disp('�ǵ����');
% disp(count)
% corner_count = count;

k=0;
Corner_Location=[];
% �������棬m��������ͼ���H����n��������ͼ���W����,ʵ�ʶ�Ӧ����ʱ����x=n��y=m.
[Corner_Location(:,1),Corner_Location(:,2)]=find(Corner==1);

% %ȥ���ܼ��ǵ㣬��ʾƽ��ֵ
% k=0;
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

