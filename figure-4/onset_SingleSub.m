function [onset_p]=onset_SingleSub(sub,name,ch,pseudo,time,time_window,time_windowB,freq,plotFig,figure,dim)


out_folder=['C:\Users\edoardo\Desktop\elifeSchaum\',name,'/',num2str(ch),'/',num2str(pseudo),'/'];
vsSub=GetSubjectList();
load('C:\Users\edoardo\Desktop\elifeSchaum\SSRT.mat')
substring=vsStats{sub,1};

load([out_folder,substring,'.mat'], 'sessions');   

dataSvm=sessions.mvpa.resultSvm.svm;
classifAccuracyTask=100*squeeze(dataSvm(1,2,:))+50;
out_folder=['C:\Users\edoardo\Desktop\elifeSchaum\',name,'/',num2str(ch),'/',num2str(pseudo),'/'];

load([out_folder,substring,'_baseline.mat'], 'sessions');   
dataSvmBase=sessions.mvpa.resultSvm.svm;
% adataSvm=sessions.mvpa.resultSvm.svm;ll task comparison
classifAccuracyBase=100*squeeze(dataSvmBase(1,2,:))+50;
 
x=classifAccuracyTask;
% low pass 
[filt] = ft_preproc_lowpassfilter(x', 300, freq, 6, 'but',   'twopass'  , 'no');
y=classifAccuracyBase;
% filt base contain classification of baseline // should be around 50 %
[filtB] = ft_preproc_lowpassfilter(y', 300, freq, 6, 'but',   'twopass'  , 'no');

if dim>1
    
    %  correct time for embedding
    timeO=linspace(-0.2,sessions.mvpa.time_end,270);
       
    time=linspace(timeO(dim),sessions.mvpa.time_end,size(classifAccuracyTask,1));
    
    %  correct time  base for embedding
    timeB=linspace(-0.2,0.5,211);      
    timeBase=linspace(timeB(dim),0.5,size(filtB,2));
  
    
    
else
    time=linspace(-0.2,sessions.mvpa.time_end,size(classifAccuracyTask,1));
    timeB=linspace(-0.2,0.5,size(classifAccuracyBase,1));
    timeBase= timeB;
end


idx1=nearest(time,time_window(1));
idx2=nearest(time,time_window(2));

idB1=nearest(timeBase,time_windowB(1));
idB2=nearest(timeBase,time_windowB(2));

% find maxima peak in a window 0.1-0.35 maximum ssrt
new_signal=filt(1,idx1:idx2);


CI = prctile(new_signal,95);
idx_above=find(new_signal>=CI);
if ~isempty(idx_above)
    
    ii_value=median(new_signal(idx_above));
    
    ii=nearest(new_signal,ii_value);
    
end

% 
[pks,locs] =findpeaks(new_signal);


mean_before=mean(filtB(1,idB1:idB2));% mean of baseline
std_base=std(filtB(1,idB1:idB2),1); % std of baseline

perc_th=[ 50 70 75 90 ]; 
% this corresponds to go backward from the peak with 50%, 30%, 25%, 10% as used by Marti 2015
onset_p=zeros(length(perc_th),1);
% set a threshold

for iThreshold=1:length(perc_th)
  
    new_timeS=linspace(time_window(1),time_window(2),size(new_signal,2));

    bValidPeakFound = false;
   
    for iPeak = 1:length(pks)               
           if pks(iPeak) > mean_before+2*std_base  % posive peaks only
                 dbMaxPower = pks(iPeak);
                 iColMaxPow = locs(iPeak);
                 dbMaxTime = new_timeS(1,iColMaxPow-1);                   
                 bValidPeakFound= true;
                 break;
                 
                 
           end
           
           
           
    end   
    if bValidPeakFound==0
    
     if ii_value > mean_before+2*std_base

            dbMaxPower = ii_value ;
            iColMaxPow =ii ;
            if iColMaxPow ==1
                
                iColMaxPow =2;
            end
            dbMaxTime = new_timeS(1,ii-1);                   
            bValidPeakFound= true;
      else
           bValidPeakFound= false;
            
            
       end
    end

    if bValidPeakFound

         range=abs(mean_before-dbMaxPower);
     
         thr_value=dbMaxPower-range*(100-perc_th(iThreshold))/100;
        
         [jj, id]=find(new_signal(1: iColMaxPow-1)<=(thr_value));
             
         if ~isempty(id)
              onset_p(iThreshold,1)=new_timeS(max(id));
             

         else
              if new_signal(1)>=(thr_value);
                   onset_p(iThreshold,1)=new_timeS(1);
                  
              else
                  
                 onset_p(iThreshold,1)=nan;
                 
              end

         end

    else

           onset_p(iThreshold,1)=nan;  

    end
    if plotFig==1
           % h = figure;set(h, 'Visible', 'on')
            linespec = {'k*', 'b*', 'r*','g*','m*','c*'};
            hold on
            if ch==1
                 subplot(1,2,1)
            else
                 subplot(1,2,2)
            end

            hold on
            plot(time,x,'g')
            hold on
            plot(time,filt,'LineWidth',2)
            hold on
            if ~isnan(onset_p(iThreshold,1))
                id_onset=nearest(time,onset_p(iThreshold,1));
                plot(time(id_onset),filt(id_onset),linespec  {iThreshold},'Markersize',18)
                hold on 
            end
            hold on 
            plot([time(1) time(end)],[mean_before+2*std_base mean_before+2*std_base],'k','LineWidth',3)
            hold on
            plot([time(1) time(end)],[50 50],'k','LineWidth',3)
            plot([vsStats{sub,21}/1000 vsStats{sub,21}/1000],[30 80],'k','LineWidth',4)
            title(num2str(sub))
            hold on 
            plot([0.1 0.1],[40 80],'--k')
            hold on 
            plot([0.35 0.35],[40 80],'--k')
            xlim([-0.05 0.6])
            disp(['sub_n',num2str(sub)])
            disp(['ch_n',num2str(ch)])       
    end
end  


end