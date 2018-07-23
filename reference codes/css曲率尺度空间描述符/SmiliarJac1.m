function  U =SmiliarJac1( I,J,A,B)
[width1 height1]  = size(I);
[width2 height2] = size(J);

delt = uint8(height1/8);
cnt1 = size(A,1);
cnt2 = size(B,1);
H = fspecial('average',[15 15]);%生成一15*15邻域平均窗函数
I1 = filter2(H,I);
J1 = filter2(H,J);
C = zeros(cnt1,cnt2);
G = zeros(cnt1,cnt2);
for s = 1:cnt1
    u1 = A(s,1);v1 = A(s,2);
    for t = 1:cnt2
        u2 = B(t,1);v2 = B(t,2);
        su = 0;sum1=0;sum2=0;
        for k = 1:15
            for l = 1:15
                m1 = u1+k-8;n1 = v1+l-8;
                m2 = u2+k-8;n2 = v2+l-8;
               if (0<m1&&0<n1&&0<m2&&0<n2&&m1<=width1&&n1<=height1&&m2<=width2&&n2<=height2)
                su = su + (double(I(m1,n1))-double(I1(u1,v1)))*(double(J(m2,n2))-double(J1(u2,v2)));
                sum1 = sum1 +(double(I(m1,n1))-double(I1(u1,v1)))^2;
                sum2 = sum2 + (double(J(m2,n2))-double(J1(u2,v2)))^2;
                end
            end   
        end
        C(s,t) = su/(15*15*(sqrt(sum1*sum2)));
        r = double((u1-u2)^2+(v1-v2)^2);
         G(s,t) = double((C(s,t)+1)/2*exp(double((-r)/(2*delt*delt))));
          
    end    
end

P = VD(G);
U=find1(P) ;


end

function Pij=VD(Gij) 
[T,D,U]=svd(Gij);
[a,b]=size(D);
c=min(a,b);
for i=1:c
    if(D(i,i)~=0) %%%%%%%%%%判断对角线元素是不是等于0
        D(i,i)=1;
    end
end
Pij=T*D*U';
end

function U=find1(Pij) 
[i,j]=size(Pij);
U = zeros(i,2);
for ii=1:i
     %[C,I]=max(D(i,:));
     %index(i,:) = [i,I];

    [a,b]=max(Pij(ii,:));
    idx1 = [ii,b];
    [c,d]=max(Pij(:,b));
    idx2 = [d,b];
     
    
    if idx1(1,1)==idx2(1,1)
        U(ii,1) = idx1(1,1);
        U(ii,2) = idx1(1,2);
    else
        U(ii,1) = 0;
        U(ii,2) = 0;
    end
end
end