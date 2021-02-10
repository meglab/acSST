function TestOnsetLatencies(bUseFailedStop)

    % not directly visible in figure 3A/B
    
    % here, we test which source is activated first in the beta band, rIFG or preSMA
        
    % figure 3A shows the group statistics, z(sSTOP) vs. z(cAC), while
    % figure 3B shows the grand average difference, z(sSTOP)-z(cAC)
    % based on the single subject TFRs (z(sSTOP)-z(cAC)), onset latencies were analyzed using this script

    if bUseFailedStop
        strCond = 'fSTOP';
    else
        strCond = 'sSTOP';
    end
    
    load(sprintf('./../data/LatencyAndBetaPowerValues_%s.mat', strCond));
    vThresholds = [ 0.1 0.25 0.3 0.5 0.75 1 ];

    iNumPermutations = 50000;
    
    for iThreshold = 1:length(vThresholds)     
        
        [pValue, n, mean_preSMA, sd_preSMA, mean_IFG, sd_IFG] = PermuationTest(vLat_preSMA(:,iThreshold)', vLat_rIFG(:,iThreshold)', iNumPermutations);
        
        fprintf('\nThreshold %0.3f: IFG: %0.3f %0.3f, preSMA: %0.3f %0.3f, deltaLatency %0.4f, p=%0.4f, n=%d\n', ...
                vThresholds(iThreshold), mean_IFG, sd_IFG, mean_preSMA, sd_preSMA, (mean_preSMA-mean_IFG), pValue, n);    
            
    end

end


function [pValue, n, meanLatency_src1, sdLatency_src1, meanLatency_src2, sdLatency_src2] = PermuationTest(vLatencies_src1, vLatencies_src2, nPermutations)

    if size(vLatencies_src1,2)==1 || size(vLatencies_src2,2)==1
        pValue = 1;
        n = 0;
        meanLatency_src1 = NaN;
        sdLatency_src1 = NaN;
        meanLatency_src2 = NaN;
        sdLatency_src2 = NaN;        
        disp('Error in PermuationTest.m: Incorrect input format. Use row vectors, no columns!');
    end

    % exclude subjects without positive peak (set to zero as placeholder)
    for i=length(vLatencies_src1):-1:1       
        if vLatencies_src1(i)==0 || vLatencies_src2(i)==0
            vLatencies_src1(i) = [];
            vLatencies_src2(i) = [];
        end
    end

    meanLatency_src1 = mean(vLatencies_src1);
    sdLatency_src1 = std(vLatencies_src1);
    meanLatency_src2 = mean(vLatencies_src2);
    sdLatency_src2 = std(vLatencies_src2);

    n = length(vLatencies_src1);
    
    % mean latency from src1 is expected to be greater than from src2
    realMeanDiff = meanLatency_src1 - meanLatency_src2;

    mergedSamples = [vLatencies_src1 vLatencies_src2];

    permMeanDiff = [];
    
    for iPerm=1:nPermutations

        permutedMergedSamples = mergedSamples(randperm(size(mergedSamples,2)));    
        permMeanDiff(iPerm) = mean(permutedMergedSamples(1:size(vLatencies_src1,2))) ...
                              - mean(permutedMergedSamples((size(vLatencies_src1,2)+1):size(mergedSamples,2)));
    end

    % two-tailed
    pValue = length(find(abs(permMeanDiff) > realMeanDiff)) / nPermutations;    

end
