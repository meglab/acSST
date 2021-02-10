addpath('./../SharedFunctions');
strProjectRoot = SetPaths();
addpath('./../Behavioral');

iFreq = 1;

bUseFailedStop = false; 
%bUseFailedStop = true; % use failed stop instead of successful stop trials
if bUseFailedStop
    strCond = 'fSTOP';
else
    strCond = 'sSTOP';
end

viFreq = [ 12 32 ]; % beta band as obtained by sensor statistics    
tROI = [ 0.1 0.35 ]; % time window of task segments

viChannelLatencies = [];
viChannelFreqs = [];

strInputFilePrefix = 'MTMcon';
strOutputFilePrefix = 'GrandAverage';

vsSubjects = GetSubjectList();

vsConditions = GetConditionList_sSTOP_cAC_fSTOP();

freq = [8 44]; % frequency band width of TFRs
strBand = 'beta';
strFreqRangeTFR = sprintf('%d-%dHz', freq(1), freq(2) );
strTransformationMethod = 'Hanning_3cycles';

strLatencyOutputFolder = sprintf('%sFigures/VirtualChannelTFR/v%d/OnsetLatenciesAndPowerValues_%d-%dHz_%0.2f-%0.2fs/', ...
                                strProjectRoot, iFreq, viFreq(1), viFreq(2), tROI(1), tROI(2));
if ~exist(strLatencyOutputFolder)
    mkdir(strLatencyOutputFolder)
end
strOutputPathLatencies = sprintf('%sLatencyAndBetaPowerValues_%s-cAC.mat', ...
                            strLatencyOutputFolder, strCond);

% parameters of original virtual channel time course data (broad band)
[ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));
lFreq = freq(1);
uFreq = freq(2);
strFreqRange = sprintf('%d-%dHz',freq(1,1), freq(1,2));
strTFRInputPath = sprintf('%sTFR/VirtualChannelTFR/v%d/SingleSubjects_zValues_%s/', strProjectRoot, iFreq, strTransformationMethod);

[ viVoxelIDs, viMNICoordAndLabels ] = GetVoxelList(strProjectRoot);

STOP = {};
fSTOP = {};
cAC = {};
deltaZ = {};

%% get single subject TFRs
for iSubj = 1:size(vsSubjects,1)

    if bUseFailedStop
        strSourcePath_STOP = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{5,1}, vsSubjects{iSubj,1});
    else
        strSourcePath_STOP = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{1,1}, vsSubjects{iSubj,1});
    end

    load(strSourcePath_STOP); % loads 'TaskTFR_BLcorr'
    STOP{end+1} = TaskTFR_BLcorr; % already z transformed

    strSourcePath_cAC   = sprintf('%sMTMcon_%s_%s_%d_%s.mat', strTFRInputPath, strFreqRange, strTimeInterval, vsConditions{3,1}, vsSubjects{iSubj,1});
    load(strSourcePath_cAC); % loads 'TaskTFR_BLcorr'
    cAC{end+1} = TaskTFR_BLcorr; % already z transformed

    deltaZ{end+1} = TaskTFR_BLcorr;
    deltaZ{end}.powspctrm = STOP{end}.powspctrm - cAC{end}.powspctrm;

   end

vLat_rIFG = [];
vLat_preSMA = [];
vBetaPowDiff_max_rIFG = [];
vBetaPowDiff_max_preSMA = [];

vThresholds = [ 0.1 0.25 0.3 0.5 0.75 1 ];

