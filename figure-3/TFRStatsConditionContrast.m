function [bRet] = TFRStatsConditionContrast(iVoxel)

	% creates data for figure 3C
    % one file per source / voxel
    
    bRet = false;
    iFreq = 1;
    
    strInputFilePrefix = 'MTMcon';
    
    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();   
    addpath('./../Behavioral');

    vsSubjects = GetSubjectList();
    
    vsConditions = GetConditionList_sSTOP_cAC();        
    vsConditions(4,:) = [];
    vsConditions(2,:) = [];
    
    freq = [2 44];
    strTransformationMethod = 'Hanning_3cycles';
    
    % output path
    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));
    
    lFreq = freq(1);
    uFreq = freq(2);
    strFreqRange = sprintf('%d-%dHz',freq(1,1), freq(1,2));

    strTFRInputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_zValues_%s/', strProjectRoot, iFreq, strTransformationMethod);
    strTFROutputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/StatsConditionContrast_%s/', strProjectRoot, iFreq, strTransformationMethod);

    if ~exist(strTFROutputPath, 'dir')
        mkdir(strTFROutputPath);
    end

    cond1 = {};
    cond2 = {};

    for iSubj = 1:size(vsSubjects,1)
       
        strSourcePath_cond1 = sprintf('%s%s_%s_%s_%d_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, strTimeInterval, vsConditions{iCond1,1}, vsSubjects{iSubj,1});        
        load(strSourcePath_cond1); % loads 'TaskTFR_BLcorr'
        cond1{end+1} = TaskTFR_BLcorr;

        strSourcePath_cond2   = sprintf('%s%s_%s_%s_%d_%s.mat', strTFRInputPath, strInputFilePrefix, strFreqRange, strTimeInterval, vsConditions{iCond2,1}, vsSubjects{iSubj,1});
        load(strSourcePath_cond2); % loads 'TaskTFR_BLcorr'
        cond2{end+1} = TaskTFR_BLcorr;
    end 

    vTimeWindow = [ 0 0.5 ];
    
    [ viVoxelIDs, viMNICoordAndLabels ] = GetVoxelList(strProjectRoot); % beta-band sources

    strChannelID = sprintf('VirtualChannel_%d_pc1', viVoxelIDs(1,iVoxel));
    strChannelName = sprintf('%s', viMNICoordAndLabels{iVoxel,4});
    
    for iTimeWin = 1:size(vTimeWindow,1)

        cfg = [];
        cfg.channel = strChannelID;

        cfg.latency   = [ vTimeWindow(iTimeWin,1) vTimeWindow(iTimeWin,2) ];

        cfg.statistic = 'ft_statfun_depsamplesT';
        cfg.method    = 'montecarlo';
        cfg.frequency = [lFreq uFreq];
        cfg.latency   = [ vTimeWindow(iTimeWin,1) vTimeWindow(iTimeWin,2) ];

        cfg.alpha            = 0.05;
        cfg.correctm         = 'cluster';
        cfg.clusteralpha     = 0.05;
        cfg.clusterstatistic = 'maxsum'; % first analysis: default values
        cfg.correcttail      = 'alpha';      

        cfg.tail             = 0; % two sided test
        cfg.clustertail      = 0;

        cfg.numrandomization = 5000;

        cfg.avgovertime      = 'no';
        cfg.avgoverchan      = 'no';

        cfg.parameter        = 'powspctrm';           

        cfg.ivar      = 1;
        cfg.uvar      = 2;

        cfg.design    = [ ones(1,length(cond1)) ones(1,length(cond2))*2; 1:length(cond1) 1:length(cond2) ];
        freqStat = ft_freqstatistics(cfg, cond1{:}, cond2{:});

        strOutputFilePath = sprintf('%sFreqStats_%s_vs_%s_%s_%s_%0.2f_%0.2fs.mat', ...
                strTFROutputPath, strtok(vsConditions{iCond1,2},'_'), strtok(vsConditions{iCond2,2},'_'), strChannelName, strFreqRange, cfg.latency(1), cfg.latency(2));               
        save(strOutputFilePath, 'freqStat');        
    end

    bRet = true;
end

