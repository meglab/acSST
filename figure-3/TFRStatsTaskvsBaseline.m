function [bRet] = TFRStatsTaskvsBaseline(iCond, iVoxel)

    % creates data for figure 3A+B
    % one file per source / voxel

    bRet = false;

    addpath('./../SharedFunctions');
    addpath('./../Behavioral');
    strProjectRoot = SetPaths();

    vsSubjects = GetSubjectList();
    [ viSubjectExcludes, iNumSets ] = GetSubjectExlusions(10);
    vsSubjects(viSubjectExcludes,:) = [];

    vsConditions = GetConditionList_sSTOP_cAC();

    iFreq = 1; 
    freq = [2 44];
    strTransformationMethod = 'Hanning_3cycles';

    % output path
    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));

    lFreq = freq(1);
    uFreq = freq(2);
    strFreqRange = sprintf('%d-%dHz',freq(1,1), freq(1,2));

    strTFRInputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_%s/', strProjectRoot, iFreq, strTransformationMethod);
    strTFROutputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/StatsOverSubjects_%s/', strProjectRoot, iFreq, strTransformationMethod);

    if ~exist(strTFROutputPath, 'dir')
        mkdir(strTFROutputPath);
    end

    task = {};
    baseline = {};

    for iSubj = 1:size(vsSubjects,1)

        strSourcePathTask = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{iCond,1}, vsSubjects{iSubj,1});
        strSourcePathBase = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange,  strTimeInterval, vsConditions{iCond+1,1}, vsSubjects{iSubj,1});

        load(strSourcePathTask); % contains TFRmult
        TaskTFR = TFRmult;

        load(strSourcePathBase); % contains TFRmult
        BaselineTFR = TFRmult;

        iMinNumTrials = min( [ size(TaskTFR.powspctrm,1), size(BaselineTFR.powspctrm,1) ] );

        if size(TaskTFR.powspctrm,1) > iMinNumTrials
            TaskTFR.powspctrm = TaskTFR.powspctrm([1:iMinNumTrials],:,:,:);
            TaskTFR.trialinfo = TaskTFR.trialinfo([1:iMinNumTrials],:);
        end
        if size(BaselineTFR.powspctrm,1) > iMinNumTrials
            BaselineTFR.powspctrm = BaselineTFR.powspctrm([1:iMinNumTrials],:,:,:);
            BaselineTFR.trialinfo = BaselineTFR.trialinfo([1:iMinNumTrials],:);
        end

        cfg = [];
        TaskTFR = ft_freqdescriptives(cfg, TaskTFR);
        BaselineTFR = ft_freqdescriptives(cfg, BaselineTFR);

        cfg = [];
        cfg.keepindividual   = 'no';
        cfg.foilim           = 'all';
        dimord = 'rpt_chan_freq_time';

        % actual no ft_freqgrandaverage required; just redefine time scale
        cfg.toilim     = [ 0 0.5 ];
        taskStats      = cfg.toilim;
        TaskTFR        = ft_freqgrandaverage(cfg, TaskTFR(:));
        TaskTFR.dimord = dimord;

        % baseline interval
        cfg.toilim         = [ -0.1 0.4 ];
        baselineStats      = cfg.toilim;
        BaselineTFR        = ft_freqgrandaverage(cfg, BaselineTFR(:));
        BaselineTFR.dimord = dimord;

        BaselineTFR.time   = TaskTFR.time;

        task{end+1} = TaskTFR;
        baseline{end+1} = BaselineTFR;

    end % pool over subjects

    [ viVoxelIDs, viMNICoordAndLabels ] = GetVoxelList(strProjectRoot);

    strChannelID = sprintf('VirtualChannel_%d_pc1', viVoxelIDs(1,iVoxel));
    strChannelName = sprintf('%s', viMNICoordAndLabels{iVoxel,4});

    cfg = [];
    cfg.channel = strChannelID;

    cfg.statistic = 'ft_statfun_depsamplesT';
    cfg.method    = 'montecarlo';
    cfg.frequency = [lFreq uFreq];
    cfg.latency   = [0 0.5];

    cfg.correctm = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum';

    cfg.tail             = 0; % two sided test
    cfg.clustertail      = 0;
    cfg.alpha            = 0.05;
    cfg.correcttail = 'alpha';

    cfg.numrandomization = 5000;

    cfg.avgovertime      = 'no'; % 'yes';
    cfg.avgoverchan      = 'no'; % 'yes';

    cfg.parameter        = 'powspctrm';

    cfg.ivar      = 1;
    cfg.uvar      = 2;

    cfg.design    = [ ones(1,length(task)) ones(1,length(baseline))*2; 1:length(task) 1:length(baseline) ];
    freqStat = ft_freqstatistics(cfg, task{:}, baseline{:});
    strFreqRangeStat = sprintf('%d-%dHz', cfg.frequency(1,1), cfg.frequency(1,2));

    strTimeIntervalStats = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineStats(1), baselineStats(2), taskStats(1), taskStats(2));
    disp(strTimeIntervalStats);

    strOutputFilePath = sprintf('%sFreqStats_%s_%s_%s_%s_vs_baseline.mat', strTFROutputPath, strFreqRangeStat, strTimeIntervalStats, strChannelName, vsConditions{iCond,2});
    save(strOutputFilePath, 'freqStat');


    bRet = true;
end

