function [ Corner_Location ] = HRS(gray_img, Corner_harris, Corner_RCSS, Corner_SUSAN, CRFmax)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% ȥ���ظ��ǵ�
%����uniquetol���ݲΧ�ڵ�Ψһֵ��
DS = [1 1];
tol = 3;
m=0;
Corner_harris_pure = [];
Corner_RCSS_pure = [];

[C_harris,IA_harris]=uniquetol(Corner_harris, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
for m = 1:length(IA_harris)
    M_temp = [];
    if(length(IA_harris{m})==1)
        Corner_harris_pure(m,1) = Corner_harris(IA_harris{m},1);
        Corner_harris_pure(m,2) = Corner_harris(IA_harris{m},2);
    else
        Corner_harris_pure(m,1) = round(mean(Corner_harris(IA_harris{m},1)));
        Corner_harris_pure(m,2) = round(mean(Corner_harris(IA_harris{m},2)));
    end
end

[C_RCSS,IA_RCSS]=uniquetol(Corner_RCSS, tol, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);

for m = 1:length(IA_RCSS)
     M_temp = [];
    W2 = [];
    l = length(IA_RCSS{m});
    loc_mat = [];
    if(l==1)
        Corner_RCSS_pure(m,1) = Corner_RCSS(IA_RCSS{m},1);
        Corner_RCSS_pure(m,2) = Corner_RCSS(IA_RCSS{m},2);
    else
        loc_mat = [Corner_RCSS(IA_RCSS{m}(:),1),Corner_RCSS(IA_RCSS{m}(:),2)]; %[l 2]
        W2 = gray_value_weight(gray_img,loc_mat); %[1 l]
        loc_temp = W2*loc_mat;
        Corner_RCSS_pure(m,1) = round(loc_temp(1,1)); %W2*loc_mat(1,1)�õ�[1 2]�ľ���
        Corner_RCSS_pure(m,2) = round(loc_temp(1,2));
    
%     M_temp = [];
%     if(length(IA_RCSS{m})==1)
%         Corner_RCSS_pure(m,1) = Corner_RCSS(IA_RCSS{m},1);
%         Corner_RCSS_pure(m,2) = Corner_RCSS(IA_RCSS{m},2);
%     else
%         Corner_RCSS_pure(m,1) = round(mean(Corner_RCSS(IA_RCSS{m},1)));
%         Corner_RCSS_pure(m,2) = round(mean(Corner_RCSS(IA_RCSS{m},2)));

    end
end

%% �ǵ�ƥ��
% ismembertol(A,B)�ҳ�RCSS��Harris�ǵ��е���ͬ���֣�
% LIR��������Corner_RCSS_pure��ͬ������*1���߼����󣬵�Corner_RCSS_pure��Ԫ������Corner_harris_pure���ҵ��ݲ�tol��Χ�ڵ�Ԫ��ʱ��LIR��Ӧ�и�ֵΪ1������Ϊ0��
% LocH��������Corner_RCSS_pure��ͬ������*1��Ԫ������
%   ��Corner_RCSS_pure��Ԫ��a����Corner_harris_pure_pure���ҵ��ݲ�tol��Χ�ڵ�Ԫ��ʱ��LocH��Ӧ�е�ֵΪCorner_harris��������a�����ݲ�tol��Χ��ֵ������������Ϊ0
[LIR,LocH] = ismembertol(Corner_harris_pure,Corner_RCSS_pure,tol,'ByRows',true,'OutputAllIndices',true,'DataScale',DS);

i=0;
j=0;
Corner_harris_diff = [];
Corner_RCSS_diff = [];
Corner_RCSS_samewithintol = [];
Corner_final = [];
% lambda_RCSS_samewithintol = []; % Harris�㷨�о���M������ֵ��1����2
% lambda_harris_pure = [];
for k = 1:length(LocH)
    % �ҳ�Corner_harris_pure�й����Ľǵ㣨��Corner_RCSS_pureû�н����ĵ㣩
    if(LocH{k} == 0)
        i=i+1;
        Corner_harris_diff(i,1)=Corner_harris_pure(k,1);
        Corner_harris_diff(i,2)=Corner_harris_pure(k,2);
        % �ҳ�Corner_harris_pure����Corner_RCSS_pure���ڽ����Ľǵ�
        Corner_harris_samewithintol = setdiff(Corner_harris_pure, Corner_harris_diff, 'rows');
        % �ҳ�Corner_RCSS_pure����Corner_harris_pure���ڽ����Ľǵ�
    else
        for l=1:length(LocH{k})
            j=j+1;
            Corner_RCSS_samewithintol(j,1)=Corner_RCSS_pure(LocH{k}(l),1);
            Corner_RCSS_samewithintol(j,2)=Corner_RCSS_pure(LocH{k}(l),2);
            % ƥ��ǵ���Ӧ����ֵ��һ������Ϊλ��Ȩ��
            [CRF1,D1] = Corner_response_func(gray_img, Corner_RCSS_samewithintol(j,1),Corner_RCSS_samewithintol(j,2));
            [CRF2,D2] = Corner_response_func(gray_img, Corner_harris_pure(k,1),Corner_harris_pure(k,2));
%             lambda_RCSS_samewithintol = [lambda_RCSS_samewithintol;D1(1,1),D1(2,2)];
%             lambda_harris_pure = [lambda_harris_pure;D2(1,1),D2(2,2)];
            CRF(j,1) = CRF1;
            CRF(j,2) = CRF2;
            CRF_harris(j,1) = CRF1;
            CRF_RCSS(j,1) = CRF2;
            if(CRF1<0)
                w1 = 0;
                w2 = 1;
            else
                w1 = CRF_weight(CRF1,CRF2);
                w2 = CRF_weight(CRF2,CRF1);
            end
            Corner_temp(j,1) = round(w1*Corner_RCSS_samewithintol(j,1)+w2*Corner_harris_pure(k,1));
            Corner_temp(j,2) = round(w1*Corner_RCSS_samewithintol(j,2)+w2*Corner_harris_pure(k,2));
            W(j,1) = w1;
            W(j,2) = w2;
        end
    end
end

% �ǵ㽻���п��ܴ�����ͬ�ĵ㣬���֮
Corner_RCSS_samewithintol_pure = [];
[C_s,IA_s,IC_s]=uniquetol(Corner_RCSS_samewithintol,'ByRows',true);
Corner_RCSS_samewithintol_pure = C_s;
% �ҳ�Corner_RCSS_pure�й����Ľǵ㣨��Corner_harris_pureû�н����ĵ㣩
Corner_RCSS_diff = setdiff(Corner_RCSS_pure, Corner_RCSS_samewithintol_pure, 'rows');

CRF_RCSS_diff = [];
Corner_RCSS_diff_final = [];
CRF3 = 0;
t = 0.001;
CRF_threshold = t*CRFmax;
% CRF_threshold = 0;
% lambda_RCSS_diff = [];
for l = 1:length(Corner_RCSS_diff)
    [CRF3,D3] = Corner_response_func(gray_img, Corner_RCSS_diff(l,1),Corner_RCSS_diff(l,2));
%     lambda_RCSS_diff = [lambda_RCSS_diff;D3(1,1),D3(2,2)];
    CRF_RCSS_diff = [CRF_RCSS_diff; CRF3];
    if CRF3 > CRF_threshold
        Corner_RCSS_diff_final = [Corner_RCSS_diff_final; Corner_RCSS_diff(l,1),Corner_RCSS_diff(l,2)];
    end
end

% ��Ȩ��Corner_diff�Ĳ���
if (~isempty(Corner_RCSS_diff)) && (~isempty(Corner_harris_diff))
    Corner_diff_temp = union(Corner_RCSS_diff,Corner_harris_diff,'rows');
else
    Corner_diff_temp = [Corner_RCSS_diff;Corner_harris_diff];
end


% USAN����ǽǵ�,�õ����սǵ�
% Corner_final = False_corner_delete(gray_img, Corner_temp1);
tol1 = 7;
[LIR1,LocH1] = ismembertol(Corner_diff_temp,Corner_SUSAN,tol,'ByRows',true,'OutputAllIndices',true,'DataScale',DS);
LIR1_temp = find(LIR1);
Corner_diff_final = [Corner_diff_temp(LIR1_temp,1),Corner_diff_temp(LIR1_temp,2)];
if (~isempty(Corner_temp)) && (~isempty(Corner_diff_final))
    Corner_temp2 = union(Corner_temp,Corner_diff_final,'rows');
else
    Corner_temp2 =[Corner_temp; Corner_diff_final];
end

% Corner_final = Corner_temp2;
%% �Ǽ���ֵ���Ʒ����������ǵ�
tol2 = 6;
[C_final,IA_final]=uniquetol(Corner_temp2, tol2, 'ByRows', true, 'OutputAllIndices', true, 'DataScale', DS);
for m = 1:length(IA_final)
    M_temp = [];
    W2 = [];
    l = length(IA_final{m});
    loc_mat = [];
    if(l==1)
        Corner_final(m,1) = Corner_temp2(IA_final{m},1);
        Corner_final(m,2) = Corner_temp2(IA_final{m},2);
    else
        loc_mat = [Corner_temp2(IA_final{m}(:),1),Corner_temp2(IA_final{m}(:),2)]; %[l 2]
        W2 = gray_value_weight(gray_img,loc_mat); %[1 l]
        loc_temp = W2*loc_mat;
        Corner_final(m,1) = round(loc_temp(1,1)); %W2*loc_mat(1,1)�õ�[1 2]�ľ���
        Corner_final(m,2) = round(loc_temp(1,2));
%         Corner_final(m,1) = round(mean(Corner_temp2(IA_final{m},1)));
%         Corner_final(m,2) = round(mean(Corner_temp2(IA_final{m},2)));
    end
end
Corner_Location = [];
Corner_Location = Corner_final;
end

