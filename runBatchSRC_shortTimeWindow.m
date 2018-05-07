clear all; close all; clc
addpath(genpath('/Users/jacekdmochowski/Dropbox/stim2eeg'));
addpath(genpath('../data'));

feature2run='muFlow';
maxRacesPerSubject=4;
fs=30;
K=fs-1;
Kx=10;
Ky=10;
nComp=5;
arModelOrder=round(fs);
subjStrs={'013','014','015','016','017','018','019','020','021','022','023','024','030','031','032','033','034','035'};
nSubj=numel(subjStrs);
structfilenames_PLAY=[];
structfilenames_BCI=[];
structfilenames_WATCH=[];
for s=1:nSubj
    tmp=dir(['/Users/jacekdmochowski/Dropbox/ARL/data/' subjStrs{s} '/play/mat/*ready_data_jason.mat']);
    if numel(tmp)>maxRacesPerSubject, tmp=tmp(1:maxRacesPerSubject); end
    structfilenames_PLAY=cat(1,structfilenames_PLAY,tmp);
    
    tmp=dir(['/Users/jacekdmochowski/Dropbox/ARL/data/' subjStrs{s} '/bci/mat/*ready_data_jason.mat']);
    if numel(tmp)>maxRacesPerSubject, tmp=tmp(1:maxRacesPerSubject); end
    structfilenames_BCI=cat(1,structfilenames_BCI,tmp);
    
    tmp=dir(['/Users/jacekdmochowski/Dropbox/ARL/data/' subjStrs{s} '/watch/mat/*ready_data_jason.mat']);
    if numel(tmp)>maxRacesPerSubject, tmp=tmp(1:maxRacesPerSubject); end
    structfilenames_WATCH=cat(1,structfilenames_WATCH,tmp);
end
for i=1:numel(structfilenames_PLAY), filenames_PLAY{i}=fullfile(structfilenames_PLAY(i).folder,structfilenames_PLAY(i).name); end
for i=1:numel(structfilenames_BCI), filenames_BCI{i}=fullfile(structfilenames_BCI(i).folder,structfilenames_BCI(i).name); end
for i=1:numel(structfilenames_WATCH), filenames_WATCH{i}=fullfile(structfilenames_WATCH(i).folder,structfilenames_WATCH(i).name); end


