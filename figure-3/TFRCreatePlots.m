function TFRCreatePlots()

    iFreq = 1;
    
    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();
    addpath('./../SharedFunctions/export_fig');
    addpath('./../SharedFunctions/cbrewer');
    
    vsAllConditions = GetConditionList_sSTOP_cAC();
    vsAllConditions(4,:) = [];
    vsAllConditions(2,:) = [];
    
    bPlotSingleConditions = true;
    
    vsConditions{1,1} =  vsAllConditions{1,1};
    vsConditions{1,2} =  vsAllConditions{1,2};
    vsConditions{2,1} =  vsAllConditions{2,1};
    vsConditions{2,2} =  vsAllConditions{2,2};
    
   vTimeWindowStats = [ 0, 0.5 ];
   iTimeWin = 1;
        
   viFreqLimits = [2 44];
   viFreqLimitsPlot = [8 44];
   vZlim = [ -0.5 0.5 ];
   strTransformationMethod = 'Hanning_3cycles';
   viVoxelsPerPage = { [ 4 5 6 7 3 2 1 ]}; % lPMC, rPMC, lMFG, lAI, lIFG, preSMA, rIFG
   viYScale = [ -0.1 0.1; -0.1 0.1; -0.1 0.1; -0.25 0.0; -0.2 -0.05; -0.2 0.05; -0.05 0.2];
   [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);
   
   strFreqRange = sprintf('%d-%dHz', viFreqLimits(1), viFreqLimits(2) );
   
   strStatParametersCond = 'tail_0_a_0.0500_ca_0.0500000';
   strStatParametersContrast = 'tail_0';
   
   strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));
   strTimeIntervalContrast = sprintf('%.2f_%.2fs', taskInterval(1), taskInterval(2));
   
   strTFRInputPathCond = sprintf('%sTFR/VirtualChannelTFR/v%d/StatsOverSubjects_%s/', strProjectRoot, iFreq, strTransformationMethod);
   strTFRInputPathStats = sprintf('%sTFR/VirtualChannelTFR/v%d/StatsConditionContrast_%s/', strProjectRoot, iFreq, strTransformationMethod);
   strTFRInputPathDeltaZ = sprintf('%sTFR/VirtualChannelTFR/v%d/AveragedOverSubjects_zValues_%s/', strProjectRoot, iFreq, strTransformationMethod);
   
   strTFROutputFolder = sprintf('%sFigures/VirtualChannelTFR/v%d/StatsOverSubjects_%s/', ...
       strProjectRoot, iFreq, strTransformationMethod);
   if ~exist(strTFROutputFolder)
       mkdir(strTFROutputFolder)
   end
   
   load(sprintf('%sGrandAverage_%s_sSTOP_zValues.mat', strTFRInputPathDeltaZ, strFreqRange)); % loads 'Grandavg_z_sSTOP'
   load(sprintf('%sGrandAverage_%s_cAC_zValues.mat', strTFRInputPathDeltaZ, strFreqRange)); % loads 'Grandavg_z_cAC'
   
   % only keep beta freq range
   viBetaFreqRange = [10:28]; % 12-32Hz
   %viBetaFreqRange = [12:28]; % 14-32Hz
   Grandavg_z_sSTOP.powspctrm = Grandavg_z_sSTOP.powspctrm(:,:,viBetaFreqRange,:);
   Grandavg_z_cAC.powspctrm = Grandavg_z_cAC.powspctrm(:,:,viBetaFreqRange,:);
   
   % mean over beta range
   Grandavg_z_sSTOP.powspctrm = mean(Grandavg_z_sSTOP.powspctrm,3,'omitnan');
   Grandavg_z_cAC.powspctrm = mean(Grandavg_z_cAC.powspctrm,3,'omitnan');
   
   [ viVoxelIDs, viMNICoordAndLabels ] = GetVoxelList(strProjectRoot);
   
   % setup subplot layout
   viColPos =    [ 0.04 0.26 0.48 0.76 ];
   viColWidth =  [ 0.175 0.175 0.25 0.2 ];
   iNumCols = 4;
   
   cGreen = [1/255 127/255 28/255];
   cRed = [213/255 94/255 0/255];
   cBlue = [0/255 114/255 178/255];

   for iPage = 1:size(viVoxelsPerPage,1)
       
       iNumVoxel = length(viVoxelsPerPage{iPage,1});
       dbRowHeight = 1/iNumVoxel;
       dbRowGraphHeight = 1/(iNumVoxel)*0.8;
       viRowPos =    [ 0.02:dbRowHeight:(1-dbRowHeight+0.02) ];
       viRowHeight = repmat(dbRowGraphHeight,1,iNumVoxel);
       
       figure
       set(gcf, 'Position', [1, 1, 1200, 1000]);
       
       iRow = 0;
       for iVoxel = viVoxelsPerPage{iPage,1}
           iRow = iRow + 1;
           
           if bPlotSingleConditions
               for iCond = 1:size(vsConditions,1)
                   
                   strSourcePathCond = sprintf('%sFreqStats_%s_%s_%s_%s_vs_baseline_%s.mat', ...
                                        strTFRInputPathCond, strFreqRange, strTimeInterval, viMNICoordAndLabels{iVoxel,4}, vsConditions{iCond,2}, strStatParametersCond);
                   load(strSourcePathCond); % loads 'freqStat'
                   [cfg] = GetPlotConfigStats();
                   axes('Position',[viColPos(iCond) viRowPos(iRow) viColWidth(iCond) viRowHeight(iRow)]);
                   ft_singleplotTFR(cfg, freqStat);
                   hold on;
                   strTitle = GetTitle(viMNICoordAndLabels, iVoxel, sprintf(' - %s', vsConditions{iCond,2}));
                   FormatPlot(gca, [0, 130], viFreqLimitsPlot, false, false);
                   
               end
           end
           
           % add line plot overaged beta power with SEM as bounderies
           iNumSubj = size(Grandavg_z_sSTOP.powspctrm,1);
           
           vAverage_sSTOP = mean(Grandavg_z_sSTOP.powspctrm(:,iVoxel,:,:), 1, 'omitnan');
           vAverage_sSTOP = reshape(vAverage_sSTOP,[1,size(vAverage_sSTOP,4)]);
           vSEM_sSTOP = std(Grandavg_z_sSTOP.powspctrm(:,iVoxel,:,:), 1, 'omitnan') / sqrt(iNumSubj);
           vSEM_sSTOP = reshape(vSEM_sSTOP,[1,size(vSEM_sSTOP,4)]);
           
           vAverage_cAC = mean(Grandavg_z_cAC.powspctrm(:,iVoxel,:,:), 1, 'omitnan');
           vAverage_cAC = reshape(vAverage_cAC,[1,size(vAverage_cAC,4)]);
           vSEM_cAC = std(Grandavg_z_cAC.powspctrm(:,iVoxel,:,:), 1, 'omitnan') / sqrt(iNumSubj);
           vSEM_cAC = reshape(vSEM_cAC,[1,size(vSEM_cAC,4)]);
           
           axes('Position',[viColPos(iNumCols) viRowPos(iRow) viColWidth(iNumCols) viRowHeight(iRow)]);                      
           
           vAverage_sSTOP(isnan(vAverage_sSTOP))=0;
           vAverage_cAC(isnan(vAverage_cAC))=0;
           vSEM_sSTOP(isnan(vSEM_sSTOP))=0;
           vSEM_cAC(isnan(vSEM_cAC))=0;
           
           xconf = [Grandavg_z_sSTOP.time Grandavg_z_sSTOP.time(end:-1:1)] ;
           yconf_sSTOP = [vAverage_sSTOP+vSEM_sSTOP vAverage_sSTOP(end:-1:1)-vSEM_sSTOP(end:-1:1)];
           yconf_cAC = [vAverage_cAC+vSEM_cAC vAverage_cAC(end:-1:1)-vSEM_cAC(end:-1:1)];
           
           hold on
           p_sSTOP = fill(xconf, yconf_sSTOP,'red');
           p_sSTOP.FaceColor = cRed;
           p_sSTOP.EdgeColor = 'none';
           p_sSTOP.FaceAlpha = 0.3;
           
           p_cAC = fill(xconf, yconf_cAC,'blue');
           p_cAC.FaceColor = cBlue;
           p_cAC.EdgeColor = 'none';
           p_cAC.FaceAlpha = 0.3;
           
           plot(Grandavg_z_sSTOP.time,vAverage_sSTOP,'color',cRed)
           plot(Grandavg_z_sSTOP.time,vAverage_cAC,'color',cBlue)
           hold off
           
           FormatPlot(gca, ylim, viFreqLimits, true, true)
           ylim([viYScale(iVoxel,1), viYScale(iVoxel,2) ]);
           
           strCond1 = strrep(vsConditions{1,2},'_target','');
           strCond2 = strrep(vsConditions{2,2},'_target','');
           
           strSourcePathStats = sprintf('%sFreqStats_%s_vs_%s_%s_%s_%0.2f_%0.2fs_%s_v%d.mat', ...
               strTFRInputPathStats, strCond1, strCond2, viMNICoordAndLabels{iVoxel,4}, strFreqRange, vTimeWindowStats(iTimeWin,1), vTimeWindowStats(iTimeWin,2), strStatParametersContrast, iFreq);
           strInputFilePathDeltaZ = sprintf('%sGrandAverage_%s_delta_zValues_%s_%s.mat', strTFRInputPathDeltaZ, strFreqRange, strCond1, strCond2);
           
           load(strSourcePathStats); % loads freqStat
           [cfg] = GetPlotConfigStats();
           axes('Position',[viColPos(iNumCols-1) viRowPos(iRow) viColWidth(iNumCols-1) viRowHeight(iRow)]);
           ft_singleplotTFR(cfg, freqStat);
           hold on;
           strTitle = GetTitle(viMNICoordAndLabels, iVoxel, sprintf(' - z(%s) vs. z(%s)', strCond1, strCond2));
           FormatPlot(gca, [0, 130], viFreqLimitsPlot, true, false);
           
       end
       
       strExpFormat = 'svg';
       strTFROutputPath = sprintf('%sAll_VC_TFRs_%s_%s_%0.2f_%0.2f_%s_vs_%s_page%d_rev.%s', ...
           strTFROutputFolder, strFreqRange, strStatParametersCond, vTimeWindowStats(1), vTimeWindowStats(2), strCond1, strCond2, iPage, strExpFormat);
       saveas(gcf,strTFROutputPath, strExpFormat);       
       
   end

