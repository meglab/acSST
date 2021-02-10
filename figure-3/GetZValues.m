function [ bSuccess ] = GetZValues(iFreq, iSubj)

    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();

    vsSubjects = GetSubjectList();    
    vsConditions = GetConditionList_sSTOP_cAC();
    viConds = [1 3];    
    
    % output path
    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);    

    strFreqRange = sprintf('8-44Hz');
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));        
    strTransformationMethod = 'Hanning_3cycles';
    
    strTFRInputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_%s/', strProjectRoot, iFreq, strTransformationMethod);
    strTFROutputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_zValues_%s/', strProjectRoot, iFreq, strTransformationMethod);
    if ~exist(strTFROutputPath, 'dir')
        mkdir(strTFROutputPath);
    end
   
    for iCond = viConds
        
        strSourcePathTask = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{iCond,1}, vsSubjects{iSubj,1});
        strSourcePathBase = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{iCond+1,1}, vsSubjects{iSubj,1});
 
        load(strSourcePathTask); 
        TaskTFRtmp = TFRmult;
        
        load(strSourcePathBase); 
        BaselineTFRtmp = TFRmult;

        % use existing cfg structures etc. for output
        TaskTFR{iCond} = TaskTFRtmp;     
        TaskTFR_BC{iCond} = TaskTFRtmp; % _BC --> baseline corrected
        TaskTFR_BC{iCond}.powspctrm = zeros(size(TaskTFRtmp.powspctrm));
    
        BaselineTFR{iCond} = BaselineTFRtmp; 
        BaselineTFR_BC{iCond} = BaselineTFRtmp; 
        BaselineTFR_BC{iCond}.powspctrm = zeros(size(BaselineTFRtmp.powspctrm));
    
        iLowTime = find(BaselineTFRtmp.time >= baselineInterval(1), 1,'first');
        iHighTime = find(BaselineTFRtmp.time >= baselineInterval(2), 1,'first');             
        viBaselineInd{iCond} = [iLowTime:iHighTime];    
    
        iLowTime = find(TaskTFRtmp.time >= taskInterval(1), 1,'first');
        iHighTime = find(TaskTFRtmp.time >= taskInterval(2), 1,'first');             
        viTaskInd{iCond} = [iLowTime:iHighTime];    
    
    end
    
    % calculate std of both baselines (over all trials and time bins)
    std_bothConditions = getStd(BaselineTFR, viBaselineInd, viConds);           
    
    for iCond = viConds
        
        for iTrial = 1:size(TaskTFR{iCond}.powspctrm, 1)

            taskTrial = TaskTFR{iCond}.powspctrm(iTrial,:,:,:);
            siz             = size(taskTrial);
            taskTrial = reshape(taskTrial, siz(2:end));

            baselineTrial = BaselineTFR{iCond}.powspctrm(iTrial,:,:,:);
            siz                 = size(baselineTrial);
            baselineTrial = reshape(baselineTrial, siz(2:end));

            TaskTFR_BC{iCond}.powspctrm(iTrial,:,:,:) = getZValues(taskTrial, baselineTrial, viBaselineInd{iCond}, std_bothConditions);
            BaselineTFR_BC{iCond}.powspctrm(iTrial,:,:,:) = getZValues(baselineTrial, baselineTrial, viBaselineInd{iCond}, std_bothConditions);
        end
    end
    
    % use ft_freqdescriptives to average over trials
    for iCond = viConds
        
        cfg = [];
        TaskTFR_BLcorr = ft_freqdescriptives(cfg, TaskTFR_BC{iCond});       
        BaselineTFR_BLcorr = ft_freqdescriptives(cfg, BaselineTFR_BC{iCond});       

        strOutputFilePath = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFROutputPath, strFreqRange, strTimeInterval, vsConditions{iCond,1}, vsSubjects{iSubj,1});
        save(strOutputFilePath, 'TaskTFR_BLcorr');      

        strOutputFilePath = sprintf('%sMTMcon_%s_%s_%d_%s_baseline.mat', strTFROutputPath, strFreqRange, strTimeInterval, vsConditions{iCond,1}, vsSubjects{iSubj,1});
        save(strOutputFilePath, 'BaselineTFR_BLcorr');      

    end
    
    bSuccess = true;
end

function std_bothConditions = getStd(baseline, viBaselineInd, viConds)

    % input dimensions (power values in baseline_sSTOP): rpt (trials) x channels x frequencies x time points
    % output dimensions (std values in std_bothConditions): channels x frequencies

    std_bothConditions = [];

    for iChannel = 1:size(baseline{viConds(1)}.powspctrm, 2)

        for iFreq = 1:size(baseline{viConds(1)}.powspctrm, 3)

            vTimeBins = [];
            
            for iCond = viConds
                
                for iTrial = 1:size(baseline{iCond}.powspctrm, 1)

                    vTimeBinsCond = baseline{iCond}.powspctrm(iTrial,iChannel,iFreq,viBaselineInd{iCond});
                    siz            = size(vTimeBinsCond);
                    vTimeBinsCond  = reshape(vTimeBinsCond, [1 siz(end)]);

                    vTimeBins = [ vTimeBins vTimeBinsCond ];

                end
            end
            
            std_bothConditions(iChannel,iFreq) = nanstd(vTimeBins);
        end
    end

end



function dataTaskBC = getZValues(dataTask, dataBaseline, baselineTimes, std_bothConditions)

    if length(size(dataTask)) ~= 3
    	error('time-frequency matrix should have three dimensions (chan,freq,time)');
    end
    
    % compute mean of time/frequency quantity in the baseline interval,
    % ignoring NaNs, and replicate this over time dimension
    meanVals = repmat(nanmean(dataBaseline(:,:,baselineTimes), 3), [1 1 size(dataTask, 3)]);   
    
    stdVals = repmat(std_bothConditions,[1,1,size(dataTask,3)]);   
    
    dataTaskBC = (dataTask - meanVals) ./ stdVals;
    
end