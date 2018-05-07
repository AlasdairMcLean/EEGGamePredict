clear all; close all; clc
addpath(genpath('/Users/jacekdmochowski/Dropbox/stim2eeg'));
addpath(genpath('/Users/jacekdmochowski/Dropbox/rca'));
addpath(genpath('.'));
dataPath='/Users/jacekdmochowski/Dropbox/ARL/data/';
subjStr='013';
condStr='play';
dateStr='11_28_17';
raceNumber=1;
matFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '_epoched_eeg_and_stimulus.mat'];
saveFilename=[dataPath subjStr '/' condStr '/xdf/' dateStr '_0' num2str(raceNumber) '_preprocessed_eeg_and_stimulus.mat'];
%%
load(matFilename);
stim=featuresCut.muSqTemporalContrast;
fs=featuresCut.fs;

%%
opts.Q1=1;
opts.Q2=4;
opts.zero=1;
opts.xtent=12;
opts.showSvd=0;
opts.nChan2Keep=96;
opts.rpca=0;
opts.fs=fs;
opts.fsref=fs;
opts.locfile='JBhead96_sym.loc'; % wild guess
opts.chanlocs=[];
opts.fl=1; % passband low
opts.fh=14.5; % passband high
virtualeog=zeros(96,4);
virtualeog([1 34],1)=1;
virtualeog([2 35],2)=1;
virtualeog(1,3)=1;
virtualeog(2,3)=-1;
virtualeog(33,4)=1;
virtualeog(36,4)=-1;
opts.virtualeog=virtualeog;

eeg = myPreprocess( eeg_series_cut_resample , opts);

save(saveFilename,'eeg','stim','featuresCut','opts');

% %%
% K=fs;
% Kx=20;
% Ky=20;
% stim_tpl=tplitz(stim,K);
% [A,B,rhos,pvals,U,V,Rxx,Ryy] = myCanonCorr(stim_tpl,eeg,Kx,Ky);
% 
% %%
% nComp=5;
% Bk=B(:,1:nComp);
% forwards=Ryy*Bk*inv(Bk'*Ryy*Bk);
% cm=jmaColors('usa');
% figure;
% for i=1:nComp
%     subplot(2,nComp,i);
%     topoplot(forwards(:,i),'JBhead96_sym.loc','numcontour',0);
%     title(sprintf('rho=%0.2f',rhos(i)));
%     subplot(2,nComp,i+nComp);
%     plot((0:K)/fs,A(:,i),'k');
% end
% colormap(cm);
% 
% 
% %%
% % eloc = readlocs( opts.locfile );
% % locs(:,1)=[eloc.X]';
% % locs(:,2)=[eloc.Y]';
% % locs(:,3)=[eloc.Z]';
% % badch=1;
% % goodch=setdiff(1:96,badch);
% % F=scatteredInterpolant(locs(goodch,1),locs(goodch,2),locs(goodch,3),eeg(goodch,1));
% % %%
% % Fq=F(locs(badch,1),locs(badch,2),locs(badch,3));







