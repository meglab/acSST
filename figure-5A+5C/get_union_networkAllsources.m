function indx_sub=get_union_networkAllsources(strInput,source_target,indx,correctionI,ncorrection,stop)

    m_method='dpss';
    tsmooth=5;
    freq_res='2';

    condstrTask=['task',num2str(freq_res),'/'];
    condstrBase=['base',num2str(freq_res),'/'];

    indxU=zeros(2,59);

    count_plot=0;

    if correctionI==1                
       corr='bonf_corr';
    else
         corr='no_corr';
    end

    fr_i=indx;
    fr='beta';

    time=linspace(0,600,301);
    frstr1=num2str(time(fr_i(1)));
    frstr2=num2str(time(fr_i(2)));
    frRange=[frstr1,'_',frstr2,'_Hz/'];   
    tt=1;
    time_window=[0.100 0.350];

    strOutput=([strInput,'/',fr,'/',frRange, m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',...
         corr,'/',num2str(ncorrection),'/']);
    load([strOutput,'network_','.mat']);
    for sub=1:59

          % load all subject 
           if stop==0 

                for j=1:2
                    if index_subAc(j,sub)==1 || index_subStop(j,sub)==1

                          signS=squeeze(index_subStop(j,sub));
                          signAc=squeeze(index_subAc(j,sub));

                          if signS==1 || signAc==1                          
                              indxU(j,sub)=1;                          
                          else
                              indxU(j,sub)=0;                          
                          end
                    else                    
                         indxU(j,sub)=0;
                    end
                end
           else  % if only stop condition needed to be loaded
                for j=1:2
                    if  index_subStop(j,sub)==1
                          signS=squeeze(index_subStop(j,sub));

                          if signS==1                           
                              indxU(j,sub)=1;                          
                          else
                              indxU(j,sub)=0;                          
                          end
                    else                    
                         indxU(j,sub)=0;
                    end
                end
           end   
    end

    indx_sub=find(indxU(source_target,:)==1);

end