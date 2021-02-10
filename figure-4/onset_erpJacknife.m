
function resultJack= onset_erpJacknife(name,ch1,ch2,pseudo,thr)

load('C:\Users\edoardo\Desktop\elifeSchaum\SSRT.mat')
th=thr/100;

avgData=zeros(59,2,256);

avgBase=zeros(60,1);
avgBase2=zeros(60,1);

% take baseline as in onset analysis
timeB=linspace(-0.2,0.5,211); % original time
timeBase=linspace(timeB(14),0.5,196); %embedded time
time_windowB=[0    0.250];
idB1=nearest(timeBase,time_windowB(1));
idB2=nearest(timeBase,time_windowB(2));


for sub=1:59
      %load ifg
      out_folder=['C:\Users\edoardo\Desktop\elifeSchaum\',name,'\',num2str(ch1),'\',num2str(pseudo),'\'];
      substring=vsStats{sub,1};
      load([out_folder,substring,'.mat'], 'sessions');   

      dataSvm=sessions.mvpa.resultSvm.svm;
      classifAccuracyTask=100*squeeze(dataSvm(1,2,:))+50;
      x=classifAccuracyTask';

    
      avgData(sub,1,:)=[x];
     
     
    %load baseline to deterine mean
     
    load([out_folder,substring,'_baseline.mat'], 'sessions');   

    dataSvm=sessions.mvpa.resultSvm.svm;
    classifAccuracyBase=100*squeeze(dataSvm(1,2,:))+50;
    x=classifAccuracyBase;
   
    
        
    avgBase(sub,1)=mean(x(idB1:idB2));
      
   
    
    %load presma
    out_folder=['C:\Users\edoardo\Desktop\elifeSchaum\',name,'\',num2str(ch2),'\',num2str(pseudo),'\'];
       
    load([out_folder,substring,'.mat'], 'sessions');   
    dataSvmBase=sessions.mvpa.resultSvm.svm;
    classifAccuracyTask2=100*squeeze(dataSvmBase(1,2,:))+50;
    x=classifAccuracyTask2';
      
    avgData(sub,2,:)=[x];
    
    load([out_folder,substring,'_baseline.mat'], 'sessions');   

    dataSvm=sessions.mvpa.resultSvm.svm;
    classifAccuracyBase=100*squeeze(dataSvm(1,2,:))+50;
    x=classifAccuracyBase;
       
        
    avgBase2(sub,1)=mean(x(idB1:idB2));
      
   
end

% 59 subjects plus grand average base
avgBase(60,1)=mean(avgBase);

cfg=[];
cfg.extract='onset';
cfg.aggregate='jackMiller';
cfg.chans=1;

% redefine time after embedding 14
times1=linspace(-0.200,0.699,270);
cfg.times=linspace(times1(14),0.699,256);
 
cfg.peakWin=[0.100 0.35];
cfg.timeFormat='s';
cfg.areaWin ='ampLat';
cfg.percAmp = th;
cfg.fig='True';
cfg.peakWidth=0;
cfg.ampLatWin=[0.1 0.35];
[res1,cfgNew] = latency(cfg,avgData,1, avgBase);

set(gcf, 'Position', [1, 1,1200,900]) 
close(gcf)


avgBase2(60,1)=mean(avgBase2);
cfg=[];
cfg.extract='onset';
cfg.aggregate='jackMiller';
cfg.chans=2;
times1=linspace(-0.200,0.699,270);
cfg.times=linspace(times1(14),0.699,256);

cfg.peakWin=[0.100 0.35];
cfg.timeFormat='s';
cfg.areaWin ='ampLat';
cfg.percAmp = th;
cfg.fig='True';
cfg.ampLatWin=[0.1 0.35];
cfg.peakWidth=0;

[res2,cfgNew] = latency(cfg,avgData,1, avgBase2)
 set(gcf, 'Position', [1, 1,1200,900]) 
close(gcf)


mean(res1)
mean(res2)

mean_ifg=mean(res1);
meanpresma=mean(res2);
resultJack = jackT(res1,res2);

save('C:\Users\edoardo\Desktop\elifeSchaum\jacnife_results.mat','resultJack','mean_ifg','meanpresma')
