function Wr = APG(alpha,beta,t,lambda,L)
%APG Summary of this function goes here
%   Detailed explanation goes here
for k=0:500
    beta(k+1)=alpha(k)+(t(k-1)-1)/t(k)*(alpha(k)-alpha(k-1));
    alpha(k+1)=
end

end

