function X=tplitz2(x,K,L)

% construct block toeplitz matrix
X=[];

% to understand this function, take the most common case where 'x' is a
% single column
for i=1:size(x,2)
    Xtmp=toeplitz(x(:,i));
    trimask=upptrimask(Xtmp,1);
    Xtmp(trimask==1)=NaN; 
    %Xtmp=Xtmp(:,1:K+1);
    Xtmp=Xtmp(:,1:K);
    
    % aggregate
    X=cat(2,X,Xtmp);
end

for row=1:size(X,1)
    nanind=find(isnan(X(row,:)));
    if ~isempty(nanind)
        %X(row,nanind)=X(row,nanind(1)-1);
        X(row,nanind)=0;
    end
end
numrows=size(X,1);
numcols=size(X,2);
Xp=zeros(numrows+L,numcols+L);
col1=X(:,1);
Xp(L+1:end,L+1:end)=X;
for i=1:L
    Xp(L-i+1:L-i+numrows,L-i+1)=col1;
end




% add zero-degree coefficient
X=cat(2,Xp,ones(size(Xp,1),1));

return