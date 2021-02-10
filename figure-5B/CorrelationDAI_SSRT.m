% correlation GC DAI  - SSRTs

close all;
clear all;
clc;

addpath('./../SharedFunctions');
strProjectRoot = SetPaths();

% DAI values based on a fully conditioned GCA (all seven sources, i.e. 42 links)
load('DAI.mat'); % loads 'aa' and 'daiStop'
% 'daiStop': DAI values based on sSTOP trials
% 'aa': vector with subjects indeces for subject whose GC (rIFG->preSMA) is
% signficant above the bias level in sSTOP condition
signSubjectIndices = aa; % rename

load('SSRTs.mat'); % loads 'vSSRT'
ssrt = vSSRT';

% correlate SSRT with DAI of six frequencies (30, 32, 34, 36, 38, 40 Hz)
corrCoef=zeros(1,6);
corrPvalue=zeros(1,6);
confidenI=zeros(2,6);
rhoBoot=zeros(1,6);
iTest=0; % counter for tests / correlations

 for iFreq=16:21 % freq index (correspondend with 30:2:40 Hz)
      
     iTest=iTest+1;
     sSTOP_DAI=daiStop(signSubjectIndices,:);           
    
     scorr = @(a,b)(corr(a,b,'Tail','both'));
     [bootstat,bootsam] = bootstrp(50000,scorr,ssrt(signSubjectIndices)',sSTOP_DAI(:,iFreq));
    
     alpha=0.05/6; % 6 tests, one per frequency
    
     CI = prctile(bootstat,[100*alpha,100*(1-alpha)]);
     confidenI(1,iTest)=CI(1);
     confidenI(2,iTest)=CI(2);
     rhoBoot(1,iTest)=mean(bootstat);
      
 end
  
% print CI
confidenI
iSignFreqIndex = 18; % corresponds with 34 Hz

% plotting
figure;
set(gcf, 'Position', [1, 1, 750, 500]);

sSTOP_DAI=daiStop(signSubjectIndices,iSignFreqIndex);
p=polyfit(sSTOP_DAI,ssrt(signSubjectIndices)',1); % generate the coefficients of polynomial of degree(1)
y=polyval(p,sSTOP_DAI);
scatter(sSTOP_DAI,ssrt(signSubjectIndices),'filled', 'MarkerFaceColor',[0.25,0.25,0.25])
hold on;
plot(sSTOP_DAI,y,'k-','LineWidth',1);
hold on;
plot([0 0],[150 350], '--', 'color',[0.5,0.5,0.5], 'LineWidth',1);

xlabel({['preSMA \fontname{Arial}', 8594, ' r-IFG           r-IFG \fontname{Arial}', 8594, 'preSMA']; ''; 'DAI - Spectral GC at 34 Hz'});
ylabel('SSRT  (ms)')   
xlim([-0.5 1]);
xticks([-0.5:0.5:1]);
ylim([150 350]);
yticks([150:50:350]);

h = zeros(1, 1);
h(1) = plot(NaN,NaN,'-', 'color',[0 0 0], 'LineWidth',1);
legend(h, sprintf('$r=%0.3f$', rhoBoot(3)), 'Interpreter','latex');

set(gca,'TickLength',[0.02, 0.02]);        
set(gca, 'FontSize',14);
box on;
