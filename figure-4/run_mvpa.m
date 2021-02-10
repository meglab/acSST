
function run_mvpa()

%% SVM analysis of source data -MEG acSST 

% Main script to run svm analysis on source data
% 1)  mvpa_sourceanalysis.m performs svm analysis on source data wirh an
      % embedding (dim)
%2)   statistic_mvpa.m performs cluser-base permutation statistic of svm
      %classification against chance level(50%)
% 3)  onset_SingleSub.m single subject onset analysis
% 4)  onset_erpJacknife additional onset analysis based on a jacknife
      % approach
baseline={[-0.2   0.500]};   
name_folder={'stopVsAc_smooth10ms_pseudo8_perm100_,-0.2_0.5new11April_BroaddownembOnepassnewcode14dim' }; % broadband data
%name_folder={['stopVsAc_smooth10ms_pseudo8_perm100_,-0.2_0.5new11April_but12_32HzdownembOnepassnewcode14dim'] };  % beta filtered 


for testing=[1]
    
    name=name_folder{testing};
    base=baseline{testing};
    for sub=[1:51 53:59 62] % exclude subjects that had been excluded earlier due to outlier criteria (see methods, section participant)
        % before exclusion: n=62, after exclusion n=59
        smoothMs=12; % in sample
        response='no' ;% only left/rigth responses (type Left, Rigth)
        perm=100;
        cond_string1='2'; %stop condition
        cond_string2='3'; %ac condition
        filterBeta=0;  % 1 for filtering in beta band
        dim=14; % embedding dimension it corresponds to 3 cycle at center frequency 22
        
        
        mvpa_sourceanalysis(sub,'svm_time',1,cond_string1, cond_string2,8,1,1,name,smoothMs,perm,base,response,filterBeta,dim) % ifg 
        mvpa_sourceanalysis(sub,'svm_time',3,cond_string1, cond_string2,8,1,1,name,smoothMs,perm,base,response,filterBeta,dim) % pre_sma 
    end
    
end

% put result together and perform a cluster-based statistic

%------% all subject


test_time={[0.1 0.350]};

nn=1; tt=1;
add_title=['allSubj ','noiseNorm',' ',name_folder{nn}(37:end),' timeTest',' ',num2str(test_time{tt}(1)),'-',num2str(test_time{tt}(2)) ];
cluster_alpha=0.05;
dim=14; % embedding dimension
statistic_mvpa([1:59]',1,'svm_time','ifg',name_folder{nn},test_time{tt},cluster_alpha,10000,8,dim,add_title)
statistic_mvpa([1:59]',3,'svm_time','pre-sma',name_folder{nn},test_time{tt},cluster_alpha,10000,8,dim,add_title)

% Peak onset Analysis  
test_b={[0  0.25]}; % time window used as baseline same length as troi
time_window=[0.1 0.350];
time_windowB=test_b{tt};
freq=10;
pseudo=8;
onset_p_ifg=zeros(4,59);
onset_p_preSma=zeros(4,59);
plotting=0;
it_s=0;
dim=14;
for sub= [1:59]

       it_s=it_s+1;   
          
          ch=1;   %ifg

           [ onset_p_ifg(:,it_s)]=onset_SingleSub(sub,name_folder{tt},ch,pseudo,[],time_window,time_windowB,freq,plotting,figure(sub),dim);

           ch=3;%psma

           [onset_p_preSma(:,it_s)]=onset_SingleSub(sub,name_folder{tt},ch,pseudo,[],time_window,time_windowB,freq,plotting,figure(sub),dim);
end           
                        
for th=1:4
    exclude=[];

    ifg_values=onset_p_ifg(th,:);
    psma_values=onset_p_preSma(th,:);
    exclude=[find(isnan( ifg_values))';find(isnan( psma_values))'];
    if ~isempty(exclude)
        ifg_values(unique(exclude))=[];
        psma_values(unique(exclude))=[];



    end


    [pValue, meanLatency_src1, sdLatency_src1, meanLatency_src2, sdLatency_src2] = PermuationTest( psma_values,ifg_values);
    display([num2str(pValue), '-',num2str(meanLatency_src2),'-',num2str(meanLatency_src1),'-',num2str(length(exclude))])
    
end

% jacknife for broadband data
for th=[75]
 
    resultJack= onset_erpJacknife(name_folder{1},1,3,8,th);

end





end