%hankel mat
function X=hankel(x,r,l,K,L)
    for i=1:size(x,2)
        xp=x(:,r-l:r+l);
        XtmpR=toeplitz(x(:,1));
        trimask=upptrimask(Xtmp,1);
        XtmpR(trimask)=NaN;
        if size(Xtmp,2) >= K
            XtmpR=XtmpR(:,1:K); % go until the Kth column and cut the rest
        else
            if size(Xtmp,2) < K-L
                warning('Toeplitz matrix extending beyond valid data. Zeros incorporated for extra columns/rows.')
            end
            Xtmp=Xtmp(:,1:end);
            Xtmp=cat(2,Xtmp,zeros(length(x(:,1)),K-length(x(:,1))));
        end
        XtmpL=fliplr(XtmpR);
        X=cat(XtmpL,XtmpR,2);
    end

    for row=1:size(X,1)
        nanind=find(isnan(X(row,:)));
        if ~isempty(nanind)
            X(row,nanind)=0;
        end
    end
    numrows=size(X,1)+L;
    numcols=2*K-1;
    Xp=zeros(numrows,numcols);
    col1=cat(1,X(:,1),zeros(L,1));
    for i=1:K
        Xp(:,numcols/2-0.5+i)=cat(1,zeros(i-1,1),col1(1:numrows-i+1));
    end
   %for i=1:K
   %     Xp(:,)
return