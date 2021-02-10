function iNumSubject = Statistics_Step2_DepSamplesT_BC(iFreq, iTail, strSuffix, viCondContrast, iExclusionSet)

    % iTail = 1: one-tailed, positive
    % iTail = 0: two-tailed
    
    iCondX = viCondContrast(1); % e.g. sSTOP
    iCondY = viCondContrast(2); % e.g. cAC

    iArrowDirection = 0; % left and right arrow trials
    iStrategy = 0; % all subjects
  
    % _BC --> baseline corrected statistics

    % 1) use analytic depsamplesT test here because we're not interested in clusters, 
    %    just compute t values for each voxel when contrasting task vs. baseline
    % 2) as a second level statistics,
    %    use cluster analysis when contrasting the two (baseline corrected) conditions
   
    if ~isdeployed
        addpath('./../SharedFunctions');
    end
    
    [ strProjectRoot, strFieldTripPath ] = SetPathsVersion('20181010');
   
    saSubjects = GetSubjectsByStrategy(iStrategy);
    [ viSubjectExcludes, iNumSets ] = GetSubjectExlusions(iExclusionSet);
    saSubjects(viSubjectExcludes,:) = [];
    
    iNumSubject = size(saSubjects,1);
    
    vsConditions = GetConditionList();
    
    strBeamformerResultsFolder = GetBeamformerFolder(iArrowDirection, iStrategy);

    dbAlpha = 0.05;
    vClusterAlpha = [ 0.05 ];

    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);

    strFreqRange = sprintf('%d-%dHz', freqRange(1), freqRange(2) );
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));

    strInputDir = sprintf('%s%s/%s/%s/DICS_Sources/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange);
    disp(strInputDir);
        
    strOutputDir = sprintf('%s%s/%s/%s/Statistics_n%d%s/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange, iNumSubject, strSuffix);
    strInputDirSingleSubj = sprintf('%s%s/%s/%s/Statistics_SingleSubjectsTaskVsBaseline/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange);
    
    if ~exist(strOutputDir)
        mkdir(strOutputDir)
    end
    
    template = load(sprintf('%sMRI_T1/%s/template_grid.mat', strProjectRoot, getHeadModelsFolderName()));
    Nx = length(template.template_grid.xgrid);
    Ny = length(template.template_grid.ygrid);
    Nz = length(template.template_grid.zgrid);

    for iClusterAlpha = 1:length(vClusterAlpha)

        dbClusterAlpha = vClusterAlpha(iClusterAlpha);

        % second level statistics over all subjects, contrasting the conditions
        ConditionPoolGrandAverages = {};

        for iCond = [iCondX iCondY] 

            SingleSubjSourceStatData = {};

            for iSubj = 1:size(saSubjects,1)

                strFilePathSourceStat = sprintf('%sSourceStat_vs_Baseline_%s_%d_analytic.mat', strInputDirSingleSubj, saSubjects{iSubj,1}, vsConditions{iCond,1});
                load(strFilePathSourceStat); % loads 'SourceStat'    

                SourceStat.pos    = template.template_grid.pos;
                SourceStat.xgrid  = template.template_grid.xgrid;
                SourceStat.ygrid  = template.template_grid.ygrid;
                SourceStat.zgrid  = template.template_grid.zgrid;
                SourceStat.dim    = [Nx Ny Nz];
                SourceStat.inside = template.template_grid.inside;

                SingleSubjSourceStatData{end+1} = SourceStat;
            end

            cfg=[];
            cfg.keepindividual = 'yes';
            cfg.parameter = 'stat';
            Grandavg = ft_sourcegrandaverage(cfg, SingleSubjSourceStatData{:});
            ConditionPoolGrandAverages{iCond} = Grandavg;

        end

        iNumTrialsCondX = size(ConditionPoolGrandAverages{1,iCondX}.stat,1);
        iNumTrialsCondY = size(ConditionPoolGrandAverages{1,iCondY}.stat,1);
        StatSources = ConditionPoolGrandAverages{iCondY};

        cfg             = [];
        cfg.grid        = template.template_grid;
        cfg.dim         = [Nx Ny Nz];
        cfg.parameter   = 'stat';
        cfg.method      = 'montecarlo'; % calls ft_statistics_montecarlo.m
        cfg.correctm    = 'cluster';
        cfg.clusteralpha     = dbClusterAlpha;        
        cfg.statistic   = 'depsamplesT';
        cfg.alpha       = dbAlpha;  
        cfg.clusterstatistic = 'maxsum'; % first analysis: default
        cfg.correcttail = 'alpha'; % sets alpha/2 for cfg.alpha
        cfg.tail             = iTail; % one sided test  % first analysis: default values
        cfg.clustertail      = iTail; % clusteralpha is set as clusteralpha/2 when computecritval = 'yes' (default):
        % ft_sourcestatistics calls ft_statistics_montecarlo
  
        cfg.numrandomization = 5000;
  
        %                           sSTOP              cAC
        cfg.design(1,:) = [ 1:iNumTrialsCondX 1:iNumTrialsCondY ];
        cfg.design(2,:) = [ ones(1,iNumTrialsCondX), 2*ones(1,iNumTrialsCondY) ];
        cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: trials of all conditions and subjects)
        cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)
        
        %                                                  sSTOP                  vs.              cAC
        SourceStat = ft_sourcestatistics( cfg, ConditionPoolGrandAverages{1,iCondX}, ConditionPoolGrandAverages{1,iCondY} );
        % save the result data
        SourceStat.cfg.previous = []; % remove history
        strConditionPrefix = sprintf('SourceStat-%d-BC-vs-%d-BC', vsConditions{iCondX,1}, vsConditions{iCondY,1});
        strFilePathSourceStat = sprintf('%s%s-a-%.3f-clusta-%.5f-tail-%d.mat', strOutputDir, strConditionPrefix, cfg.alpha, cfg.clusteralpha, cfg.tail);
    
        strCondX = strtok(vsConditions{iCondX,2},'_');
        strCondY = strtok(vsConditions{iCondY,2},'_');
        strTitlePrefix = sprintf('Second-level Statistics %s vs. %s', strCondX, strCondY);
            
        SourceStat.myInfo.scriptPath = sprintf('%s.m', mfilename('fullpath'));
        if iNumTrialsCondX ~= iNumTrialsCondY
            SourceStat.myInfo.numSubjects = -1; % size(saSubjects,1);
        else
            SourceStat.myInfo.numSubjects = iNumTrialsCondX; % size(saSubjects,1);
        end
        SourceStat.myInfo.design = cfg.design;
        SourceStat.myInfo.subjects = saSubjects;
        SourceStat.myInfo.title = strTitlePrefix;                        
        
        save(strFilePathSourceStat, 'SourceStat');          
    end
    
end