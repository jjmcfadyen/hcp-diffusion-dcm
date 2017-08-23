function X = secondLevel(subjectlist)
% subjectlist = path to list of subjects

%% Directories

dir_subjects = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Subjects/';
dir_scratch = '/scratch/ap66/';
dir_hcp = '/scratch/hcp/';
dir_results = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/fMRI/GLM_Long/';

%% Parameters
% Based on Hillebrandt, Friston, & Blakemore (2014)'s HCP data analysis

sessions = {'LR','RL'};
subjects = load(subjectlist);

TR = 0.72; % inter-scan interval (in seconds)
TE = 0.0331; % echo time (in seconds)

spm('defaults','fmri');

%% Second Level - GLM

con_names = {'Faces','Shapes'};
con_labels = {'con_0003','con_0006'};

for c = 1:length(con_names)

    GLM_dir = [dir_results con_names{c}];
    if ~exist(GLM_dir)
        mkdir(GLM_dir);
    end
    GLM_dir = [GLM_dir '/'];

    clear matlabbatch;

    matlabbatch{1}.spm.stats.factorial_design.dir = {GLM_dir};

    for s = 1:length(subjects)
        subj_dir = [dir_scratch num2str(subjects(s,1)) '/GLM_Long/'];
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{s,1} = [subj_dir con_labels{c} '.nii,1'];
    end

    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    % Estimate
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[GLM_dir 'SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    % Contrast Manager
    matlabbatch{3}.spm.stats.con.spmmat = {[GLM_dir 'SPM.mat']};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = con_names{c};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;

    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);

end

end
