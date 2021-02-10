function TFRSensorStatsTaskvsBaselinePooled()

    strInputFilePrefix = 'MTMcon';
    
    strTimeSegmentTask = '-0.20_0.50';
    strTimeSegmentBaseline = '-0.20_0.50';
    
    % for beta band
    freq = [4 45];
    strTaper = 'hanning';     
        
    % for gamma band     
    %freq = [45 120];
    %strTaper = 'dpss'; 
        
    strOutputFilePrefix = 'GrandAverage';

    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();
    
    vsSubjects = GetSubjectList();
    vsConditions = GetConditionList();
    vsChannelSelection = {'MEG'};

    % get grad from any subject
    load(sprintf('%sMATLABScripts/SharedFunctions/ctf275.mat', strProjectRoot)); % loads 'grad'


    lFreq = freq(1);
    uFreq = freq(2);
    strFreqRange = sprintf('%d-%d',freq(1,1), freq(1,2));

    strTFRInputPath = sprintf('%sTFR/%sHz/SingleSubjects/', strProjectRoot, strFreqRange);
    strTFROutputPath = sprintf('%sTFR/%sHz/StatsOverSubjects/', strProjectRoot, strFreqRange);
    if ~exist(strTFROutputPath, 'dir')
        mkdir(strTFROutputPath);
    end

    task = {};
    baseline = {};

    for iSubj = 1:size(vsSubjects,1)

        strSourcePathTask_cAC = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, vsConditions{5,1}, vsSubjects{iSubj,1}, strTimeSegmentTask, strTaper);
        strSourcePathTask_sSTOP = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, vsConditions{3,1}, vsSubjects{iSubj,1}, strTimeSegmentTask, strTaper);

        strSourcePathBase_cAC = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, vsConditions{6,1}, vsSubjects{iSubj,1}, strTimeSegmentBaseline, strTaper);
        strSourcePathBase_sSTOP = sprintf('%s%s_%s_%d_%s_%s_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, vsConditions{4,1}, vsSubjects{iSubj,1}, strTimeSegmentBaseline, strTaper);

        disp(strSourcePathTask_cAC);
        load(strSourcePathTask_cAC); % contains TFRmult
        TaskTFR_cAC = TFRmult;
        disp(strSourcePathTask_sSTOP);
        load(strSourcePathTask_sSTOP); % contains TFRmult
        TaskTFR_sSTOP = TFRmult;

        disp(strSourcePathBase_cAC);
        load(strSourcePathBase_cAC); % contains TFRmult
        BaselineTFR_cAC = TFRmult;
        disp(strSourcePathBase_sSTOP);
        load(strSourcePathBase_sSTOP); % contains TFRmult
        BaselineTFR_sSTOP = TFRmult;

        cfg = [];
        cfg.channel = vsChannelSelection;

        TaskTFR_cAC = ft_freqdescriptives(cfg, TaskTFR_cAC);
        TaskTFR_sSTOP = ft_freqdescriptives(cfg, TaskTFR_sSTOP);
        BaselineTFR_cAC = ft_freqdescriptives(cfg, BaselineTFR_cAC);
        BaselineTFR_sSTOP = ft_freqdescriptives(cfg, BaselineTFR_sSTOP);

        cfg = [];
        cfg.keepindividual   = 'no';
        cfg.foilim           = 'all';
        dimord = 'chan_freq_time';

        cfg.toilim           = 'all'; 
        TaskTFR          = ft_freqgrandaverage(cfg, TaskTFR_cAC(:), TaskTFR_sSTOP(:));
        TaskTFR.dimord   = dimord;

        cfg.toilim               = 'all';        
        BaselineTFR          = ft_freqgrandaverage(cfg, BaselineTFR_cAC(:), BaselineTFR_sSTOP(:));
        BaselineTFR.dimord   = dimord;

        BaselineTFR.time     = TaskTFR.time;

        task{end+1} = TaskTFR;
        baseline{end+1} = BaselineTFR;

    end % pool over subjects


    cfg = [];
    cfg.method     = 'distance';
    cfg.grad       = grad;
    cfg.channel = vsChannelSelection;

    cfg.neighbours = ft_prepare_neighbours(cfg, task{1}); % goes for the grad

    cfg.statistic = 'depsamplesT';
    cfg.method    = 'montecarlo';
    cfg.frequency = 'all'; 
    cfg.latency   = 'all'; 

    cfg.correctm = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum'; 
    cfg.tail             = 0; 
    cfg.clustertail      = 0; 
    cfg.correcttail = 'alpha';

    cfg.alpha            = 0.05; % 
    cfg.numrandomization = 5000;

    cfg.avgovertime      = 'no';
    cfg.avgoverchan      = 'yes';

    cfg.parameter        = 'powspctrm';

    cfg.ivar      = 1;
    cfg.uvar      = 2;

    cfg.design    = [ ones(1,length(task)) ones(1,length(baseline))*2; ...
        1:length(task) 1:length(baseline) ];
    freqStat = ft_freqstatistics(cfg, task{:}, baseline{:});

end


