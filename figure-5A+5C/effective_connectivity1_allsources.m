
function effective_connectivity1_allsources(indx,time_window,freq_res,paddingT,base,max_freq,data_string,evoked,source_set,blockwise)

%% compute different granger causality
% time_window=[0.1 0.350];
% freq_res=2;
% paddingT=4;
% base=0;
% max_freq=600;
% data_string='30_06_task_4sourceBlock';
% evoked='no';
% source_set=8;
% blockwise='yes';

zSc='no'

vsSubjectList = GetSubjectList();

padding='yes';
plotting='no';

if source_set==14
    nsources=7;
    comb_s=7*(7-1);
    
else
    nsources=source_set;
    comb_s=source_set*(source_set-1);
end
method={'dpss'};%


for tt=1:size(time_window,1)
    foilim=[0 max_freq];
    if strcmp(padding,'yes') 
        pad=paddingT;%time_window(tt,2)-time_window(tt,1);    
    
    else
         pad=paddingT;            
    end
    
    
    foi = 0:freq_res:max_freq;
    
    nsub=1;
        
    % conditional granger
    grangerStopCond=zeros(comb_s,length(foi),nsub);
    grangerAcCond=zeros(comb_s,length(foi),nsub);
    
      
         
    for mm=1
        
        m_method=method{mm};
      
        tf1=nearest(foi,2);
        tf2=nearest(foi,8);


        if strcmp(m_method,'dpss')


            taper=[5 ];


        else
            taper=[1];

        end


        for tsmooth= taper
            for sub=indx

                %out_folder=['/data/common/ProjectExchange/acSST_Exchange/'];
                out_folder=['/data/common/ProjectExchange/acSST_Exchange/RT_acgo_filtered/'];
             
                substring=vsSubjectList{sub,1};
                if base==1
                
                      stop=load([out_folder,substring,'_20_VirtChannel.mat']);  
                      ac=load([out_folder,substring,'_30_VirtChannel.mat']);   
                      base_str='base';
                
                else
                               

                     stop=load([out_folder,substring,'_2_VirtChannel.mat']);  
                     ac=load([out_folder,substring,'_3_VirtChannel.mat']);   
                     base_str='task';
                    
                end     


                 AllTrlData_succ = stop.VChannelDataOut;
                 AllTrlData_succ.elec.pnt = [];
                 iNumVirtualChannels = size(stop.VChannelDataOut.label,2)/2; % devide by 2 because we get 2 principial components for each channel
                 for iElec = 1:iNumVirtualChannels
                    AllTrlData_succ.elec.pnt = [AllTrlData_succ.elec.pnt; iElec, 1, 1];
                    AllTrlData_succ.elec.pnt = [AllTrlData_succ.elec.pnt; iElec, 2, 2];
                 end

                 field = 'trialtmp';
                 AllTrlData_succ = rmfield(AllTrlData_succ,field);
                 cfg=[];
                             
                                        
                         
                 if source_set==14       
                      
                                                  
                        listIndxS=[1 2; 
                                   3 4;
                                   5 6 ;
                                   7 8;
                                   9 10;
                                   11 12;
                                   13 14]; 
                         cfg.channel={ AllTrlData_succ.label{listIndxS(1,1)},  AllTrlData_succ.label{listIndxS(1,2)}, AllTrlData_succ.label{listIndxS(2,1)},...
                         AllTrlData_succ.label{listIndxS(2,2)},  AllTrlData_succ.label{listIndxS(3,1)},  AllTrlData_succ.label{listIndxS(3,2)},  AllTrlData_succ.label{listIndxS(4,1)}, ...
                         AllTrlData_succ.label{listIndxS(4,2)}, AllTrlData_succ.label{listIndxS(5,1)}, AllTrlData_succ.label{listIndxS(5,2)} , AllTrlData_succ.label{listIndxS(6,1)}, AllTrlData_succ.label{listIndxS(6,2)},...
                          AllTrlData_succ.label{listIndxS(7,1)}, AllTrlData_succ.label{listIndxS(7,2)}}     ; 
                                    
                                
                 end
                    
                    
                    
                 cfg.latency     =[ time_window(tt,1)  time_window(tt,2)];
             
                 aa=ft_selectdata(cfg, AllTrlData_succ);
                 
                 
%                  % subtract evoked response

                 if strcmp(evoked,'yes')
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end


                    evokAvg=mean(evok_data,3);



                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=bsxfun(@minus,squeeze(evok_data(:,:,tr)),evokAvg);
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=correctedS(:,:,tr);


                    end
                    
                    
                 elseif strcmp(zSc,'yes')    
                    
                    
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end

                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=zscore(evok_data(:,:,tr));
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=correctedS(:,:,tr);


                    end
                    
                    
                 elseif strcmp(evoked,'yes')==1 &&     strcmp(zSc,'yes') 
                    
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end


                     evokAvg=mean(evok_data,3);



                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=bsxfun(@minus,squeeze(evok_data(:,:,tr)),evokAvg);
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=zscore(correctedS(:,:,tr));


                    end
                    
                    
                    
                
                 end
                
            
                cfg = [];
                cfg.method    = 'mtmfft';
                cfg.output='fourier';
                cfg.taper= m_method;
                cfg.padtype = 'zero';
                cfg.foi=[0:freq_res:600];
                if strcmp(m_method,'dpss')
                    
                   
                    
                    cfg.tapsmofrq = tsmooth ;
                    
                end
