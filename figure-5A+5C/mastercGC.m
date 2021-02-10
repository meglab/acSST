% script cGC analysis  Filterd gc-Ac trial
time_window=[-0.100 0.150;
              0   0.250;
              0.100 0.350;
              0.200  0.450;
              0.300  0.550
              0.400  0.650];

idx=1:59;
for i=1:6
     
      %effective_connectivity1_allsources(indx,time_window,freq_res,paddingT,base,max_freq,data_string,evoked,source_set,blockwise)
      effective_connectivity1_allsources(idx,[time_window(i,1) time_window(i,2)],2,4,0,600,'10_01_task_allsource_BlockStabilityFixPca','no',14,'yes')    
     
      
end  

% permutation GC
for indxSubject=1:59
    for permIndx=1:500
          effective_connectivity1_permutationAllSources(permIndx,indxSubject,[time_window(i,1) time_window(i,2)],2,4,0,600,'10_01_task_allsource_BlockStabilityFixPca','no',14,'yes')
    end
    
end

%% it quantifies for each subject if ifg-psma link is significant (exceed bias level)

spectrlNetworkStatAllSources('result_statistic_perm_10_01_20_AllSources_FilteredTrial',8,44,1,[0.100 0.350],0,2)
strInput='result_statistic_perm_10_01_20_AllSources_FilteredTrial';
strInputGCc='result_final_10_01_task_allsource_BlockStabilityFixPca/';
% 5-23 correspond to 8-44 hz
prepareData_source_target_all('preparedDataGcNoFilter', strInput,strInputGCc,2,[5 23])

%% final stastic on ifg-psma link 
input_folder='preparedDataGcNoFilter'; %path to the data prepared in a fieldtrip structure
statistic_cGC_allSources(input_folder,strInput,2,[5 23],[8 44],'')

