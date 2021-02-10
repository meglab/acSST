
function prepareData_source_target_all(nameFolder, strInput,strInputGCc,ncorr,fidx)

% prepare data of nonparamteric granger for statistic


date=nameFolder;
nNyquist=1;     
m_method='dpss';
tsmooth=5;
freq_res='2';

condstrTask=['task',num2str(freq_res),'/'];
condstrBase=['base',num2str(freq_res),'/'];
       
vsSubjectList = GetSubjectList();

time_window=[-0.100 0.150;
             0 0.250;
             0.100 0.350;
             0.200 0.450;
             0.300 0.550;
             0.400 0.650 ;
            ];

         
mainTitle={'Conditional Granger Causality'};

plotting='CondGC';

if strcmp(plotting,'CondGC')
    
    subject=1:59;
    plt=1;
end   
    
 
data_statStop={};
data_statAc={};

data_statStopDai={};

for tt=1:6
   
   for ss=1:2
       
       
     % 5-23 correspond to 8-44 hz
     indx_sub=get_union_networkAllsources(strInput,ss,fidx,1,ncorr,0);
     data=[];
     dataB=[];
     dataDStop=[];
     count_sub=0;
     subject= indx_sub;
     
     for sub=[indx_sub];

           substring=vsSubjectList{sub,1};
         % load task and index sub 
        if tt<=7
            name_file=['connectivity_measure_',substring,'.mat'];
%            
           load(['/data/home1/epinzuti/',strInputGCc, m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',name_file],...
               'grangerStopCond','grangerAcCond');

            name_fileTitle=['grangerCond', m_method];


        end

        if nNyquist==1

            time=linspace(0,600,301);


        else

             time=linspace(0,120,size(data.avg,3));


        end
   
         % prepare data 
         count_sub=count_sub+1;
         data.dimord='subj_chan_time';
         data.time=time;
             
         data.avg(count_sub,1,:)=squeeze(grangerStopCond(ss,:))';
         data.label{1}='Fp1';
         dataB.dimord='subj_chan_time';
         dataB.time=time;
                                         
         dataB.avg(count_sub,1,:)=squeeze(grangerAcCond(ss,:))';
         dataB.label{1}='Fp1';
     
              
              
     end 
    
     data_statStop{ss}=data;
     data_statAc{ss}=dataB;
   end 
   if tt<7
      strOutput=(['/data/common/acSST_Exchange/',date,'/', m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',plotting,'/',...
          num2str(ncorr),'/']);
        
   else
       
      strOutput=(['/data/common/acSST_Exchange/',date,'/', m_method,'/',condstrBase,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',plotting,'/'...
          num2str(ncorr),'/']);
       
   end
      
   if ~exist(strOutput)
       
       mkdir(strOutput)
       
   end
   
  
   save([strOutput,'_data4StatSliding','.mat'],'data_statStop','data_statAc')
  
   
   
   
end

% data DAI
its=0;
for subb=1:59
    its=its+1;
    substring=vsSubjectList{subb,1};
    % load task and index sub 
   
    name_file=['connectivity_measure_',substring,'.mat'];
   

    load(['/data/home1/epinzuti/',strInputGCc, m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(3,1)),'_',num2str(time_window(3,2))],'/',name_file],...
       'grangerStopCond','grangerAcCond');

    name_fileTitle=['grangerCond', m_method];

    dai_stopN= squeeze(grangerStopCond(2,:))- squeeze(grangerStopCond(1,:));
    dai_stopd= squeeze(grangerStopCond(2,:)) + squeeze(grangerStopCond(1,:));

    stopDAI=bsxfun(@rdivide,dai_stopN,dai_stopd);

    dataDStop.dimord='subj_chan_time';
    dataDStop.avg(its,1,:)=stopDAI(1:end)';
    dataDStop.label{1}='Fp1';                      
    dataDStop.time=time;



end

daiStop=squeeze(dataDStop.avg(:,1,:)); % data for correlation
strOutput='/data/common/acSST_Exchange/data_preparedFiltered/';
save([strOutput,'_DAI_data_',num2str(ncorr),'correction.mat'],'dataDStop','daiStop')
 
 
end

 
 
 

 



