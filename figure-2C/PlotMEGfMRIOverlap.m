addpath('./../SharedFunctions');
[ strProjectRoot, strFieldTripDir ] = SetPaths();

% load fMRI data, loads 'stopVSac'
load('fMRI_spmT0001.mat');

% load MEG data, loads 'SourceStat'
load('SourceStat-2-BC-vs-3-BC-a-0.050-clusta-0.05000-tail-0.mat');


% MNI template
mriDataPath = sprintf('%sMRI_T1/StandardMRI_detailed.mat', strProjectRoot);
load( mriDataPath );  % loads structure StandardMRI    

% MEG plot
SourceStat.stat = abs(SourceStat.stat);
SourceStat.stat = SourceStat.stat ./ max(SourceStat.stat)
cfg            = [];
cfg.parameter  = {'stat','mask'};
SourceStat.unit = 'mm';
mri.unit = 'mm';
SourceStatInt  = ft_sourceinterpolate(cfg, SourceStat , mri);  

% fMRI plot
stopVSac.anatomy = abs(stopVSac.anatomy);
stopVSac.anatomy = stopVSac.anatomy ./ max(max(max(stopVSac.anatomy)));
stopVSac.stat = stopVSac.anatomy;
stopVSac.mask = stopVSac.anatomy;
stopVSac = rmfield(stopVSac,'anatomy')

cfg            = [];
cfg.parameter  = {'stat','mask'};
stopVSac.unit = 'mm';
mri.unit = 'mm';
stopVSacInt  = ft_sourceinterpolate(cfg, stopVSac , mri);  

overlap = SourceStatInt;
overlap.stat = SourceStatInt.stat .* SourceStatInt.mask .* stopVSacInt.stat;
overlap.mask = overlap.stat;

cfg = [];
%cfg.method         = 'ortho';
cfg.method       = 'slice';
%cfg.method        = 'surface';
%cfg.projmethod = 'project';  % 'nearest';

cfg.funcolormap   = 'jet';    

cfg.interactive   = 'yes';
cfg.funcolorlim = 'maxabs';  

cfg.funparameter  = 'stat';
cfg.maskparameter = 'mask';

ft_sourceplot(cfg, SourceStatInt);
ft_sourceplot(cfg, stopVSacInt);
ft_sourceplot(cfg, overlap);


