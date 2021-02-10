
function svm_time_source(out_folder,sub,ch,cond_string1,cond_string2,perm,pseudo,Bcorr,gaussSmoth,smoothMs,baseline,response,filter_beta,dim)
% part of this code was taken from:
%Guggenmos, M., Sterzer, P., & Cichy, R. M. (2018). Multivari7 6 3 ate pattern analysis for MEG: A comparison of dissimilarity
%7 6 4 measures. NeuroImage, 173, 434–447

% load virtual channel time-courses and apply a svm to the raw data
%-------load data each condition Stop / ac 

vsSub=GetSubjectList();
substring=vsSub{sub,1};

strinImp='C:\Users\edoardo\Desktop\elifeSchaum\RT_acgo_no_filter/';
load([strinImp,vsSub{sub,1},'_',cond_string1,'_VirtChannel.mat']);

beta_filter=filter_beta;

if beta_filter==1
       
   % filter data in beta band    
    
    for cht=[ch]
         VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
         cfg=[];
         cfg.bpfilter      ='yes';
         cfg.bpfreq        =[12 32];
         cfg.padding      = 1;
         cfg.bpfilttype    = 'but';
         cfg.bpfiltdir     =  'onepass';
         [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);
                   
        
    end
    
end


% first condition data  %succ stop
if ch==1
   % for ifg 
   if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataT1=filtt(:,[ch ],:);
    
   else
       % no filter applied
       dataT1=VChannelDataOut.trialtmp(:,[ch ],:);
       
   end
   
else
   % for preSma
   if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataT1=filtt(:,[ch ],:);        
   else 
      dataT1=VChannelDataOut.trialtmp(:,[ch ],:);
   end
   
end

label1=ones(size(dataT1,1),1);
clear VChannelDataOut
if strcmp(cond_string1,'2')  % if succ stop we load the corresponding baseline
    
    load([strinImp,vsSub{sub,1},'_','20','_VirtChannel.mat']);
    
        
    if beta_filter==1
    
         VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
         cfg=[];
         cfg.bpfilter      ='yes'
         cfg.bpfreq        =[12 32];
         cfg.padding      = 1;
         cfg.bpfilttype    =  'but';
         cfg.bpfiltdir     =  'onepass';
         [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);
     
   end
    
if ch==1
    % for ifg
    if beta_filter==1
        filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);

    else   
       dataB1=VChannelDataOut.trialtmp(:,[ch ],:);
    end
else
   % for preSma
    if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);

    else   
       dataB1=VChannelDataOut.trialtmp(:,[ch ],:);
    end

end
    
end


clear VChannelDataOut
% load second condition

load([strinImp,vsSub{sub,1},'_',cond_string2,'_VirtChannel.mat']); % load ac condition

if beta_filter==1
     VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
     cfg=[];
     cfg.bpfilter      ='yes';
     cfg.bpfreq        =[12 32];
     cfg.padding      = 1;
     cfg.bpfilttype    = 'but';
     cfg.bpfiltdir     =  'onepass';
     [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);

end
    
if ch==1    

    if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataT2=filtt(:,[ch ],:);
           
               
     else
           dataT2=VChannelDataOut.trialtmp(:,[ch ],:);

    end
else
    if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataT2=filtt(:,[ch ],:);
              
     else
           dataT2=VChannelDataOut.trialtmp(:,[ch ],:);

    end
       
    
end


label2=ones(size(dataT2,1),1)*2;

if  strcmp(cond_string2,'3')  % if condition ac we load the corresponding baseline
    
    load([strinImp,vsSub{sub,1},'_','30','_VirtChannel.mat']);
        
    if beta_filter==1
        
         VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
         cfg=[];
         cfg.bpfilter      ='yes';
         cfg.bpfreq        =[12 32];
         cfg.padding      = 1;
         cfg.bpfilttype    ='but';
         cfg.bpfiltdir     =  'onepass';
         [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);
         
    
   
    end

            
    
if ch==1    

    if beta_filter==1
      filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
           
    else
        dataB2=VChannelDataOut.trialtmp(:,[ch ],:);

    end
else
    if beta_filter==1
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)
       
            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
   
           
    else
           dataB2=VChannelDataOut.trialtmp(:,[ch ],:);

    end
       
    
end
end

if strcmp(response,'L')
        
    Manual_indx=find(VChannelDataOut.trialInfo(:,6)==-1);
        
elseif strcmp(response,'R')  
    
    Manual_indx=find(VChannelDataOut.trialInfo(:,6)==1);
         
end

% prepare the data
time=VChannelDataOut.time{1};
clear VChannelDataOut

time_base_t1=nearest(time,baseline(1));
time_base_t2=nearest(time,baseline(2));

n_trialB1=size(dataB1,1);
nchannel=size(dataB1,2);
npointsB1=size(dataB1(:,:,time_base_t1:time_base_t2),3);


tmpdataB1=zeros(n_trialB1,nchannel,npointsB1);


for tr=1:n_trialB1
    tt=dataB1(tr,:,time_base_t1:time_base_t2);
    tmpdataB1(tr,:,:)=tt;
    
