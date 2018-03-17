function [H,W,rhos,pvals,U,V,A,B,stats,hf,hs] = stim2brain( X,Y,Ky,show,nComp,K,fs,locfile )
if nargin<8, locfile='BioSemi64.loc'; end;
if nargin<7, fs=30; end
if nargin<6, K=30; end;
if nargin<5, nComp=3; end;
if nargin<4, show=0; end;
if nargin<3, Ky=10; end;

Y(isnan(Y))=0;
Ryy=cov(Y);
%[H,W,rhos,U,V,stats] = canoncorr(X,Y);
[H,W,rhos,pvals,U,V] = myCanonCorr(X,Y,[],Ky); stats=[];
A=Ryy*W(:,1:nComp)*inv(W(:,1:nComp)'*Ryy*W(:,1:nComp));

X(isnan(X))=0;
Rxx=cov(X);
B=Rxx*H(:,1:nComp)*inv(H(:,1:nComp)'*Rxx*H(:,1:nComp));


nFeats=floor(size(H,1)/(K+1));
%colors=varycolor(nFeats);
colors={'k','r','g','b'};
if show
    hf=figure;
    for c=1:nComp
        %impulse responses
        hs(c*2)=subplot(nComp,2,c*2); hold on;
        
        for feat=1:nFeats
            hp=plot((0:K-1)/fs,H((feat-1)*K+1:feat*K,c));
            %set(hp,'color',colors(feat,:));
            set(hp,'color',colors{feat});
        end        
        % forward models
        hs((c-1)*2+1)=subplot(nComp,2,(c-1)*2+1);
        topoplot(A(:,c),locfile,'electrodes','off','numcontour',0,'plotrad',0.7);
        title(sprintf('r = %0.2f, p = %0.3f ', rhos(c), pvals(c)));
        %title(sprintf('Canon. Comp. %d',c));
    end
end

end

