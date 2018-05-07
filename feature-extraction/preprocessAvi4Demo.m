clear all; close all; clc
diskPath = 'D:/ARL/meta/';
srcDataFilename='/Users/JacekSuper/Dropbox/ARL/data/precomputed/demoMaterials-subject1.mat';

playerDirName = '006/';
videoFileName='2017-10-06 18-59-54.avi';
videoFullFilename = [diskPath playerDirName videoFileName];
vobj = VideoReader(videoFullFilename);

nFrames=vobj.Duration*vobj.FrameRate;

load('../../data/006/PLAY/race1_frameSamplesKept.mat','frameSamplesKept');
disp('we good');
f1=frameSamplesKept(1);
f2=frameSamplesKept(end);
workingFrames=read(vobj,[f1 f2]);

%%
load(srcDataFilename);

%%
% downsample frame sequence
workingFrames=workingFrames(:,:,:,1:4:end);


%%
if size(workingFrames,4)>size(rhos_PLAY,1)
nExtraFrames=size(workingFrames,4)-size(rhos_PLAY,1);
workingFrames=workingFrames(:,:,:,1:nFrames-nExtraFrames);
end
%%

% now make the figure
ms=10;
frameWidth=0.95;
plotWidth=0.8;
plotHeight=0.2;
nFrames=size(workingFrames,4);
v = VideoWriter('D:/ARL/demos/stkDemo.mp4');
%v.FileFormat='mp4';
%v.CompressionRatio = 3;
v.FrameRate=30;
nFramesToWrite=5389;
open(v);
hf=figure;
for f=1:nFramesToWrite
    
    hs(2)=subplot(212);
    set(hs(2),'Position',[0.1 0.1 plotWidth plotHeight]);
    hold on
    hp(:,1)=plot(time,rhos_PLAY(:,1),'color',color_PLAY,'LineWidth',lw);
    hp(:,3)=plot(time,rhos_BCI(:,1),'color',color_BCI,'LineWidth',lw);
    hp(:,5)=plot(time,rhos_WATCH(:,1),'color',color_WATCH,'LineWidth',lw);
    hp(:,2)=plot(time(f),rhos_PLAY(f,1),'o','color',color_PLAY,'MarkerFaceColor',color_PLAY,'MarkerSize',ms);
    hp(:,4)=plot(time(f),rhos_BCI(f,1),'o','color',color_BCI,'MarkerFaceColor',color_BCI,'MarkerSize',ms);
    hp(:,6)=plot(time(f),rhos_WATCH(f,1),'o','color',color_WATCH,'MarkerFaceColor',color_WATCH,'MarkerSize',ms);
    xlim([time(f)-displayWindowLength time(f)+displayWindowLength])
    ylim([-0.6 0.6])
    ylabel('SRC');
    xlabel('Time (s)');
    hlg=legend('PLAY','MOCK BCI','WATCH');
    set(hlg,'Position',[0.3726-0.125 0.2194+0.075 0.5036 0.0488])
    set(hlg,'box','off');
    set(hlg,'orientation','horizontal');

    
    
    
    hs(1)=subplot(211);
    set(hs(1),'Position',[0.025 0.35 frameWidth frameWidth*720/1280]);
    imagesc(workingFrames(:,:,:,f));
    %axis equal
    axis off
    
    % do it
    drawnow
    M(f)=getframe(hf);
    writeVideo(v,M(f));
    
end
close(v);
