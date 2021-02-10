function [pValue, meanLatency_src1, sdLatency_src1, meanLatency_src2, sdLatency_src2] = PermuationTest(vLatencies_src1, vLatencies_src2)

    meanLatency_src1 = mean(vLatencies_src1);
    sdLatency_src1 = std(vLatencies_src1);
    meanLatency_src2 = mean(vLatencies_src2);
    sdLatency_src2 = std(vLatencies_src2);

    % mean latency from src1 is expected to be greater than from src2
    realMeanDiff = meanLatency_src1 - meanLatency_src2;

    nPermutations = 50000;  % nPermutations = 5000000 -> p = 0.890004

    mergedSamples = [vLatencies_src1 vLatencies_src2];

    permMeanDiff = [];
    
    for iPerm=1:nPermutations

        permutedMergedSamples = mergedSamples(randperm(size(mergedSamples,2)));    
        permMeanDiff(iPerm) = mean(permutedMergedSamples(1:size(vLatencies_src1,2))) ...
                              - mean(permutedMergedSamples((size(vLatencies_src1,2)+1):size(mergedSamples,2)));
    end

    % find the p-value (one-sided, src1 > src2)
    pValue = length(find(abs(permMeanDiff > realMeanDiff))) / nPermutations;

end