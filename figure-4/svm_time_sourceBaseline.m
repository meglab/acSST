
function svm_time_sourceBaseline(out_folder,sub,ch,cond_string1,cond_string2,perm,pseudo,Bcorr,gaussSmoth,smoothMs,baseline,beta_filter,dim)


vsSub=GetSubjectList();
substring=vsSub{sub,1};
strinImp='C:\Users\edoardo\Desktop\elifeSchaum\RT_acgo_no_filter/';
%strinImp='/data/common/acSST_Exchange/VirtualChannelAllData/';
load([strinImp,vsSub{sub,1},'_',cond_string1,'_VirtChannel.mat']);

%load first condition data
if beta_filter==1
    VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
    cfg=[]
    cfg.bpfilter      ='yes';
    cfg.bpfreq        =[12 32];
    cfg.padding      = 1;
    cfg.bpfilttype    = 'but';
    cfg.bpfiltdir     =  'onepass';
    [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);
     
    
   filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
   for i=1:size(VChannelDataOut.trial,2)

        filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
   end
   dataT1=filtt(:,[ch ],:);
else
   filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
   for i=1:size(VChannelDataOut.trial,2)

        filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
   end
   dataT1=filtt(:,[ch ],:);
   
   
   
   
end
label1=ones(size(dataT1,1),1);
clear VChannelDataOut
if strcmp(cond_string1,'2')
    
    load([strinImp,vsSub{sub,1},'_','20','_VirtChannel.mat']);
        
    if beta_filter==1
        VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
         cfg=[]
         cfg.bpfilter      ='yes';
         cfg.bpfreq        =[12 32];
         cfg.padding      = 1;
         cfg.bpfilttype    = 'but';
         cfg.bpfiltdir     =  'onepass';
         [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);

               
        
        
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);
       
    else
        
        filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);
        
        
       
       
       
    end



elseif  strcmp(cond_string1,'3')
    
    load([strinImp,vsSub{sub,1},'_','30','_VirtChannel.mat']);
    
    
     if beta_filter==1
       VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
       cfg=[]
       cfg.bpfilter      ='yes';
       cfg.bpfreq        =[12 32];
       cfg.padding      = 1;
       cfg.bpfilttype    = 'but';
       cfg.bpfiltdir     =  'onepass';
       [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);
         
         
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);
       
     else
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB1=filtt(:,[ch ],:);
   
         
         
     end

    
end

clear VChannelDataOut
% load second cond

load([strinImp,vsSub{sub,1},'_',cond_string2,'_VirtChannel.mat']);

if beta_filter==1
    
     VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
     cfg=[]
     cfg.bpfilter      ='yes';
     cfg.bpfreq        =[12 32];
     cfg.padding      = 1;
     cfg.bpfilttype    = 'but';
     cfg.bpfiltdir     =  'onepass';
     [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);

    
    
   filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
   for i=1:size(VChannelDataOut.trial,2)

        filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
   end
   dataT2=filtt(:,[ch ],:);
else
    
   filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
   for i=1:size(VChannelDataOut.trial,2)

        filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
   end
   dataT2=filtt(:,[ch ],:);
   
   
   
end
label2=ones(size(dataT2,1),1)*-1;


if strcmp(cond_string2,'2')
    
    load([strinImp,vsSub{sub,1},'_','20','_VirtChannel.mat']);
    
    if beta_filter==1
        
       VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
       cfg=[]
       cfg.bpfilter      ='yes';
       cfg.bpfreq        =[12 32];
       cfg.padding      = 1;
       cfg.bpfilttype    = 'but';
       cfg.bpfiltdir     =  'onepass';
       [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);


        
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
    else
         filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
   
       
     end



elseif  strcmp(cond_string2,'3')
    
    load([strinImp,vsSub{sub,1},'_','30','_VirtChannel.mat']);
   
    if beta_filter==1
        
       VChannelDataOut= rmfield( VChannelDataOut , 'elec' );
       cfg=[]
       cfg.bpfilter      ='yes';
       cfg.bpfreq        =[12 32];
       cfg.padding      = 1;
       cfg.bpfilttype    = 'but';
       cfg.bpfiltdir     =  'onepass';
       [VChannelDataOut] = ft_preprocessing(cfg, VChannelDataOut);

        
        
       filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
       
    else
        filtt=zeros(size(VChannelDataOut.trial,2),size(VChannelDataOut.trial{1},1),size(VChannelDataOut.trial{1},2));
       for i=1:size(VChannelDataOut.trial,2)

            filtt(i,:,:)=VChannelDataOut.trial{i}(:,:);
       end
       dataB2=filtt(:,[ch ],:);
       
        
        
        
     end

    
end
time=VChannelDataOut.time{1};
clear VChannelDataOut

% baseline for zscore task = the all epoch is zscore 
%actual baseline
time_base1=nearest(time,-0.2);
time_base2=nearest(time,0.5);
timeActual=time(time_base1:time_base2);
% time_base_t1=nearest(time,baseline(1));
% time_base_t2=nearest(time,baseline(2));
% timeActual=linspace(0,baseline(2)-baseline(1),(time_base_t2-time_base_t1));
% %actual baseline
% time_base1=nearest(time,baseline(1));
% time_base2=nearest(time,baseline(2));


n_trialB1=size(dataB1,1);
nchannel=size(dataB1,2);
npointsB1=size(dataB1(:,:,time_base1:time_base2),3);


