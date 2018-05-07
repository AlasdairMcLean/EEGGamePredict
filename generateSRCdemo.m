clear all; close all; clc
addpath(genpath('..'));
subjectIndx=3;

%%
weightFilename='../data/precomputed/weights_PLAY_muFlow_22-Oct-2017';
load(weightFilename);
[~,filenameStr]=fileparts(filenames_PLAY{subjectIndx});
load(filenameStr); % 'stim' and 'eeg' in memory
% filenameStr=filenames_PLAY{subjectIndx};
% filenameStr2=strrep(filenameStr,'/XDF','');
% load(filenameStr2); % 'stim' and 'eeg' in memory
winlen=5*fs; %winshift=0.2*fs;
winshift=4; % 4 samples at 120 Hz means 30 fps output
rhos_PLAY = computeTimeResolvedRhos(stim,eeg,A_PLAY,B_PLAY,winlen,winshift);

%%
weightFilename='../data/precomputed/weights_BCI_muFlow_22-Oct-2017';
load(weightFilename);
[~,filenameStr]=fileparts(filenames_BCI{subjectIndx});
load(filenameStr); % 'stim' and 'eeg' in memory
%filenameStr2=strrep(filenameStr,'/XDF','');
%load(filenameStr2); % 'stim' and 'eeg' in memory
rhos_BCI = computeTimeResolvedRhos(stim,eeg,A_BCI,B_BCI,winlen,winshift);

%%
weightFilename='../data/precomputed/weights_WATCH_muFlow_22-Oct-2017';
load(weightFilename);
[~,filenameStr]=fileparts(filenames_WATCH{subjectIndx});
load(filenameStr); % 'stim' and 'eeg' in memory
%filenameStr=filenames_WATCH{subjectIndx};
%filenameStr2=strrep(filenameStr,'/XDF','');
%load(filenameStr2); % 'stim' and 'eeg' in memory
rhos_WATCH = computeTimeResolvedRhos(stim,eeg,A_WATCH,B_WATCH,winlen,winshift);

%%
nWins=size(rhos_PLAY,1);
time=(0:nWins-1)*winshift/fs+0.5*winlen/fs;
%
color_PLAY=[0,0.4470,0.7410];
color_BCI=[0.8500,0.3250,0.0980];
color_WATCH=[0.9290,0.6940,0.1250];
displayWindowLength=15; % seconds
lw=2;
ms=14;


save(['../data/precomputed/demoMaterials-subject' num2str(subjectIndx)],'rhos_BCI','rhos_PLAY','rhos_WATCH',...
    'nWins','time','color_BCI','color_PLAY','color_WATCH','displayWindowLength','lw','ms');

%%
if 0
    v = VideoWriter('srcDemo.mp4');
    set(v,'FrameRate',round(1/(winshift/fs)));
    open(v);
    
    hf=figure;
    set(hf,'Position',[360 278 2*560 2*210]);
    hold on
    
    for t=1:numel(time)
        hp(:,1)=plot(time,rhos_PLAY(:,1),'color',color_PLAY,'LineWidth',lw);
        hp(:,3)=plot(time,rhos_BCI(:,1),'color',color_BCI,'LineWidth',lw);
        hp(:,5)=plot(time,rhos_WATCH(:,1),'color',color_WATCH,'LineWidth',lw);
        hp(:,2)=plot(time(t),rhos_PLAY(t,1),'o','color',color_PLAY,'MarkerFaceColor',color_PLAY,'MarkerSize',ms);
        hp(:,4)=plot(time(t),rhos_BCI(t,1),'o','color',color_BCI,'MarkerFaceColor',color_BCI,'MarkerSize',ms);
        hp(:,6)=plot(time(t),rhos_WATCH(t,1),'o','color',color_WATCH,'MarkerFaceColor',color_WATCH,'MarkerSize',ms);
        xlim([time(t)-displayWindowLength time(t)+displayWindowLength])
        ylim([-0.5 0.5])
        ylabel('Stimulus-Response Correlation');
        xlabel('Time (s)');
        hlg=legend('PLAY','MOCK BCI','WATCH');
        set(hlg,'box','off');
        set(hlg,'orientation','horizontal');
        drawnow
        M(t)=getframe(hf);
        writeVideo(v,M(t));
        %pause
        clf
        hold on
    end
    
    %
    close(v);
end
