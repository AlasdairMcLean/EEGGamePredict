function [V,rho]=mcca(X,d)
% [V,rho]=mcca(X,d) Multiset Canonical Correlation Analysis. X is the data
% arranged as samples by dimension, whereby all sets are concatenated along
% the dimensions. d is a vector with the dimensions of each set. V are the
% component vectors and rho the resulting inter-set correlations.
N=length(d);
R=cov(X);
for i=N:-1:1, j=(1:d(i))+sum(d(1:i-1)); D(j,j)=R(j,j); end
[V,lambda]=eig(R,D);
rho = (diag(lambda)-1)/(N-1);