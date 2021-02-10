addpath('./../SharedFunctions');
strProjectRoot = SetPaths();

freq = [4 120];
strTimeSegmentTask = '0.100_0.350';
strTimeSegmentBaseline = '0.150_0.400';

strInputFilePrefix = 'MTMFFT';
strOutputFilePrefix = 'GrandAverage';

strTaper = 'hanning';

vsSubjects = GetSubjectList();    
vsConditions = GetConditionList();

% get grad from any subject
strFilePathRawData = sprintf('%sPreprocessedData/Preproc4_RejectedShortRTAndDetrend/AHK88_2_Preproc4_%dms.mat', strProjectRoot, GetSSRTFilterThreshold(true));

% get grad from any subject
load(strFilePathRawData); % contains AllTrlData and therefor grad
grad = AllTrlData.hdr.grad;
clear AllTrlData;

%[ freq, strTimeSegmentTask, bBaseLineCorrection, strTimeSegmentBaseline, viBaselineIndices ] = GetTFRParameters(iFreq);

lFreq = freq(1);
uFreq = freq(2);
strFreqRange = sprintf('%d-%d',freq(1,1), freq(1,2));

strFFTInputPath = sprintf('%sFFT/%sHz/SingleSubjects/', strProjectRoot, strFreqRange);
strFFTOutputPath = sprintf('%sFFT/%sHz/StatsOverSubjects/', strProjectRoot, strFreqRange);
if ~exist(strFFTOutputPath, 'dir')
    mkdir(strFFTOutputPath);
end

task = {};
baseline = {};

for iSubj = 1:size(vsSubjects,1)

    strSourcePathTask_cAC = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strFFTInputPath, strInputFilePrefix, strFreqRange, vsConditions{5,1}, vsSubjects{iSubj,1}, strTimeSegmentTask, strTaper);
    strSourcePathTask_sSTOP = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strFFTInputPath, strInputFilePrefix, strFreqRange, vsConditions{3,1}, vsSubjects{iSubj,1}, strTimeSegmentTask, strTaper);    
    strSourcePathBase_cAC = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strFFTInputPath, strInputFilePrefix, strFreqRange, vsConditions{6,1}, vsSubjects{iSubj,1}, strTimeSegmentBaseline, strTaper);
    strSourcePathBase_sSTOP = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strFFTInputPath, strInputFilePrefix, strFreqRange, vsConditions{4,1}, vsSubjects{iSubj,1}, strTimeSegmentBaseline, strTaper);

    try
        disp(strSourcePathTask_cAC);
        load(strSourcePathTask_cAC); % contains FFTmult
        TaskFFT_cAC = FFTmult;
        disp(strSourcePathTask_sSTOP);
        load(strSourcePathTask_sSTOP); % contains FFTmult
        TaskFFT_sSTOP = FFTmult;

        disp(strSourcePathBase_cAC);
        load(strSourcePathBase_cAC); % contains FFTmult
        BaselineFFT_cAC = FFTmult;
        disp(strSourcePathBase_sSTOP);
        load(strSourcePathBase_sSTOP); % contains FFTmult
        BaselineFFT_sSTOP = FFTmult;
    catch
        strMessage = sprintf('Could not load file %s%s_%s_*_%s_*.mat', strFFTInputPath, strInputFilePrefix, strFreqRange, vsSubjects{iSubj,1});
        disp(strMessage);
        continue;
    end    

    cfg = [];
    cfg.channel = {'MEG', '-MLP31', '-MRC12', '-MRF22', '-MRF24', '-MRO21', '-MZC02'};  

    TaskFFT_cAC = ft_freqdescriptives(cfg, TaskFFT_cAC);
    TaskFFT_sSTOP = ft_freqdescriptives(cfg, TaskFFT_sSTOP);
    BaselineFFT_cAC = ft_freqdescriptives(cfg, BaselineFFT_cAC);
    BaselineFFT_sSTOP = ft_freqdescriptives(cfg, BaselineFFT_sSTOP);

    cfg = [];
    cfg.keepindividual   = 'no';
    cfg.foilim           = 'all';

    dimord = 'chan_freq';

    cfg.toilim           = 'all'; 
    TaskFFT          = ft_freqgrandaverage(cfg, TaskFFT_cAC(:), TaskFFT_sSTOP(:));
    TaskFFT.dimord   = dimord;

    cfg.toilim               = 'all';
    BaselineFFT          = ft_freqgrandaverage(cfg, BaselineFFT_cAC(:), BaselineFFT_sSTOP(:));
    BaselineFFT.dimord   = dimord;

    task{end+1} = TaskFFT;
    baseline{end+1} = BaselineFFT;

end % pool over subjects


cfg = [];
cfg.method     = 'distance';
cfg.grad       = grad;
cfg.channel = {'MEG', '-MLP31', '-MRC12', '-MRF22', '-MRF24', '-MRO21', '-MZC02'};
cfg.neighbours = ft_prepare_neighbours(cfg, task{1}); % goes for the grad

cfg.statistic = 'depsamplesT';
cfg.method    = 'montecarlo';
cfg.frequency = 'all'; 
cfg.latency   = 'all'; 

cfg.correctm = 'cluster';
cfg.clusteralpha     = 0.01;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0; 
cfg.clustertail      = 0; 
cfg.correcttail = 'alpha';
cfg.alpha            = 0.01;
cfg.numrandomization = 5000;
cfg.avgoverchan      = 'yes';
cfg.parameter        = 'powspctrm';

cfg.ivar      = 1;
cfg.uvar      = 2;

cfg.design    = [ ones(1,length(task)) ones(1,length(baseline))*2; ...
    1:length(task) 1:length(baseline) ];
freqStat = ft_freqstatistics(cfg, task{:}, baseline{:});

strOutputFilePath = sprintf('%sFreqStats_%s_%ss_pooled_task_vs_baseline.mat', strFFTOutputPath, strFreqRange, strTimeSegmentTask);
save(strOutputFilePath, 'freqStat');


find(freqStat.mask==1)

figure;
set(gcf, 'Position', [1, 1, 400, 300]);
set(gca,'FontSize',14); 
plot(freqStat.freq, freqStat.stat);
hold on;
cluster1_start = 3;  % 12.0
cluster1_end = 8;    % 31.9
cluster2_start = 16; % 63.8
cluster2_end = 22;   % 87.7 

h=fill([freqStat.freq(cluster1_start),freqStat.freq(cluster1_end),freqStat.freq(cluster1_end),freqStat.freq(cluster1_start)],[-10,-10,15,15],[0.5 0.5 0.5], 'LineStyle','none'); % [x] [y] 
h.FaceAlpha=0.3;
h=fill([freqStat.freq(cluster2_start),freqStat.freq(cluster2_end),freqStat.freq(cluster2_end),freqStat.freq(cluster2_start)],[-10,-10,15,15],[0.5 0.5 0.5], 'LineStyle','none'); % [x] [y] 
h.FaceAlpha=0.3;
set(gca,'yTick',[-10:5:10]);
xlim([1,120]);
ylim([-10,10]);
ax = gca;
ax.XAxis.MinorTick = 'on';
set(gca,'TickLength',[0.02, 0.01])

xlabel('Frequency  [Hz]','FontSize',14)
ylabel('t-value','FontSize',14)

set(gca,'FontSize',14);
find(freqStat.mask==1)
[ freqStat.freq(cluster1_start) freqStat.freq(cluster1_end) ]
[ freqStat.freq(cluster2_start) freqStat.freq(cluster2_end) ]
