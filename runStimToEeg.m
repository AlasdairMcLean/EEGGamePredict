function [H,W,rhos,pvals,U,V,A,B,stats,hf,hs] = runStimToEeg( X,Y,Kx,Ky,show,nComp,K,fs,locfile )
%
% run the stim2eeg method on stimulus X and EEG Y
% NB: call this after prepStimToEeg.m
%
% output arguments
% H: temporal filter to apply to the stimulus (samples x components)
% W: spatial filter to apply to the EEG (electrodes x components)
% rhos: correlation coefficient vector between filtered stimulus and filtered EEG
% for each component
% pvals: p-value of correlation coefficients
% U: temporally filtered stimulus (samples x component)
% V: spatially filtered EEG (samples x component)
% A: forward model of the stimulus
% B: forward model of the EEG (topoplot this to visualize components)
% stats: statistics of cca 
% hf: handle to display figure if show=1
% hs: handle to subplots of figure 
%
% input arguments
% X: stimulus feature convolution matrix (samples x samples) 
% Y: EEG (samples x electrodes)
% Kx: regularization parameter of stimulus (between 1 and temporal aperture
% length)
% Ky: regularization parameter of EEG (between 1 and number of electrodes)
% show: 1 to display results, 0 otherwise
% nComp: number of components to visualize
% K: length of temporal aperture in SAMPLES
% fs: sampling rate of X and Y
% locfile: topoplot compatible channel location file
%
% Jacek P. Dmochowski (c) 2016




if nargin<8, locfile='BioSemi64.loc'; end;
if nargin<7, fs=30; end
if nargin<6, K=30; end;
if nargin<5, nComp=3; end;
if nargin<4, show=0; end;
if nargin<3, Ky=10; end;

Y(isnan(Y))=0; % apparently still necessary. FIXTHIS
[H,W,rhos,pvals,U,V,Rxx,Ryy] = myCanonCorr(X,Y,Kx,Ky); stats=[];
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