end

mean_base1=mean(tmpdataB1,3);
std_base1=std(tmpdataB1,[],3);

n_trialB2=size(dataB2,1);
nchannel=size(dataB2,2);
npointsB2=size(dataB2(:,:,time_base_t1:time_base_t2),3);


tmpdataB2=zeros(n_trialB2,nchannel,npointsB2);

for tr=1:n_trialB2
    tt=dataB2(tr,:,time_base_t1:time_base_t2);
    tmpdataB2(tr,:,:)=tt;

end


mean_base2=mean(tmpdataB2,3);
std_base2=std(tmpdataB2,[],3);


n_trialT1=size(dataT1,1);
nchannel=size(dataT1,2);
npointsT1=size(dataT1,3);


tmpdataT1=zeros(n_trialT1,nchannel,npointsT1);

for tr=1:n_trialT1
    tt=dataT1(tr,:,:);
    tmpdataT1(tr,:,:)=tt;

end


n_trialT2=size(dataT2,1);
nchannel=size(dataT2,2);
npointsT2=size(dataT2,3);


tmpdataT2=zeros(n_trialT2,nchannel,npointsT2);

for tr=1:n_trialT2
    tt=dataT2(tr,:,:);
    tmpdataT2(tr,:,:)=tt;

end



if Bcorr==1 %baseline z score
    corr_base1=bsxfun(@rdivide,bsxfun(@minus,tmpdataT1,mean_base1),std_base1);
   
    corr_base2=bsxfun(@rdivide,bsxfun(@minus,tmpdataT2,mean_base2),std_base2);
  
else
    
     corr_base1=tmpdataT1;
     corr_base2=tmpdataT2;
end


if gaussSmoth==1  % smoothing the data
    results_smoothed_1=zeros(size(corr_base1,1),size(corr_base1,2),size(corr_base1,3)-1);
    for i=1:size(corr_base1,1)
       for ll=1:size(corr_base1,2)
           tmp=squeeze(corr_base1(i,ll,:));
           results_smoothed_1(i,ll,:) = smooth_results_da_causal(tmp,smoothMs)';
       end

    end

    results_smoothed_2=zeros(size(corr_base2,1),size(corr_base2,2),size(corr_base2,3)-1);



    for i=1:size(corr_base2,1)
       for ll=1:size(corr_base1,2)
           tmp=squeeze(corr_base2(i,ll,:));
           results_smoothed_2(i,ll,:) = smooth_results_da_causal(tmp,smoothMs)';
       end
    end

    if strcmp(response,'L') | strcmp(response,'R')
        
          results_smoothed_1=results_smoothed_1( Manual_indx,:);
          label1=ones(size(results_smoothed_1,1),1)*1;
         % ac take manual response only left /rigth
          results_smoothed_2=results_smoothed_2( Manual_indx,:);
          label2=ones(size(results_smoothed_2,1),1)*2;
        
    end
    
       
    
else
    
    results_smoothed_1=corr_base1;
    results_smoothed_2=corr_base2;
    
end

cond1=[];
for i=1:size(results_smoothed_1,1)
    
    cond1.trial{i}(:,:)=squeeze(results_smoothed_1(i,:,:))';
    cond1.time{i}=linspace(-0.2,0.7,size(results_smoothed_1,3));
     
    cond1.fsample=1200;
    cond1.trialinfo=label1;
end
for ll=1:size(results_smoothed_1,2)
    
    cond1.label{ll}=num2str(ll);
end


cond2=[];
for i=1:size(results_smoothed_2,1)
    
    cond2.trial{i}(:,:)=squeeze(results_smoothed_2(i,:,:))';
    cond2.time{i}=linspace(-0.2,0.7,size(results_smoothed_1,3));
    
    cond2.fsample=1200;
    cond2.trialinfo=label2;
end
for ll=1:size(results_smoothed_2,2)
    
    cond2.label{ll}=num2str(ll);
end


cfg=[];
ERP_data=ft_appenddata(cfg,cond1,cond2);
cfg=[];
cfg.resamplefs      = 300;
ERP=ft_resampledata(cfg,ERP_data);


newAllTrlDataT=zeros(length(ERP.trial),size(ERP.trial{1}(:,:),1),size(ERP.trial{1}(:,:),2));
for i=1:length(ERP.trial)

    newAllTrlDataT(i,:,:)=ERP.trial{i}(:,:);
   
end
ntrial=size(newAllTrlDataT(:,1,:),1);
if dim>1
    % create embedding vectors
    iStart = dim;
    timeLength = length(newAllTrlDataT(1,1,:));

    embeddedVectors_Y = zeros(ntrial,(timeLength-dim),dim);

    for iTrial = 1:ntrial

        trial = squeeze(newAllTrlDataT(iTrial,1,:)); 

        for iTimePoint = iStart:(length(trial)-1)

            embeddedVectors_Y(iTrial,(iTimePoint-dim+1),:) = trial((iTimePoint-dim+1):iTimePoint,1)';

        end

    end


  newAllTrlDataT=permute( embeddedVectors_Y,[1 3 2]);
    

end

