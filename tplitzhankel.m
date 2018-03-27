function Xp=tplitzhankel(x,K,L)

%X=input data; each column will be made into a toeplitz matrix. Thus, the
%row dimension should represent time.

%K=number of columns in the toeplitz matrix. If this value exceeds the
%number of valid datapoints, columns of zeros will be added instead

%L=number of extra rows in the toeplitz matrix beyond that of the data.

% construct block toeplitz matrix
X=[];

% to understand this function, take the most common case where 'x' is a
% single column
for i=1:size(x,2)
    Xtmp=toeplitz(x(:,i));
    trimask=upptrimask(Xtmp,1);
    Xtmp(trimask)=NaN; 
    %Xtmp=Xtmp(:,1:K+1);
    if size(Xtmp,2) >= K
        Xtmp=Xtmp(:,1:K); % go until the Kth column and cut the rest
    else
        if size(Xtmp,2) < K-L
            warning('Toeplitz matrix extending beyond valid data. Zeros incorporated for extra columns/rows.')
        end
        Xtmp=Xtmp(:,1:end);
        Xtmp=cat(2,Xtmp,zeros(length(x(:,1)),K-length(x(:,1))));
    end
    
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
numrows=size(X,1)+L; %
numcols=2*K-1;
Xp=zeros(numrows, numcols); % pre-allocate the matrix
col1=cat(1,X(:,1),zeros(L,1));
for i=1:K
    Xp(:,numcols/2-0.5+i)=cat(1,zeros(i-1,1),col1(1:numrows-i+1));
end
Xp(:,1:numcols/2-0.5)=fliplr(Xp(:,numcols/2+1.5:end));
Xp=cat(2,ones(numrows,1),Xp);
Xp=cat(2,Xp,ones(numrows,1));

return