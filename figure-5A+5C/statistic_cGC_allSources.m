function statistic_cGC_allSources(input_folder,strInputUnion,nncorr,fidx,fRange,fq_string)

% statistic source-target link

% input_folder=where data are stored (data need to be in fieldtrip structure)
% strInputUnion=  path to data for the get_unionNetwork function (result of
% the permutation analyis)
% nncorr= number of Bonf correction applied durring the permutation test
% (if applied) 
% fidx= indices of the frequencies (used in the get_unionNetwork)
% ftRange= range of frequency where apply statistic
% fq_string=string



date=input_folder;

m_method='dpss';
tsmooth=5;
freq_res='2';
nsource=7;
condstrTask=['task',num2str(freq_res),'/'];
condstrBase=['base',num2str(freq_res),'/'];

correction=1; % apply Boferroni correction
matrixvalue=[]; % store pvalue for latex document
base=0; % plotting baseline
slidingWindow=1;

vsSubjectList = GetSubjectList();

time=0:2:600; % frequency
statWindow={};
time_window=[-0.100 0.150;
    0 0.250;
    0.100 0.350;
    0.200 0.450;
    0.300 0.550
    0.400 0.650];


mainTitle={  'Conditional_Granger_Causality_'};
plotting= 'CondGC';

cond='CondGCMain';

if strcmp(cond,'CondGCMain')
    
    subject=1:59;
    plt=1;
   
end


if slidingWindow==0 && nsource==7

    sources=[1: 2];
    indPlot=[];
    timeW=[3];
    ncorr=1;%number of correction to apply  
    
elseif slidingWindow==1 && nsource==7

    sources=[1: 2];
    indPlot=[];
    timeW=[1:6];
    ncorr=1;%number of correction to apply  
         
    
end


data4plot={};
data4plotSliding={};
statistic={};
c_plot=0;
for tt=timeW
      
    
    
    if base==0
        strOutput=(['/data/common/acSST_Exchange/',date,'/', m_method,'/',condstrTask,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',plotting,'/',...
            num2str(nncorr),'/']);
    else
        strOutput=(['/data/common/acSST_Exchange/',date,'/', m_method,'/',condstrBase,num2str(tsmooth),'/',[num2str( time_window(tt,1)),'_',num2str(time_window(tt,2))],'/',plotting,'/',...
            num2str(nncorr),'/']);
               
        
    end
    load([strOutput,'_data4StatSliding','.mat'])
    
   
    statisticRand={};
    
    for ss=[1:2]
        c_plot=c_plot+1;
        pos_cluster_pvals=[];
        stat1=[];
        clust=[];
%         [i,j, name]= index_source_pairs(ss);
        load('/data/common/acSST_Exchange/list_sourceTargetpair.mat')
        name=[list_sourceTarget{ss,1},'-',list_sourceTarget{ss,2}];
        rowLabel{1,ss} = name;
        
        if slidingWindow==1
            
            columnLabels = {'-100-150ms','0-250ms','100-350ms','200-450ms','300-550ms','400-650ms'};
            
        else
            
            columnLabels = {'100-350ms'};
            
        end
        
        % i,j =indeces sources
        %5-23 =indeces frequencies
        %1 applied Bonferroni correction

        indx_sub=get_union_networkAllsources(strInputUnion,ss,fidx,1,nncorr,0)';
        
        cfg=[];
        n_subject=length(indx_sub);
        cfg.neighbours    = [];
        
        cfg.latency          = fRange;
        cfg.tail             = 0;
        cfg.clustertail      = 0;
        cfg.channel          = {'Fp1'};
        cfg.avgovertime= 'no';
        cfg.method           = 'montecarlo';
        cfg.statistic        = 'ft_statfun_depsamplesT';
        cfg.correctm         = 'cluster';
        cfg.clusteralpha     = 0.05;
        cfg.clusterstatistic = 'maxsum';
        cfg.minnbchan        = 0;
        
        cfg.alpha            = 0.025;
        cfg.numrandomization = 50000;
        subj =length(indx_sub);
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
        data1=data_statStop{ss};
        data2=data_statAc{ss};
        
        data1.avg=data1.avg(:,:,:); % get data only significant subjects
        data2.avg=data2.avg(:,:,:);
        
        statistic{ss,tt}= ft_timelockstatistics(cfg, data1, data2);
              
      
        
    end
    
    
end

strOutput='/data/common/acSST_Exchange/data_plottingSliding/';
if ~exist(   strOutput)
   mkdir(   strOutput)

end

 save([strOutput,'DataGC_',fq_string,'.mat'],'data4plotSliding','statistic')
end

