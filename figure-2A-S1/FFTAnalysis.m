function bRet = FFTAnalysis(iSubj)

    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();
    
    strInputDir  = sprintf('%sPreprocessedData/Preproc5_RejectedShortRTAndDetrend/', strProjectRoot);

    freq = [4 120];
    strTaskInterval = '0.100_0.350';
    strBaselineInterval = '0.150_0.400';
    
    lFreq = freq(1);
    uFreq = freq(2);

    [ str1, str2 ] = strtok(strTaskInterval,'_');
    str2 = str2(2:end);
    dbTaskBegin = str2num(str1);
    dbTaskEnd = str2num(str2);

    [ str1, str2 ] = strtok(strBaselineInterval,'_');
    str2 = str2(2:end);
    dbBaselineBegin = str2num(str1);
    dbBaselineEnd = str2num(str2);

    vsSubjects = GetSubjectList();   
    vsConditions = GetConditionList_sSTOP_cAC();

    % output path
    strFreqRange = sprintf('%d-%d',freq(1,1), freq(1,2));
    strFFTOutputPath =  sprintf('%sFFT/%sHz/SingleSubjects/', strProjectRoot, strFreqRange);

    if ~exist(strFFTOutputPath, 'dir')
        mkdir(strFFTOutputPath);
    end

    for iCond = 1:size(vsConditions,1)

        strSubject = sprintf('%s', vsSubjects{iSubj,1});
        strCondition = sprintf('%s', vsConditions{iCond,2});

        % input path
        strSourcePath = sprintf('%s%s_%d_Preproc5_%dms.mat', strInputDir, strSubject, vsConditions{iCond,1}, GetSSRTFilterThreshold(true));

        load(strSourcePath); % loads 'AllTrlData'

        cfg = [];
        if vsConditions{iCond,1} >= 10
            cfg.toilim = [ dbBaselineBegin dbBaselineEnd ];
        else
            cfg.toilim = [ dbTaskBegin dbTaskEnd ];
        end
        AllTrlData = ft_redefinetrial(cfg, AllTrlData);

        cfg = [];
        cfg.output     = 'pow';
        cfg.channel    = 'MEG';
        cfg.method     = 'mtmfft';
        cfg.foilim      = [ freq(1,1) freq(1,2) ];

        if vsConditions{iCond,1} >= 10 % baseline
            cfg.toi        = 'all';
            strTimeRage = strBaselineInterval;
        else
            cfg.toi        = 'all'; % task
            strTimeRage = strTaskInterval;
        end

        cfg.taper      = 'hanning'; 
        cfg.pad        = 'maxperlen'; 
        cfg.keeptrials = 'yes';

        FFTmult = ft_freqanalysis(cfg, AllTrlData);

        FFTmult.cfg.previous = [];
        FFTmult.trialinfo = AllTrlData.trialinfo;
        strOutputFilePath = sprintf('%sMTMFFT_%s_%d_%s_%s_%s.mat',strFFTOutputPath, strFreqRange, vsConditions{iCond,1}, strSubject, strTimeRage, cfg.taper);
        save(strOutputFilePath, 'FFTmult', '-v7.3');
    end

    bRet = true;
end