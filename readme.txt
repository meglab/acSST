FIGURE 1 (C)

Behavioral data was extracted from raw data using MATLAB and analyzed using JASP.

Bayesian statistics that analyzed the prediction of SSRT, was run in a jupyter notebook: bayesianStatistics/MultiRegressionSSRT.ipynb



FIGURE 2

(A) Group statistics on MEG data over individual source reconstructions are divided into two scripts:

– Statistics_Step1_Analytic_BC.m (uses SingleSubjects_DICS/[subjectID]_Sources_[conditionNum].mat)	
– Statistics_Step2_DepSamplesT_BC.m

  Ouput: SourceStat-2-BC-vs-3-BC-a-0.050-clusta-0.05000-tail-0.mat

Both have been applied to beta-band (iFreq=2) and gamma-band (iFreq=3) source reconstructions.
Helper functions are located in the corresponding folder, MNI template comes with FieldTrip.

Figure supplement S1 (sensor statistics)

– FFTAnalysis.m was performed for every subject.
- FFTStatsTaskvsBaselinePooled.m was used for group statistics and plotting.

(B) fMRI data analysis

Run ttest_stopVSac_SPM_job.m. Individual contrasts are uploaded on Dryad Digital repository (VP[subjectIndexNum]_con_0006.nii)

(C) Overlap plot

Run PlotMEGfMRIOverlap.m.



FIGURE 3

Broad-band virtual channel data (time courses) for the seven sources identified in the beta band (Figure 2) are uploaded on Dryad Digital repository. Note that they contain the first and second principal component for each source identified by an PCA. Only the first component is used. Based on these data, TFR analysis was performed and data were z-transformed. Related script: TFRAnalysis.m called with iFreq=1 (for broad band) and GetZValues.m.

(A), (B) Run TFRStatsTaskvsBaseline.m for statistical contrast task vs. baseline for each condition separately, sSTOP (iCond = 1 as argument) and cAC (iCond = 3 as argument).

(C) Run TFRStatsConditionContrast.m for statistical contrast
	Output: FreqStats_sSTOP_vs_cAC_[SourceName]_2-44Hz_0.00_0.50s.mat

Onset latency test between rIFG and preSMA is run by TestOnsetLatencies.m (not shown in the figure, but stated in the text). Loads LatencyAndBetaPowerValues_sSTOP.mat.



FIGURE 4

run_mvpa.m contains the main function to perform SVM analysis on source data.
SSRT.mat is required.

- mvpa_sourceanalysis.m performs svm analysis on source data with time embedding (dim)
- statistic_mvpa.m performs cluster-based permutation statistics of SVM classification against chance level (50%)
- onset_SingleSub.m single subject onset analysis
- onset_erpJacknife additional onset analysis based on a jacknife approach

Statistics result files:

(A) 
	rIFG:   /Broadband/1/8/statistic_mvpaifgBroad.mat
	preSMA: /Broadband/3/8/statistic_mvpapsmaBroad.mat
(B)
	rIFG:   /BetabandFiltered/1/8/statistic_mvpaifgBetaFilter.mat
	preSMA: /BetabandFiltered/3/8/statistic_mvpapsmaBetaFilter.mat



FIGURE 5

(A) and (C) masterGC.m contains all the functions to run the non parametric Granger analysis.
Use PlotSpectraSlidingWindows.m for plotting.

	Output: SlidingWDataGC_2SurrogateLinksFullyConditioned.mat


(B) Run CorrelationDAI_SSRT.m, loads DAI.mat and SSRT.mat



TABLE 1

To identify local maxima (peaks) within the source group statistics, run SourceLocalization.m with iFreq=2 (beta-band sources). This function is part of a script that automatically generates source reconstruction reports (based on group statistics, peaks are identified using this script, and labelling of the peak voxels is done by an FSL atlas query; see Report-SourceStat-2-BC-vs-3-BC-tail-0.pdf).


