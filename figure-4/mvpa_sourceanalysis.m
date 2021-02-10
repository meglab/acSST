function mvpa_sourceanalysis(sub,analysis,channel, cond_string1, cond_string2,pseudo,Bcorr,gaussSmooth,name,smoothMs,perm,baseline,response,filterBeta,dim)

%addpath('/data/projects/SFB-Resilience/')

ch=[channel];

   switch analysis 
        case 'svm_time'
          
             out_folder_svmTime=['C:\Users\edoardo\Desktop\elifeSchaum\svm_time_source_EpochTestNoFilter/',name,'/',num2str(ch),'/',num2str(pseudo),'/'];

             if ~exist(out_folder_svmTime)
                  mkdir(out_folder_svmTime)

             end
            
             svm_time_source(out_folder_svmTime,sub,ch,cond_string1,cond_string2,perm,pseudo,Bcorr,gaussSmooth,smoothMs,baseline,response,filterBeta,dim)
             svm_time_sourceBaseline(out_folder_svmTime,sub,ch,cond_string1,cond_string2,perm,pseudo,0,gaussSmooth,smoothMs,baseline,filterBeta,dim)

            
   end


end