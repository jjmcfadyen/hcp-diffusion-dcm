function X = analyseFMRI(subject)
% subject = 100206 (string)

%% Directories

dir_script = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Scripts/fMRI';
dir_subjects = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Subjects/';
dir_scratch = '/scratch/ap66/';
dir_hcp = '/scratch/hcp/';

addpath('/projects/ap66/uqjmcfad/MatlabToolboxes/AnalyseToNifti');

%% Parameters
% Based on Hillebrandt, Friston, & Blakemore (2014)'s HCP data analysis

smoothing = [4 4 4];
sessions = {'LR','RL'};

data_units = 'secs';
TR = 0.72; % inter-scan interval (in seconds)
TE = 0.0331; % echo time (in seconds)
res = 16; % time-bins per scan
onset = 1;
frames_per_run = 176;

spm('defaults','fmri');

%% Smoothing

subj_dir = [dir_hcp subject '/MNINonLinear/Results/'];
disp(['[SMOOTHING BATCH: ' subject ']']);

for sess = 1:length(sessions)
    
    filename = ['tfMRI_EMOTION_' sessions{sess}];
    foldername = [dir_scratch subject '/'];
    
    % Get no. of frames
    img = load_nii([foldername filename '.nii']);
    frames = size(img.img,4);
    disp([subject ' ' sessions{sess} ': ' num2str(frames) ' frames.']);
    
    % Smooth
    disp(['Smoothing ' filename '...']);
    clear matlabbatch
    
    for f = 1:frames
        matlabbatch{1}.spm.spatial.smooth.data{f,1} = [foldername filename '.nii,' num2str(f)];
    end
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    
    tic;
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
    disp(['Smoothing complete for ' filename '! Time = ' num2str(toc/60) 'mins']);
    
end

%% First Level - Normal GLM

subj_dir = [dir_scratch subject '/'];
spm_dir = [subj_dir 'GLM'];
if ~exist(spm_dir)
    mkdir(spm_dir);
end
spm_dir = [spm_dir '/'];
    
disp(['[1ST LEVEL BATCH: ' subject ']']);

clear matlabbatch;

disp(['Running 1st level analysis for ' subject '...']);

for sess = 1:length(sessions)

    filename = ['stfMRI_EMOTION_' sessions{sess}];
    sess_dir = [dir_hcp subject '/MNINonLinear/Results/tfMRI_EMOTION_' sessions{sess} '/'];

    matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = data_units;
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = res;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = onset;

    for scan = 1:frames_per_run
        matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,sess).scans{scan,1} = [subj_dir filename '.nii,' num2str(scan)];
    end

    events1 = load([sess_dir 'EVs/fear.txt']);
    events2 = load([sess_dir 'EVs/neut.txt']);

    faces = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).name = 'Faces';
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).onset = events1(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).duration = events1(1,2);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(faces).orth = 0;

    shapes = 2;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).name = 'Shapes';
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).onset = events2(:,1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).duration = events2(1,2);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).cond(shapes).orth = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});

    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {[sess_dir 'Movement_Regressors.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).hpf = 128;

end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% Estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[spm_dir 'SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% Contrast Manager
matlabbatch{3}.spm.stats.con.spmmat = {[spm_dir 'SPM.mat']};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Faces > Shapes';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'both';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Shapes > Faces';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-1 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'both';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'T Effects of Interest';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = [1 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'both';

matlabbatch{3}.spm.stats.con.consess{4}.fcon.name = 'F Effects of Interest';
matlabbatch{3}.spm.stats.con.consess{4}.fcon.convec = {
    [1 0
    0 1]
    }';
matlabbatch{3}.spm.stats.con.consess{4}.fcon.sessrep = 'both';

matlabbatch{3}.spm.stats.con.delete = 0;

% Run job
tic;
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
disp(['First-level GLM complete for ' filename '! Time = ' num2str(toc/60) 'mins']);

end