% create structure for MVPA
sessions.mvpa(1).data.powspctrm=newAllTrlDataT;
sessions.mvpa(1).labels=[label1;label2];

n_perm = perm;  % number of permutations
n_pseudo =pseudo;  % number of pseudo-trials
n_conditions = length(unique(sessions.mvpa(1).labels));
n_sensors = size(sessions.mvpa(1).data.powspctrm,2);
display(num2str(n_sensors))
n_time = size(sessions.mvpa(1).data.powspctrm,3);

n_sessions =1;

%--- define  classifier: Support Vector Machine---------
clfs = {'svm'};
for c = 1:length(clfs)
    result.(clfs{c}) = nan(n_sessions, n_perm, n_conditions, n_conditions, n_time);
end
for s = 1

    fprintf('Session %g / %g\n', s, n_sessions)
     
     X = sessions.mvpa(1).data.powspctrm;
     y = sessions.mvpa(1).labels;

     conditions = unique(y);
     n_trials = histc(y, conditions);

     for f = 1:n_perm
            fprintf('\tPermutation %g / %g\n', f, n_perm)
            
            % precompute permutations
            ind_pseudo_train = nan(n_conditions, n_conditions, 2*(n_pseudo-1));
            ind_pseudo_test = nan(n_conditions, n_conditions, 2);
            labels_pseudo_train = nan(n_conditions, n_conditions, 2*(n_pseudo-1));
            labels_pseudo_test = nan(n_conditions, n_conditions, 2);
            for c1 = 1:n_conditions
                range_c1 = (c1-1)*(n_pseudo-1)+1:c1*(n_pseudo-1);
                for c2 = 1:n_conditions
                    range_c2 = (c2-1)*(n_pseudo-1)+1:c2*(n_pseudo-1);
                    ind_pseudo_train(c1, c2, 1:2*(n_pseudo - 1)) = [range_c1 range_c2];
                    ind_pseudo_test(c1, c2, :) = [c1 c2];
                    labels_pseudo_train(c1, c2, 1:2*(n_pseudo - 1)) = ...
                        [conditions(c1)*ones(1,n_pseudo-1) conditions(c2)*ones(1,n_pseudo-1)];
                    labels_pseudo_test(c1, c2, :) = conditions([c1 c2]);
                end
            end              
            train_indices = cell(1, n_conditions*(n_pseudo-1));
            test_indices = cell(1, n_conditions);
            for c1 = 1:n_conditions  % separate permutation for each condition
                prm_ = randperm(n_trials(c1));                
                prm = cell(1, n_pseudo);
                splitsize = n_trials(c1) / n_pseudo;
                for i = 1:n_pseudo
                    idxs = floor(round((i-1)*splitsize)):floor(round((i)*splitsize))-1;
                    prm{i} = prm_(idxs + 1);
                end                                
                ind = cellfun(@(x)x+sum(n_trials(1:c1-1)), prm, 'UniformOutput', 0);
                xrange = (c1-1)*(n_pseudo-1)+1:c1*(n_pseudo-1);
                for i = 1:length(xrange)
                    train_indices{xrange(i)} = ind{i};
                end
                test_indices{c1} = ind{end};
            end                                

            % 1. Compute pseudo-trials for training and test
            Xpseudo_train = nan(length(train_indices), n_sensors, n_time);
            Xpseudo_test = nan(length(test_indices), n_sensors, n_time);
            for i = 1:length(train_indices)
                Xpseudo_train(i, :, :) = mean(X(train_indices{i}, :, :), 1);
            end
            for i = 1:length(test_indices)
                Xpseudo_test(i, :, :) = mean(X(test_indices{i}, :, :), 1);
            end

            
            
            for t = 1:n_time
                for c1 = 1:n_conditions-1
                    for c2 = c1+1:n_conditions
                        % 3. Fit the classifier using training data
                        data_train = Xpseudo_train(ind_pseudo_train(c1, c2, :), :, t);
                        y_train = squeeze(labels_pseudo_train(c1, c2, :));
                       
                        model_svm = svmtrain(y_train, data_train, '-c 1 -q 0 -t 0');
                        % 4. Compute and store classification accuracies
                        data_test = Xpseudo_test(ind_pseudo_test(c1, c2, :), :, t);
                        y_train = squeeze(labels_pseudo_test(c1, c2, :));
                        result.svm(s, f, c1, c2, t) = ...
                            mean(svmpredict( y_train ,data_test,model_svm,'-q 0 -t 0')==y_train )-0.5;
                       
                    end
                end
                             
                
            end
      end
 end
% average across permutations
for c = 1:length(clfs)
    result_.(clfs{c}) = nan(n_sessions, n_perm, n_conditions, n_conditions, n_time);
end 
sessions.mvpa(1).permutation=squeeze(result.svm); 
result_.svm = squeeze(nanmean(result.svm, 2));
result = result_; 

sessions.mvpa(1).resultSvm=result;
sessions.mvpa(1).time_start=-0.2;
sessions.mvpa(1).time_end=0.7;

save([out_folder,substring,'.mat'], 'sessions','train_indices','test_indices', '-v7.3');     


end