function [ret] = TFRAnalysis(iFreq, iSubj)

    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();

    vsSubjects = GetSubjectList();
    vsConditions = GetConditionList_sSTOP_cAC();

    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
    strFreqRange = sprintf('%d-%dHz', freqRange(1), freqRange(2) );
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));
    strInputDir = sprintf('%s%s/%s/%s/VirtualChannels/', strProjectRoot, GetBeamformerFolder(0,0), strTimeInterval, strFreqRange);
        
    iNumCycles = 3;
    strTFROutputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_Hanning_%dcycles/', strProjectRoot, iFreq, iNumCycles);
    
    for iCond = 1:size(vsConditions,1)

        strSubject = sprintf('%s', vsSubjects{iSubj,1});
        strCondition = sprintf('%s', vsConditions{iCond,2});

        if ~exist(strTFROutputPath, 'dir')
            mkdir(strTFROutputPath);
        end

        % input path
        strSourcePath = sprintf('%s%s_%d_VirtChannel.mat', strInputDir, strSubject, vsConditions{iCond,1});

        try
            load(strSourcePath); % loads 'VChannelDataOut'
        catch
            strMessage = sprintf('Could not load <%s>', strSourcePath);
            disp(strMessage);
            return;
        end

        AllTrlData = VChannelDataOut;

        % Make virtual channel structrure compatible with FieldTrip
        AllTrlData.elec.pnt = [];
        iNumVirtualChannels = size(VChannelDataOut.label,2)/2; % devide by 2 because we get 2 principial components for each channel
        for iElec = 1:iNumVirtualChannels
            AllTrlData.elec.pnt = [AllTrlData.elec.pnt; iElec, 1, 1];
            AllTrlData.elec.pnt = [AllTrlData.elec.pnt; iElec, 2, 2];
        end

        cfg = [];
        cfg.output     = 'pow';        
        cfg.method     = 'mtmconvol';
        cfg.foi        = 8:1:44;
        cfg.t_ftimwin  = iNumCycles./cfg.foi;  % length of time window, should be 3 cycles at least
        cfg.taper      = 'hanning';
        cfg.output     = 'pow';
        cfg.toi        = 'all';
        cfg.pad        = 'maxperlen'; % length in seconds to which the data can be padded out  (Patrick: cfg.pad = 5)
        cfg.keeptrials = 'yes';

        TFRmult = ft_freqanalysis(cfg, AllTrlData);
        TFRmult.cfg.previous = [];
       
        strFreqRange = sprintf('%d-%dHz', cfg.foi(1), cfg.foi(end) );
        strOutputFilePath = sprintf('%sMTMcon_%s_%s_%d_%s.mat',strTFROutputPath, strFreqRange, strTimeInterval, vsConditions{iCond,1}, strSubject);
        save(strOutputFilePath, 'TFRmult', '-v7.3');

        GetZValues(iFreq, iSubj);
    end

    ret = true;
end