end


function FormatPlot(gca, yLimits, viFreqLimits, bAddScale, bOnlyXScale)
   
    set(gca, 'FontSize',10);
    
    strTitle = ' ';
    hTitle = title(strTitle);
    set(hTitle, 'FontSize', 6);

    ax = gca;
    ax.XAxis.MinorTick = 'on';
           
    if ~bOnlyXScale
        ax.YAxis.MinorTick = 'on';
        ylim(viFreqLimits);
    end
    
    xlim([0,0.5]);
    xticks([0:0.1:0.5]);
    ax.XAxis.MinorTickValues = 0:0.05:0.5;
    
    if ~bOnlyXScale
        yticks([10:10:40]);
        ax.YAxis.MinorTickValues = 10:5:50;
    end

    set(gca,'TickLength',[0.04, 0.02]);
    box on;
    
    hold on;            
    
    colors = cbrewer('div', 'RdBu', 64);
    % set grey for NaNs
    colors(64,1) = 0.8;
    colors(64,2) = 0.8;
    colors(64,3) = 0.8;
    colormap(flipud(colors));    
    
    if ~bAddScale
        colorbar('off');
    end   
    
    plot([0.244, 0.244], yLimits, '-', 'Color', 'k', 'LineWidth', 0.75); % SSRT_median
    plot([0.350, 0.350], yLimits, '-', 'Color', 'k', 'LineWidth', 0.75); % SSRT_max
    % see AnalyseRTs.m for RT percentiles
    plot([0.273, 0.273], yLimits, ':', 'Color', 'k', 'LineWidth', 0.75); % 10% perc.
    plot([0.359, 0.359], yLimits, ':', 'Color', 'k', 'LineWidth', 0.75); % 50% perc.
    
    hold on; 
end
    
 
function [cfg] = GetPlotConfigDeltaZ(iVoxelID)

    cfg = [];  
    cfg.zlim = [ -0.2 0.2];                      
    cfg.channel = sprintf('VirtualChannel_%d_pc1', iVoxelID);
    cfg.parameter = 'powspctrm';    
    
end

function [cfg] = GetPlotConfigStats()

    cfg = [];
    cfg.zlim = [ -7 7 ];               
    cfg.parameter = 'stat';    
    cfg.maskparameter = 'mask';                
    cfg.maskstyle = 'outline';
    %cfg.maskstyle = 'opacity'; 
    cfg.maskalpha = 0.2;  
    
end


function [strTitle] = GetTitle(viMNICoordAndLabels, iVoxel, strSuffix)
    
    strTitle = sprintf('%s (MNI %d,%d,%d) %s', viMNICoordAndLabels{iVoxel,4}, ...
                        viMNICoordAndLabels{iVoxel,1}, viMNICoordAndLabels{iVoxel,2}, viMNICoordAndLabels{iVoxel,3}, strSuffix);
    strTitle = strrep(strTitle, '_', '\_');
    
end



