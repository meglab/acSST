
function spectrlNetworkStatAllSources(folder_name,freq1,freq2,correction,time_window,base,ncorrection)


addpath '/data/common/FieldtripCurrent/fieldtrip-master'
rmpath('/data/common/FieldtripCurrent/fieldtrip-master/external/signal/dpss_hack/')
ft_defaults
     
m_method='dpss';
tsmooth=5;
freq_res='2';

condstrTask=['task',num2str(freq_res),'/'];
condstrBase=['base',num2str(freq_res),'/'];
       
vsSubjectList = GetSubjectList();

% convert frequencies to index 
indx=[];
time=linspace(0,600,301);
indx(1)=nearest(time,freq1);
indx(2)=nearest(time,freq2);

nperm=1000;
fr={'beta'};
cmbS=2; % combination source target// we look only ifg-psma in both directions

for r=1
    
    fr_i=indx(r,:);
    fr='beta';                       
   
    for tt=1

         
       index_subStop=zeros(cmbS,59); % store 1 if link is singificant and 0 otherwise for each source-target pair and subject
       index_subAc=zeros(cmbS,59);   
        for sub=1:59 
            substring=vsSubjectList{sub,1};
            
            if base==1

                  load(['/data/home1/epinzuti/rresult_final_04_07_base_4sourceBlockStabilityFixPca//', m_method,'/',condstrBase,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',name_file],...
                           'grangerStopCond','grangerAcCond' );

                   name_fileTitle=['grangerCondBase', m_method];

            else
                     
                  %load original GC data
                   name_file=['connectivity_measure_',substring,'.mat'];
                   load(['/data/home1/epinzuti/result_final_10_01_task_allsource_BlockStabilityFixPca/', m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',name_file],...
                        'grangerStopCond','grangerAcCond');

                    name_fileTitle=['grangerCond', m_method];



            end

         % load permutation data
          name_file=['connectivity_measure_perm_',substring,'.mat'];
          
          if base==1
              
              load(['/data/home1/epinzuti/result_final_04_07_base_4sourceBlockStabilityFixPca/', m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',name_file],...
                 'grangerStopRandCond_perm','grangerAcRandCond_perm', 'grangerStopRand_perm','grangerAcRand_perm' );        
              
          else
              
              %loop through permutation
              grangerStopRandCond_permAll={};
              grangerAcRandCond_permAll={};
              for n=1:nperm
                  name_file=['GC_perm_',substring,'perm_n',num2str(n),'.mat'];
                  load(['/data/common/acSST_Exchange/ResultsGC_ESI/spectral_cGCA13_01_task_Allsource_FilteredAc_BlockStabilityFixPca/', m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',name_file],...
                     'grangerStopRandCond_perm','grangerAcRandCond_perm' );        

                  grangerStopRandCond_permAll{n}=grangerStopRandCond_perm{1};
                  grangerAcRandCond_permAll{n}=grangerAcRandCond_perm{1};
                 
                 
              end
          end  
                    
           % take  mean of task          

           meanBetaStopDistr=zeros(cmbS,nperm);
           meanBetaAcDistr=zeros(cmbS,nperm);
            
           meanBetaStop_task=zeros(1,cmbS);
           meanBetaAc_task=zeros(1,cmbS);
                        
        
           significanceStop=zeros(cmbS,sub);
           pvalue_allStopV=zeros(sub,cmbS);
 
           pvalue_allStop=zeros(cmbS,sub);
           significanceAc=zeros(cmbS,sub);
           pvalue_allAcV=zeros(sub,cmbS);
     
           pvalue_allAc=zeros(cmbS,sub);
            
                                   
           

            for ss=1:2     % ifg-psma link  
             % take mean over specific frequency range range   
       
               % conditional GC mean of the task 
               meanBetaStop_task(1,ss)=nanmean(grangerStopCond(ss,fr_i(1):fr_i(2)),2);
               meanBetaAc_task(1,ss)=nanmean(grangerAcCond(ss,fr_i(1):fr_i(2)),2);


                for perm=1:nperm

                     meanBetaStopDistr(ss,perm)=nanmean(grangerStopRandCond_permAll{perm}(ss,fr_i(1):fr_i(2)),2);      
                     meanBetaAcDistr(ss,perm)=nanmean(grangerAcRandCond_permAll{perm}(ss,fr_i(1):fr_i(2)),2);      

                     
                end        

               %-----------condGC  perm stat STOP
              
                % how many exceed the GC in the task
                pvalueS = sum(meanBetaStopDistr(ss,:) >= meanBetaStop_task(1,ss)) / size(meanBetaStopDistr(ss,:),2);

                if pvalueS==0

                    pvalueS=1/size(meanBetaStopDistr(ss,:),2);
                end

                
                if correction==1
                               
                      significanceStop(ss,sub)=pvalueS<(0.05/ncorrection);
                      corr='bonf_corr';
                     
                else
                    
                    
                     significanceStop(ss,sub)=pvalueS<0.05;
                      corr='no_corr';
                                        
                end
                
                if  significanceStop(ss,sub)==1
                    
                    index_subStop(ss,sub)=1;
                    
                else
                    
                    index_subStop(ss,sub)=0;
                    
                end

                pvalue_allStop(ss,1)=pvalueS;
                pvalue_allStopV(1,ss)=pvalueS;

                %-----------condGC  perm stat STOP
                pvalueA = sum(meanBetaAcDistr(ss,:) >= meanBetaAc_task(1,ss)) / size(meanBetaAcDistr(ss,:),2);

                if pvalueA==0

                    pvalueA=1/size(meanBetaAcDistr(ss,:),2);
                end

                
                if correction==1
                   significanceAc(ss,sub)=pvalueA<(0.05/ncorrection);
                   corr='bonf_corr';
                 
                else
                    
                     significanceAc(ss,sub)=pvalueA<0.05;
                     corr='no_corr';
                end
                pvalue_allAc(ss,1)=pvalueA;
                pvalue_allAcV(1,ss)=pvalueA;
                
                 if significanceAc(ss,sub)==1
                    index_subAc(ss,sub)=1;
                    
                else
                    
                    index_subAc(ss,sub)=0;
                    
                end


            end


        end  


    end 
end

% plot graph
frstr1=num2str(time(fr_i(1)));
frstr2=num2str(time(fr_i(2)));
frRange=[frstr1,'_',frstr2,'_Hz/'];

strOutput=(['/data/common/acSST_Exchange/',folder_name,'/',fr,'/' ,frRange,'/',m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',...
    corr,'/',num2str(ncorrection),'/']);
if ~exist(   strOutput)
   mkdir(   strOutput)

end


save([    strOutput,'network_','.mat'], 'meanBetaStopDistr','meanBetaAcDistr',...
'meanBetaStop_task','meanBetaAc_task','significanceStop', 'significanceAc','pvalue_allStop','pvalue_allAc',...
'index_subAc','index_subStop');



end