tmpdataB1=zeros(n_trialB1,nchannel,npointsB1);

for tr=1:n_trialB1
    tt=dataB1(tr,:,time_base1:time_base2);
    tmpdataB1(tr,:,:)=tt;

end

mean_base1=mean(tmpdataB1(:,:,time_base1:time_base2),3);
std_base1=std(tmpdataB1(:,:,time_base1:time_base2),[],3);



n_trialB2=size(dataB2,1);
nchannel=size(dataB2,2);
npointsB2=size(dataB2(:,:,time_base1:time_base2),3);


tmpdataB2=zeros(n_trialB2,nchannel,npointsB2);

for tr=1:n_trialB2
    tt=dataB2(tr,:,time_base1:time_base2);
    tmpdataB2(tr,:,:)=tt;

end


mean_base2=mean(tmpdataB2(:,:,time_base1:time_base2),3);
std_base2=std(tmpdataB2(:,:,time_base1:time_base2),[],3);

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


if Bcorr==1
    corr_base1=bsxfun(@rdivide,bsxfun(@minus,tmpdataT1,mean_base1),std_base1);
    

    corr_base2=bsxfun(@rdivide,bsxfun(@minus,tmpdataT2,mean_base2),std_base2);
else
    
    % zscore baseline
     corr_base1=bsxfun(@rdivide,bsxfun(@minus,tmpdataB1,mean_base1),std_base1);
     corr_base2=bsxfun(@rdivide,bsxfun(@minus,tmpdataB2,mean_base2),std_base2);

end


if gaussSmoth==1
    results_smoothed_1=zeros(size(corr_base1,1),size(corr_base1,3)-1);
    for i=1:size(corr_base1,1)

       tmp=squeeze(corr_base1(i,1,:));
       results_smoothed_1(i,:) = smooth_results_da_causal(tmp,smoothMs)';

    end

    results_smoothed_2=zeros(size(corr_base2,1),size(corr_base2,3)-1);



    for i=1:size(corr_base2,1)

       tmp=squeeze(corr_base2(i,1,:));
       results_smoothed_2(i,:) = smooth_results_da_causal(tmp,smoothMs)';

    end
  
       
    
else
    
    results_smoothed_1=corr_base1;
    results_smoothed_2=corr_base2;
    
end

cond1=[];
for i=1:size(results_smoothed_1,1)
    
    cond1.trial{i}(1,:)=results_smoothed_1(i,:)';
    cond1.time{i}=timeActual(1:size(results_smoothed_1(i,:),2));
    cond1.label{1}='Fp1';
    cond1.fsample=1200;
    cond1.trialinfo=label1;
end

cond2=[];
for i=1:size(results_smoothed_2,1)
    
    cond2.trial{i}(1,:)=results_smoothed_2(i,:)';
    cond2.time{i}=timeActual(1:size(results_smoothed_2(i,:),2));
    cond2.label{1}='Fp1';
    cond2.fsample=1200;
    cond2.trialinfo=label2;
end


%concatenate structure 
cfg=[];
ERP_data=ft_appenddata(cfg,cond1,cond2);

% 
cfg=[];
cfg.resamplefs      = 300;
ERP=ft_resampledata(cfg,ERP_data);
%  ERP=ERP_data; 


newAllTrlDataT=zeros(length(ERP.trial),1,size(ERP.trial{1}(:,:),2));
for i=1:length(ERP.trial)

    newAllTrlDataT(i,1,:)=ERP.trial{i}(:,:);
    
end
ntrial=size(newAllTrlDataT(:,1,:),1);
if dim>1

     
    iStart = dim;
    timeLength = length(newAllTrlDataT(1,1,:));


    embeddedVectors_Y = zeros(ntrial,(timeLength-dim),dim);

    for iTrial = 1:ntrial

        trial = squeeze(newAllTrlDataT(iTrial,1,:)); 

        for iTimePoint = iStart:(length(trial)-1)

            embeddedVectors_Y(iTrial,(iTimePoint-dim+1),:) = trial((iTimePoint-dim+1):iTimePoint)';

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
%             % 2. Whitening using the Epoch method
%             sigma_conditions = reshape(squeeze(labels_pseudo_train(1,:,n_pseudo:end))',1,[]);
%             sigma_ = nan(n_conditions, n_sensors, n_sensors);
%             for c = 1:n_conditions
%                 % compute sigma for each time point, then average across time
%                 tmp_ = nan(n_time, n_sensors, n_sensors);
%                 for t = 1:n_time
%                     tmp_(t, :, :) = cov1para(Xpseudo_train(sigma_conditions==c, :, t));
%                 end
%                 sigma_(c, :, :) = mean(tmp_, 1);
%             end
%             sigma = squeeze(mean(sigma_, 1));  % average across conditions
%             sigma_inv = sigma^-0.5;
%             for t = 1:n_time
%                 Xpseudo_train(:, :, t) = squeeze(Xpseudo_train(:, :, t)) * sigma_inv;
%                 Xpseudo_test(:, :, t) = squeeze(Xpseudo_test(:, :, t)) * sigma_inv;
%             end  
%             


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

result_.svm = squeeze(nanmean(result.svm, 2));
sessions.mvpa(1).permutation=squeeze(result.svm);
result = result_;

sessions.mvpa(1).resultSvm=result;
sessions.mvpa(1).time_start=-0.2;
sessions.mvpa(1).time_end=0.7;

save([out_folder,substring,'_baseline.mat'], 'sessions', '-v7.3');     

end 
        

