%Source Code: http://blog.csdn.net/anymake_ren/article/details/21298807

function [Corner_Location,CRF] = Harris_test( gray_img )
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

CRF = zeros(nrow,ncol);    % CRF��������ǵ���Ӧ����ֵ,��ֵȫ��
CRFmax = 0;                % ͼ���нǵ���Ӧ���������ֵ������ֵ֮��
m=0.05; %һ��ȡֵΪ0.04~0.06
% ����CRF
% �����ϳ���CRF(i,j) =det(M)/trace(M)����CRF����ô��ʱӦ�ý������105�е�
% ����ϵ��k���ô�һЩ��k=0.1�Բɼ����⼸��ͼ����˵��һ���ȽϺ���ľ���ֵ
for i = 1:nrow
    for j = 1:ncol
        M = [A(i,j) C(i,j);
            C(i,j) B(i,j)];
        %�ǵ���Ӧ����
        CRF(i,j) = det(M)-m*(trace(M))^2;
        if CRF(i,j) > CRFmax
            CRFmax = CRF(i,j);
        end;
    end;
end;
% CRFmax
t=0.01;
CRF_threshold = t*CRFmax;
% CRF����ֱ�Һܴ��ʱ���ǽǵ㣬CRFR����ֱ�Һ�С��ƽ̹������ô��ô�綨�ܴ�ͺ�С��
% �����t�����ã�����t����Ƚϴ�Щ�����������ɴ�ɱһǧ���ɷŹ�һ����Ч��
% ����ͨ��һ��3*3�Ĵ������жϵ�ǰλ���Ƿ�Ϊ�ǵ�
for i = 2:nrow-1
    for j = 2:ncol-1
        if CRF(i,j) > CRF_threshold &&  CRF(i,j)>max([max(CRF(i-1,j-1:j+1)) CRF(i,j-1) CRF(i,j+1) max(CRF(i+1,j-1:j+1))]);
            Corner(i,j) = 1;
        else % �����ǰλ�ã�i,j�����ǽǵ㣬����Corner(i,j)��ɾ���Ըú�ѡ�ǵ�ļ�¼
            Corner(i,j) = 0;
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

end

