%-----------------------------------------------------------------------
% Job saved on 14-Aug-2020 06:27:25 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.name = 'dir';
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {{'D:\SourceData_fMRI_stopVSac'}};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent(1) = cfg_dep('Named Directory Selector: dir(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'Ttest_stopVSac';
matlabbatch{3}.spm.stats.factorial_design.dir(1) = cfg_dep('Make Directory: Make Directory ''Ttest_stopVSac''', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dir'));
%%
matlabbatch{3}.spm.stats.factorial_design.des.t1.scans = {
                                    'D:\SourceData_fMRI_stopVSac\VP01_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP02_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP03_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP04_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP05_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP06_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP07_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP08_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP09_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP10_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP11_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP12_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP13_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP14_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP15_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP16_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP17_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP18_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP19_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP20_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP21_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP22_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP23_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP24_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP25_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP26_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP27_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP28_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP29_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP30_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP31_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP32_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP33_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP34_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP35_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP36_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP37_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP38_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP39_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP40_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP41_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP42_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP43_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP44_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP45_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP46_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP47_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP48_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP49_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP50_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP51_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP52_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP53_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP54_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP55_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP56_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP57_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP58_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP59_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP60_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP61_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP62_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP63_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP64_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP65_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP66_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP67_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP68_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP69_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP70_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP71_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP72_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP73_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP74_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP75_con_0006.nii,1'
                                    'D:\SourceData_fMRI_stopVSac\VP76_con_0006.nii,1'

                                                          };
%%
%%
matlabbatch{3}.spm.stats.factorial_design.cov.c = [0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   0
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1
                                                   1];
%%
matlabbatch{3}.spm.stats.factorial_design.cov.cname = 'site';
matlabbatch{3}.spm.stats.factorial_design.cov.iCFI = 1;
matlabbatch{3}.spm.stats.factorial_design.cov.iCC = 1;
matlabbatch{3}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{3}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{3}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{3}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{3}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{3}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{3}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{5}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'stop>ac';
matlabbatch{5}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.delete = 0;