%               
                if strcmp(padding,'yes') 
                    cfg.pad=pad;
               
                    
                end
               
                cfg.keeptrials = 'yes';
                freq          = ft_freqanalysis(cfg,   aa );
                            
                cfg = [];
              
                if strcmp(blockwise,'yes')
             
                    granger.block = struct('name','','label',{});
                    countB=0;
                    for i=1:nsources
                        countB=countB+1;
                        granger.block(i).label(1,1)  ={ freq.label{countB}};%{'s1a'}; %freq.label(1);
                        granger.block(i).name(1,1)  = { freq.label{countB}}; %freq.label(1);
                        
                        countB=countB+1;
                        granger.block(i).label(2,1) = { freq.label{countB}}; %freq.label(2);
                    
                        granger.block(i).name(2,1) = { freq.label{countB}}; %freq.label(2);
                 
                    end
                    cfg.granger.block=granger.block;

                end
                
                 
                
                cfg.method = 'granger';
                cfg.granger.sfmethod='multivariate';
                   
                cfg.granger.conditional='yes';
                 
                g_stopCond = ft_connectivityanalysis(cfg, freq);
                        
                grangerStopCond(:,:,nsub)= g_stopCond.grangerspctrm;
                
             
                end
                           
               % Ac condition               
                                 

                 AllTrlData_ac = ac.VChannelDataOut;
                 AllTrlData_ac.elec.pnt = [];
                 iNumVirtualChannels = size(ac.VChannelDataOut.label,2)/2; % devide by 2 because we get 2 principial components for each channel
                 for iElec = 1:iNumVirtualChannels
                    AllTrlData_ac.elec.pnt = [AllTrlData_ac.elec.pnt; iElec, 1, 1];
                    AllTrlData_ac.elec.pnt = [AllTrlData_ac.elec.pnt; iElec, 2, 2];
                 end

                 field = 'trialtmp';
                 AllTrlData_ac = rmfield(AllTrlData_ac,field);
                 cfg=[];
                 
               
                if source_set==14
                         
                                
                        listIndxS=[1 2; 
                                   3 4;
                                   5 6 ;
                                   7 8;
                                   9 10;
                                   11 12;
                                   13 14];
                         cfg.channel={ AllTrlData_succ.label{listIndxS(1,1)},  AllTrlData_succ.label{listIndxS(1,2)}, AllTrlData_succ.label{listIndxS(2,1)},...
                         AllTrlData_succ.label{listIndxS(2,2)},  AllTrlData_succ.label{listIndxS(3,1)},  AllTrlData_succ.label{listIndxS(3,2)},  AllTrlData_succ.label{listIndxS(4,1)}, ...
                         AllTrlData_succ.label{listIndxS(4,2)}, AllTrlData_succ.label{listIndxS(5,1)}, AllTrlData_succ.label{listIndxS(5,2)} , AllTrlData_succ.label{listIndxS(6,1)}, AllTrlData_succ.label{listIndxS(6,2)},...
                          AllTrlData_succ.label{listIndxS(7,1)}, AllTrlData_succ.label{listIndxS(7,2)}}     ; 
                                   
                                
                 end
               
                
                 cfg.latency     =[ time_window(tt,1)  time_window(tt,2)];
                 aa=ft_selectdata(cfg, AllTrlData_ac);
                 
       
                                
                if strcmp(evoked,'yes')
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end


                     evokAvg=mean(evok_data,3);



                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=bsxfun(@minus,squeeze(evok_data(:,:,tr)),evokAvg);
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=correctedS(:,:,tr);


                    end
                    
                    
                  elseif strcmp(zSc,'yes')    
                    
                    
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end


                 


                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=zscore(evok_data(:,:,tr));
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=correctedS(:,:,tr);


                    end
                    
                    
                 elseif strcmp(evoked,'yes')==1 &&     strcmp(zSc,'yes') 
                    
                     trials=length(aa.trial);
                     nchannel=size(aa.trial{1},1);
                     npoints=size(aa.trial{1},2);
                     evok_data=zeros(nchannel,npoints,trials);
                     for tr=1:length(aa.trial)

                         evok_data(:,:,tr)=aa.trial{tr}(:,:);

                     end


                     evokAvg=mean(evok_data,3);



                    correctedS=zeros(nchannel,npoints,trials);
                    for tr=1:length(aa.trial)

                        correctedS(:,:,tr)=bsxfun(@minus,squeeze(evok_data(:,:,tr)),evokAvg);
                    end

                    for tr=1:length(aa.trial)

                         aa.trial{tr}(:,:)=zscore(correctedS(:,:,tr));


                    end
                                    
                
                 end
               
                cfg = [];
                cfg.method    = 'mtmfft';
                cfg.output='fourier';
                cfg.taper= m_method;
                cfg.padtype = 'zero';
                cfg.foi=[0 :freq_res:max_freq];
               if strcmp(m_method,'dpss')
                    
                    
                    
                    cfg.tapsmofrq = tsmooth ;
                    
                end
                
                if strcmp(padding,'yes') 
                    cfg.pad=pad;
                    
                end
           
                cfg.keeptrials = 'yes';
                freq          = ft_freqanalysis(cfg,   aa );
         
                
                cfg = [];
                cfg.method = 'granger';
                cfg.granger.sfmethod='multivariate';
                if strcmp(blockwise,'yes')
             
                     cfg.granger.block=granger.block;

                 end
             
                cfg.granger.conditional='yes';
                g_acCond = ft_connectivityanalysis(cfg, freq); 
                grangerAcCond(:,:,nsub)= g_acCond.grangerspctrm;
                

            end

                
            
            folder_output=['/data/home1/epinzuti/result_final_',data_string,'/', m_method,'/',base_str,num2str(freq_res),'/',num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/'];
            if ~exist(folder_output)    
                
                mkdir(folder_output)
                
            else
                
            end

           
          nameFile='connectivity_measure';

          save([folder_output,nameFile, '_',substring,'.mat'],'grangerStopCond','grangerAcCond');
           

        end

    end
end







