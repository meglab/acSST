function Statistics_Step1_Analytic_BC(iFreq, iSubj)

    iArrowDirection = 0; % left and right arrow trials
    iStrategy = 0;  % all subjects
  
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
     
    vsConditions = GetConditionList();
    viConds = [3 5]; % sSTOP / cAC

    strBeamformerResultsFolder = GetBeamformerFolder(iArrowDirection, iStrategy);

    [ freqRange, baselineInterval, taskInterval ] = GetFrequencyTimeRange(iFreq);

    strFreqRange = sprintf('%d-%dHz', freqRange(1), freqRange(2) );
    strTimeInterval = sprintf('v%d_BI%.4f_%.4fs_TI%.4f_%.4fs', iFreq, baselineInterval(1), baselineInterval(2), taskInterval(1), taskInterval(2));

    strInputDir = sprintf('%s%s/%s/%s/DICS_Sources/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange);
    disp(strInputDir);

    strOutputDir = sprintf('%s%s/%s/%s/Statistics_SingleSubjectsTaskVsBaseline/', strProjectRoot, strBeamformerResultsFolder, strTimeInterval, strFreqRange);
     
    if ~exist(strOutputDir)
        mkdir(strOutputDir)
    end
    
    template = load(sprintf('%sMRI_T1/%s/template_grid.mat', strProjectRoot, getHeadModelsFolderName()));
    Nx = length(template.template_grid.xgrid);
    Ny = length(template.template_grid.ygrid);
    Nz = length(template.template_grid.zgrid);

    %% source statistics task vs. base for each subject        
    for iCond = viConds %1:size(vsConditions,1)

        strInputPath = sprintf('%s%s_Sources_%d.mat', strInputDir, saSubjects{iSubj,1}, vsConditions{iCond,1});
        disp(strInputPath);
        Task = load(strInputPath); % loads 'Sources'

        strInputPath = sprintf('%s%s_Sources_%d.mat', strInputDir, saSubjects{iSubj,1}, vsConditions{iCond+1,1});
        Baseline = load(strInputPath); % loads 'Sources'

        cfg             = [];
        cfg.grid        = template.template_grid;
        cfg.dim         = [Nx Ny Nz];
        cfg.parameter   = 'pow';
        % use analytic here because we're not interested in clusters, just need t values for each voxel
        % cluster analysis is done later in contrasting the two (baseline corrected) conditions
        cfg.method      = 'analytic';
        cfg.statistic   = 'depsamplesT';
        cfg.alpha       = 0.05;
        cfg.design(1,:) = [1:length(Task.Sources.trial) 1:length(Baseline.Sources.trial)];
        cfg.design(2,:) = [ ones(1, length(Task.Sources.trial)), 2*ones(1, length(Baseline.Sources.trial)) ];
        cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: trials of all conditions and subjects)
        cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)

        SourceStat = ft_sourcestatistics( cfg, Task.Sources, Baseline.Sources);
        % save the result data
        SourceStat.cfg.previous = []; % remove history
        SourceStat.myInfo.scriptPath = sprintf('%s.m', mfilename('fullpath'));
        strFilePathSourceStat = sprintf('%sSourceStat_vs_Baseline_%s_%d_analytic.mat', strOutputDir, saSubjects{iSubj,1}, vsConditions{iCond,1});
        save(strFilePathSourceStat, 'SourceStat');

    end
       
end