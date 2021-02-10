function PlotSpectraSlidingWindows()

    addpath('./../SharedFunctions');
    strProjectRoot = SetPaths();
    addpath('./../SharedFunctions/boundedlineplot/boundedline');
    addpath('./../SharedFunctions/boundedlineplot/catuneven');
    addpath('./../SharedFunctions/boundedlineplot/Inpaint_nans');
    addpath('./../SharedFunctions/boundedlineplot/singlepatch');
    
    load(sprintf('%sGC/SlidingWDataGC_2SurrogateLinksFullyConditioned.mat', strProjectRoot));
    
    vFreqs = [ 0:2:600 ];
    vFreqRange = [1:51];
    viTimeWin = [1:6];

    vsLinksTitle = { 'pre-SMA', 'r-IFG'; ...
                     'r-IFG'  , 'pre-SMA' };    
                 
    iTimeWinStart = -100; % start with -100ms
    iTimeWinLength = 250;
    
    figure;
    set(gcf, 'Position', [1, 1, 1900, 750]);
    
    for iLink = 1:size(vsLinksTitle,1)
        
        if iLink == 1
            iPlotCounter = 6;
        elseif iLink == 2
            iPlotCounter = 0;
        end
        
        for iTimeWin = viTimeWin
            
            iPlotCounter = iPlotCounter + 1;
            subplot(2,6,iPlotCounter);            
     
            nSubjecs = size(data4plotSliding{iLink,iTimeWin}{1,1},1);

            vSpecta_sSTOP = data4plotSliding{iLink,iTimeWin}{1,1}(:,vFreqRange);          
            vSpecta_sSTOP_mean = mean(vSpecta_sSTOP,1);
            sem_sSTOP = std(vSpecta_sSTOP) / sqrt(nSubjecs);

            vSpecta_cAC = data4plotSliding{iLink,iTimeWin}{1,2}(:,vFreqRange);
            vSpecta_cAC_mean = mean(vSpecta_cAC,1);  
            sem_cAC = std(vSpecta_cAC) / sqrt(nSubjecs);

            [hLine, hPatch] = boundedline( vFreqs(vFreqRange), vSpecta_cAC_mean, sem_cAC, 'g', ...
                vFreqs(vFreqRange), vSpecta_sSTOP_mean, sem_sSTOP, 'b', ...      
                'transparency', 0.3, 'alpha');         

            cGreen = [1/255 127/255 28/255];
            cRed = [213/255 94/255 0/255];
            cBlue = [0/255 114/255 178/255];
            cYellow = [211/255 145/255 0 0.3];
            
            hLine(1).Color = cBlue;
            hPatch(1).FaceColor = cBlue;
            hLine(2).Color = cRed;
            hPatch(2).FaceColor = cRed;
            ylim([0.01,0.08]);
                        
            [viXStart, viXRange, vProb] = getSignDifference(statistic, iLink, iTimeWin);            
            for iSign = 1:size(viXRange,2)
                if vProb(iSign) <= 0.05/(size(vsLinksTitle,1)*length(viTimeWin))              
                    rectangle('Position', [viXStart(iSign) 0 viXRange(iSign) 1], 'FaceColor', cYellow, 'LineStyle', 'none'); % [0.4 1 0 0.3]
                elseif vProb(iSign) <= 0.05
                    rectangle('Position', [viXStart(iSign) 0 viXRange(iSign) 1], 'FaceColor', [0.5 0.5 0.5 0.2], 'LineStyle', 'none'); % yellow: [1 1 0 0.2]
                else
                    % no box
                end
            end                       
            
            strLink = [vsLinksTitle{iLink,1},' \fontname{Arial}', 8594, vsLinksTitle{iLink,2}];                               
            strTimeWin = [ num2str(100*iTimeWin+2*iTimeWinStart), 8230,num2str((100*iTimeWin+2*iTimeWinStart)+iTimeWinLength), ' ms'];
          
                if iTimeWin == 1   
                    ylabel(strLink);
                end                
     
                if iLink == 2
                    hTitle = title(  strTimeWin ); 
                end
      
            xline(8);
            xline(44);
            
            yticks([0 0.1]);
            xticks([0:25:100]);
            set(gca,'TickLength',[0.04, 0.04]);        

            box on;

        end
    end
    
end

function [viXStart, viXRange, vProb] = getSignDifference(statistic, iLink, iTimeWin)
    
    viXStart = [];
    viXRange = [];
    vProb = [];

    viSignRange = find(statistic{iLink,iTimeWin}.mask==1);
    
    if isempty(viSignRange)
        return;
    end
        
    % get first and last index value of significant frequency blocks
    [ viRuns ] = getRuns(viSignRange);
    
    for iRun = 1:size(viRuns,1)
            
            viSignFreqs = statistic{iLink,iTimeWin}.time(1,viSignRange); % is originally stored in time instead of freq
            
            % start and end of sign. frequency block
            iStart = statistic{iLink,iTimeWin}.time(1, viRuns(iRun,1) );
            iEnd = statistic{iLink,iTimeWin}.time(1, viRuns(iRun,2) );
            
            viXStart = [ viXStart iStart  ];
            viXRange = [ viXRange iEnd-iStart ];
            vProb    = [ vProb statistic{iLink,iTimeWin}.prob(1, viRuns(iRun,1) ); ];
    end

end



