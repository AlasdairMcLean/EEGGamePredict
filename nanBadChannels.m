function [Xout,gind] = nanBadChannels(X,P,Q,zero,locfile)
% [Xout,gind] = nanBadChannels(X,P,Q,zero)
% X: channels x time
% P: number of iterations
% Q: channels whose mean power is Q standard deviations above mean are
% discarded
if nargin<4, zero=0; end
if nargin<3, Q=6; end;
if nargin<2, P=3; end;

if size(X,1)>size(X<2), X=X.'; end % electrodes in row dimension

%%
eloc = readlocs( locfile );
locs(:,1)=[eloc.X]';
locs(:,2)=[eloc.Y]';
locs(:,3)=[eloc.Z]';
%%

gind=[];

for p=1:P
    chpwr=transpose( std(X.').^2 );
    gind=find(~isnan(chpwr));
    mustd=std(chpwr(gind));
    badch=find(  ( chpwr-mean(chpwr(gind)) ) >Q*mustd);
    if zero
        X(badch,:)=0;
    else
        if ~isempty(badch)
            X(badch,:)=NaN;
%             % interpolate here
%             goodch=setdiff(1:size(X,1),badch);
%             for b=1:numel(badch)
%                 X(badch(b),:)=NaN;
%                 for t=1:size(X,2)
%                     F=scatteredInterpolant(locs(goodch,1),locs(goodch,2),locs(goodch,3),X(goodch,t));
%                     X(badch(b),t)=F(locs(badch(b),1),locs(badch(b),2),locs(badch(b),3));
%                 end
%             end
        end
    end
end

Xout=X;
return
