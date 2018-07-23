function  Gij =SmiliarJac( A,B,I,J,delt )
clear all
IndexN = size(A);
W = IndexN(1,1);
NA = Normal(A,W);
NB = Normal(B,W);
CA = Stdis(A,W);
CB = Stdis(B,W);
Cij = [];
NI = NumO(I);
NJ = NumO(J);
F = 0;
for i =1:W
    for j = 1:W
        F = F+(A(i,j)-NA)(B(i,j)-NB);
    end
end
for i =1:NI
    for j = 1:NJ
        C(i,j) = F/(W*W*CA*CB);
    end
end
GIJ = [];
for i = 1:NI
    for j =1:NJ
        GIJ(i,j) = (C(i,j)+1)*exp(dis(I(i,:),J(j,:))*dis(I(i,:),J(j,:))/(2*delt*delt);
    end
end
Gij = GIJ

end
function N = NumO(Arg)%������������
Nm = size(I);
N =max(Nm);
end
function N = Normal(Arg,Num)%������ֵ
nt = 0;
for i = 1:Num
    for j = 1:Num
        nt = nt + Arg(i,j)
    end
end
N = nt/(Num*Num);

end
function D = Stdis(Arg,Num)%�����ĵı�׼��
total = [];
for i = 1:Num
    for j = 1:Num
        total = [total;Arg(i,j)];
    end
end
Nc = cov(total);
D = sqrt(Nc);
end
function DIS = dis(A1,A2)%��ŷʽ����
D = A1 -A2;
DIS = sqrt(D(1,1)*D(1,1)+D(1,2)*D(1,2));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%��������ֵ�ֽ⣬���P����
%%%%%%%%
%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Pij=VD(Gij) 
[T,D,U]=svd(Gij);
[a,b]=size(D);
c=max(a,b);
for i=1:c
    if(D(i,i)~=0) %%%%%%%%%%�ж϶Խ���Ԫ���ǲ��ǵ���0
        D(i,i)=1;
    end
end
Pij=T*D*U;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%����ƥ��ĵ������±�
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Uij=find(Pij) 
[i,j]=size(Pij);
for ii=1:i
    [a,b]=max(Pij(ii,:));
    [c,d]=max(Pij(:,b));
    if a==c
        Uij(ii,:)=[d b];
    else
        Uij(ii,:)=[0 0];
    end
end



%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here