%%
allEEG_PLAY=[];
allStim_PLAY=[];
for f=1:numel(filenames_PLAY)
    fprintf('PLAY %d of %d \n',f,numel(filenames_PLAY));
    load(filenames_PLAY{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    allStim_PLAY=cat(1,allStim_PLAY,stim_tpl);
    allEEG_PLAY=cat(2,allEEG_PLAY,eeg);
end
allStim_PLAY=forceSpaceTime(allStim_PLAY);
[A_PLAY,B_PLAY,rhos_PLAY,~,~,~,Rxx_PLAY,Ryy_PLAY] = myCanonCorr(allStim_PLAY,allEEG_PLAY,Kx,Ky);
Ak_PLAY=A_PLAY(:,1:nComp);
Bk_PLAY=B_PLAY(:,1:nComp);
forwards_PLAY=Ryy_PLAY*Bk_PLAY*inv(Bk_PLAY'*Ryy_PLAY*Bk_PLAY);
tforwards_PLAY=Rxx_PLAY*Ak_PLAY*inv(Ak_PLAY'*Rxx_PLAY*Ak_PLAY);
weightFilename=['../data/precomputed/weights_PLAY_' feature2run '_' date];
save(weightFilename,'A_PLAY','B_PLAY','rhos_PLAY','Rxx_PLAY','Ryy_PLAY','forwards_PLAY','nComp','K',...
    'Kx','Ky','fs','filenames_PLAY');

%%
allEEG_BCI=[];
allStim_BCI=[];
for f=1:numel(filenames_BCI)
    fprintf('BCI %d of %d \n',f,numel(filenames_BCI));
    load(filenames_BCI{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    allStim_BCI=cat(1,allStim_BCI,stim_tpl);
    allEEG_BCI=cat(2,allEEG_BCI,eeg);
end
allStim_BCI=forceSpaceTime(allStim_BCI);
[A_BCI,B_BCI,rhos_BCI,~,~,~,Rxx_BCI,Ryy_BCI] = myCanonCorr(allStim_BCI,allEEG_BCI,Kx,Ky);
Ak_BCI=A_BCI(:,1:nComp);
Bk_BCI=B_BCI(:,1:nComp);
forwards_BCI=Ryy_BCI*Bk_BCI*inv(Bk_BCI'*Ryy_BCI*Bk_BCI);
tforwards_BCI=Rxx_BCI*Ak_BCI*inv(Ak_BCI'*Rxx_BCI*Ak_BCI);
weightFilename=['../data/precomputed/weights_BCI_' feature2run '_' date];
save(weightFilename,'A_BCI','B_BCI','rhos_BCI','Rxx_BCI','Ryy_BCI','forwards_BCI','nComp','K',...
    'Kx','Ky','fs','filenames_BCI');

%%
allEEG_WATCH=[];
allStim_WATCH=[];
for f=1:numel(filenames_WATCH)
    fprintf('WATCH %d of %d \n',f,numel(filenames_WATCH));
    load(filenames_WATCH{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    allStim_WATCH=cat(1,allStim_WATCH,stim_tpl);
    allEEG_WATCH=cat(2,allEEG_WATCH,eeg);
end
allStim_WATCH=forceSpaceTime(allStim_WATCH);
[A_WATCH,B_WATCH,rhos_WATCH,~,~,~,Rxx_WATCH,Ryy_WATCH] = myCanonCorr(allStim_WATCH,allEEG_WATCH,Kx,Ky);
Ak_WATCH=A_WATCH(:,1:nComp);
Bk_WATCH=B_WATCH(:,1:nComp);
forwards_WATCH=Ryy_WATCH*Bk_WATCH*inv(Bk_WATCH'*Ryy_WATCH*Bk_WATCH);
tforwards_WATCH=Rxx_WATCH*Ak_WATCH*inv(Ak_WATCH'*Rxx_WATCH*Ak_WATCH);
weightFilename=['../data/precomputed/weights_WATCH_' feature2run '_' date];
save(weightFilename,'A_WATCH','B_WATCH','rhos_WATCH','Rxx_WATCH','Ryy_WATCH','forwards_WATCH','nComp','K',...
    'Kx','Ky','fs','filenames_WATCH');
%%
nCols=6;
cm=jmaColors('usa');
nElectrodes=size(forwards_PLAY,1);
nFilter=size(A_PLAY,1);

signs_PLAY=ones(1,nComp);
forwards_PLAY_draw=forwards_PLAY.*repmat(signs_PLAY,[nElectrodes 1]);
A_PLAY_draw=A_PLAY(:,1:nComp).*repmat(signs_PLAY,[nFilter 1]);

signs_BCI=ones(1,nComp);
forwards_BCI_draw=forwards_BCI.*repmat(signs_BCI,[nElectrodes 1]);
A_BCI_draw=A_BCI(:,1:nComp).*repmat(signs_BCI,[nFilter 1]);

signs_WATCH=ones(1,nComp);
forwards_WATCH_draw=forwards_WATCH.*repmat(signs_WATCH,[nElectrodes 1]);
A_WATCH_draw=A_WATCH(:,1:nComp).*repmat(signs_WATCH,[nFilter 1]);

figure;
for c=1:nComp
    hs(c,1)=subplot(nComp,nCols,(c-1)*nCols+1);
    topoplot(forwards_PLAY_draw(:,c),'JBhead96_sym.loc','numcontour',0);
    
    hs(c,2)=subplot(nComp,nCols,(c-1)*nCols+2);
    plot((0:K)/fs,A_PLAY_draw(:,c),'k');
    
    hs(c,3)=subplot(nComp,nCols,(c-1)*nCols+3);
    topoplot(forwards_BCI_draw(:,c),'JBhead96_sym.loc','numcontour',0);
    
    hs(c,4)=subplot(nComp,nCols,(c-1)*nCols+4);
    plot((0:K)/fs,A_BCI_draw(:,c),'k');
    
    hs(c,5)=subplot(nComp,nCols,(c-1)*nCols+5);
    topoplot(forwards_WATCH_draw(:,c),'JBhead96_sym.loc','numcontour',0);
    
    hs(c,6)=subplot(nComp,nCols,(c-1)*nCols+6);
    plot((0:K)/fs,A_WATCH_draw(:,c),'k');    
end

htit1=get(hs(1,1),'Title');
htit3=get(hs(1,3),'Title');
htit5=get(hs(1,5),'Title');

set(htit1,'String','PLAY');
set(htit3,'String','"MOCK BCI"');
set(htit5,'String','WATCH');

moveTitle(htit1,0.6,0.1,0);
moveTitle(htit3,0.6,0.1,0);
moveTitle(htit5,0.6,0.1,0);

%set(hs(:,[2 4 6]),'ylim',[-0.5 0.5]);

text(-8,5.75,'1','FontWeight','Bold');
text(-8,4.25,'2','FontWeight','Bold');
text(-8,2.85,'3','FontWeight','Bold');
text(-8,1.45,'4','FontWeight','Bold');
text(-8,-0.05,'5','FontWeight','Bold');

colormap(cm);
figFilename=['../figures/component_comparison_' feature2run '_' date ];
print('-dpng',figFilename);

%%
% compute subject-level stats
for f=1:numel(structfilenames_PLAY)
    fprintf('PLAY %d of %d \n',f,numel(filenames_PLAY));
    load(filenames_PLAY{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    this_u=stim_tpl*A_PLAY;
    this_v=eeg.'*B_PLAY;
    for c=1:size(this_u,2);
        this_r=corrcoef(this_u(:,c),this_v(:,c));
        rhos_subjects_PLAY(c,f)=this_r(1,2);
    end
end
[sems_PLAY,mus_PLAY] = nansem( rhos_subjects_PLAY,2 );
%
for f=1:numel(structfilenames_BCI)
    fprintf('BCI %d of %d \n',f,numel(filenames_BCI));
    load(filenames_BCI{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    this_u=stim_tpl*A_BCI;
    this_v=eeg.'*B_BCI;
    for c=1:size(this_u,2);
        this_r=corrcoef(this_u(:,c),this_v(:,c));
        rhos_subjects_BCI(c,f)=this_r(1,2);
    end
end
[sems_BCI,mus_BCI] = nansem( rhos_subjects_BCI,2 );
%
for f=1:numel(structfilenames_WATCH)
    fprintf('WATCH %d of %d \n',f,numel(filenames_WATCH));
    load(filenames_WATCH{f});
    eval(['stim=featuresCut.' feature2run ';']);
    arModel = ar(stim,arModelOrder);
    arPred= forecast(arModel,stim(1:arModelOrder),numel(stim));
    residual=stim-arPred;
    stim=residual;
    stim=zscore(stim);
    stim_tpl=tplitz(stim,K);
    this_u=stim_tpl*A_WATCH;
    this_v=eeg.'*B_WATCH;
    for c=1:size(this_u,2);
        this_r=corrcoef(this_u(:,c),this_v(:,c));
        rhos_subjects_WATCH(c,f)=this_r(1,2);
    end
end
[sems_WATCH,mus_WATCH] = nansem( rhos_subjects_WATCH,2 );

%
%make stacked bar graph figure for this feature

%%
% figure out p-values
s1=sum(rhos_subjects_PLAY,1);
s2=sum(rhos_subjects_BCI,1);
s3=sum(rhos_subjects_WATCH,1);
p12=ranksum(s1,s2,'tail','right');
p13=ranksum(s1,s3,'tail','right');
p23=ranksum(s2,s3,'tail','right');
[p12 p13 p23]

%%
figure;
barVals=[mus_PLAY(1:nComp) mus_BCI(1:nComp) mus_WATCH(1:nComp)].';
hbar=bar(barVals,'stacked');
hold on
mus=mus_PLAY(1:nComp);
sems=sems_PLAY(1:nComp);
mus(2)=mus(2)+mus(1);
mus(3)=mus(3)+mus(2);
mus(4)=mus(4)+mus(3);
mus(5)=mus(5)+mus(4);
herr=errorbar(ones(1,nComp),mus,sems, 'k', 'linestyle', 'none','LineWidth',1.25);

mus=mus_BCI(1:nComp);
sems=sems_BCI(1:nComp);
mus(2)=mus(2)+mus(1);
mus(3)=mus(3)+mus(2);
mus(4)=mus(4)+mus(3);
mus(5)=mus(5)+mus(4);
herr=errorbar(2*ones(1,nComp),mus,sems, 'k', 'linestyle', 'none','LineWidth',1.25);

mus=mus_WATCH(1:nComp);
sems=sems_WATCH(1:nComp);
mus(2)=mus(2)+mus(1);
mus(3)=mus(3)+mus(2);
mus(4)=mus(4)+mus(3);
mus(5)=mus(5)+mus(4);
herr=errorbar(3*ones(1,nComp),mus,sems, 'k', 'linestyle', 'none','LineWidth',1.25);

%
for i=1:size(hbar,2)
    hbar(i).EdgeColor='None';
    hbar(i).FaceAlpha=0.75;
end
set(gca,'XTickLabel',{'PLAY','"MOCK BCI"','WATCH'});
set(get(gca,'ylabel'),'String','Stimulus-Response Correlation');
set(get(gca,'ylabel'),'FontSize',16);
set(gca,'ytick',[0 0.1 0.2]);
box off


figFilename=['../figures/src_comparison_' feature2run '_' date];
print('-dpng',figFilename);