%% get onset latencies and max. power values
for iSubj = 1:size(vsSubjects,1)

    for iVoxel = [ 1 2 ] % 1=rIFG, 2=preSMA

        % get column indices of beta band
        iLowFreq = find(deltaZ{iSubj}.freq >= viFreq(1), 1,'first');
        iHighFreq = find(deltaZ{iSubj}.freq >= viFreq(2), 1,'first');
        viFreqRange = [ iLowFreq:iHighFreq ]; 

        % get column indices of tROI
        iLowTimeTask = find(deltaZ{iSubj}.time >= tROI(1), 1,'first');            
        iHighTimeTask = find(deltaZ{iSubj}.time >= tROI(2), 1,'first');      
        viTimeRange = [ iLowTimeTask:iHighTimeTask ]; 

         % get initial TFR window
        TFRtempAll = deltaZ{iSubj}.powspctrm((iVoxel*2)-1,viFreqRange,:);
        TFRtempAll = reshape(TFRtempAll, size(TFRtempAll,2), size(TFRtempAll,3));

        %% get global max within tROI / freq band from original TFR window
        TFRtemp = deltaZ{iSubj}.powspctrm((iVoxel*2)-1,viFreqRange,viTimeRange);
        TFRtemp = reshape(TFRtemp, (viFreqRange(end)-viFreqRange(1)+1), (viTimeRange(end)-viTimeRange(1)+1));
        [iRow, iCol] = find(ismember(TFRtemp, max(TFRtemp(:))));
        dbMaxTimeDeltaTFR =  deltaZ{iSubj}.time(1,viTimeRange(1)+iCol-1);
        dbMaxFreqDeltaTFR =  deltaZ{iSubj}.freq(1,viFreqRange(1)+iRow-1);                              
        dbMaxPowerDeltaTFR = deltaZ{iSubj}.powspctrm((iVoxel*2)-1,viFreqRange(1)+iRow-1,viTimeRange(1)+iCol-1);            

        TFRtempAll = nanmean(TFRtempAll,1);
        averagedPower_tROI_deltaZ = nanmean(TFRtempAll);

        averagedPowerTimeCourse = smoothdata(TFRtempAll);               
        averagedPowerTimeCourse_tROI = averagedPowerTimeCourse(1,viTimeRange);   

        % get global max from averaged curve (not just first peak)
        dbAveragedTFRDeltaMax = max(max(averagedPowerTimeCourse_tROI));


        %% get peaks from averaged power curve and use first positive peak for latency onset
        bValidPeakFound = false;
        [pks,locs] = findpeaks(averagedPowerTimeCourse_tROI);
        for iPeak = 1:length(pks)               
           if pks(iPeak) >= 0  % posive peaks only
               dbMaxPower = pks(iPeak);
               iColMaxPow = locs(iPeak);
               dbMaxTime = deltaZ{iSubj}.time(1,viTimeRange(1)+iColMaxPow-1);                   
               bValidPeakFound = true;
               break;
           end
        end        

        if bValidPeakFound
            %% get min to set thresholds based an on range between min and max
            [ dbMinPower, viColMinPow ] = min(averagedPowerTimeCourse_tROI(1,[1:iColMaxPow]));
            iColMinPow = viColMinPow(1);
            if dbMinPower < 0
                dbMinPower = 0; % use zero as place holder for missing value
            end

            %% get latency values
            vTimeThresholds = []; 
            vPowerThresholds = [];             
            for iThresholds = 1:length(vThresholds)
                for iTimeCol = (viTimeRange(1)+iColMaxPow):-1:1
                   if averagedPowerTimeCourse(1,iTimeCol) <= (vThresholds(iThresholds)*(dbMaxPower-dbMinPower)+dbMinPower)
                        vTimeThresholds(iThresholds) = deltaZ{iSubj}.time(1,iTimeCol);
                        vPowerThresholds(iThresholds) = averagedPowerTimeCourse(1,iTimeCol);
                        break;
                   end
                end
            end
        end

        if ~bValidPeakFound      
            for iThresholds = 1:length(vThresholds)
                % use zero as placeholder for 'no peak found'
                vTimeThresholds(iThresholds) = 0;
                vPowerThresholds(iThresholds) = 0;
            end
        end

        if iVoxel == 1
            vLat_rIFG    = [ vLat_rIFG; vTimeThresholds ];
            vBetaPowDiff_max_rIFG = [ vBetaPowDiff_max_rIFG; dbMaxPowerDeltaTFR ];
        end
        if iVoxel == 2
            vLat_preSMA = [ vLat_preSMA; vTimeThresholds ];              
            vBetaPowDiff_max_preSMA = [ vBetaPowDiff_max_preSMA; dbMaxPowerDeltaTFR ];                
        end    



    end

end

save(strOutputPathLatencies, 'vLat_rIFG', 'vLat_preSMA', 'vThresholds',  ...
    'vBetaPowDiff_max_rIFG', 'vBetaPowDiff_max_preSMA');


