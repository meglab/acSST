
function statistic_mvpa(indexS,ch,mvpAnalysis,titleS,name,time_test,cluster_alpha,perm,pseudo,dim,add_title)


cfg = [];
count_sub=0;
mvpa=1;
data=[];
dataB=[];
n_subject=length(indexS);%
load('C:\Users\edoardo\Desktop\elifeSchaum\SSRT.mat')
for sub=[indexS' ]%

 switch mvpAnalysis

    case 'svm_time'
   
        out_folder=['C:\Users\edoardo\Desktop\elifeSchaum\',name,'/',num2str(ch),'/',num2str(pseudo),'/'];
       
        substring=vsStats{sub,1};
        load([out_folder,substring,'.mat'], 'sessions');   

        dataSvm=sessions.mvpa.resultSvm.svm;

        % all task comparison
        classifAccuracyTask=100*squeeze(dataSvm(1,2,:))+50;
       
        count_sub=  count_sub+1;

        %Task all
        data(mvpa).dimord='subj_chan_time';
        data(mvpa).avg(count_sub,1,:)=classifAccuracyTask;
        data(mvpa).avg(count_sub,2,:)=classifAccuracyTask;
        data(mvpa).label{1}='Fp1'; % it is used only for running fieldtrip statistic
        data(mvpa).label{2}='Fp2';
       
      
        % correct time for embedding
        timeO=linspace(-0.2,sessions.mvpa.time_end,270);
        time=linspace(-0.2,sessions.mvpa.time_end,size(classifAccuracyTask,1));
        if dim>1
          time=linspace(timeO(dim),sessions.mvpa.time_end,size(classifAccuracyTask,1));
        end
                 
        
        data(mvpa).time=time;

        % test gainst baseline

        classifAccuracyTaskBase=ones(size(classifAccuracyTask,1),size(classifAccuracyTask,2))*50;

        dataB(mvpa).dimord='subj_chan_time';
        dataB(mvpa).avg(count_sub,1,:)=classifAccuracyTaskBase;
        dataB(mvpa).avg(count_sub,2,:)=classifAccuracyTaskBase;
        dataB(mvpa).label{1}='Fp1';
        dataB(mvpa).label{2}='Fp2';
        dataB(mvpa).time=time;
        
        cfg.latency          = [time_test(1) time_test(2)];
        cfg.tail             = 1;
        cfg.clustertail      = 1;


end
end
            
    cfg.neighbours    = []; 
    cfg.channel          = {'Fp1'};
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'ft_statfun_depsamplesT';
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = cluster_alpha;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan        = 0;
    
    cfg.alpha            = 0.025;
    cfg.numrandomization = perm;
    subj =n_subject;
    design = zeros(2,2*subj);
    for i = 1:subj
      design(1,i) = i;
    end
    for i = 1:subj
      design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;

    cfg.design   = design;
    cfg.uvar     = 1;
    cfg.ivar     = 2;
    % stat Task
    if strcmp(mvpAnalysis,'svm_time')
         [stat] = ft_timelockstatistics(cfg, data(mvpa), dataB(mvpa));
   
    end
           
save([out_folder,'statistic_mvpa','.mat'],'stat','data','-v7.3');


end