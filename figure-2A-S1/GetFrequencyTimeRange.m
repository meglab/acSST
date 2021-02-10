function [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq)
   

    %{
    Task trials

               GO/STOP/AC   
      |----.----|----.----.----.----.----.----.----| 
    -0.2s      0s                                 0.7s


    Baseline trials (offset = -0.2s):
                                        GO
      |----.----|----.----.----.----.----|----.----| 
    -0.2s      0s                       0.5s      0.7s
    %}


   vsFreqTimeWindows = {      
            
        1, [2 150], [-0.1 0.4], [0.0 0.5];  % broad band for virtual channel time course extraction              
        
        % beta band: center frequency 22 Hz, 6 cycles, baseline ends 100ms before go signal
        2, [12 32], [0.1273 0.4], [0.1 0.3727]; 
                  
        % gamma band: center frequency 76 Hz, 19 cycles, baseline ends 100ms before go signal
        3, [64 88], [0.15 0.4], [0.1 0.35];            
        
    };
           
    iCellArray = find(cell2mat(vsFreqTimeWindows(:,1))==iFreq);
    
    freqRange        = vsFreqTimeWindows{iCellArray,2};
    baselineInterval = vsFreqTimeWindows{iCellArray,3};
    taskInterval     = vsFreqTimeWindows{iCellArray,4};
     
end


