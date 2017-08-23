function extract_VOIs_persubject(subject)

%% Extract Time Series - using structural masks

if ~ischar(subject)
     subject = num2str(subject);
end

top_dir = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/';
main_dir = '/scratch/ap66/';

ROI_labels = {
                'lSC'
                'rSC'
                'lPUL'
                'rPUL'
                'lAMY'  
                'rAMY'
                'lFG'
                'rFG'
                'lV1'
                'rV1'
                        };

group_coords = [
                -38 -50 -20;  % lFG
                40 -52 -18;   % rFG
                -22 -92 -10;  % lV1
                28 -90 -8;    % rV1
                ]; 

mask_list = {
             'SC_l_MNI_no-overlap'
             'SC_r_MNI_no-overlap'
             'PUL_l_MNI_no-overlap'
             'PUL_r_MNI_no-overlap'
             'AMY_l_MNI'
             'AMY_r_MNI'
                        };

                
disp(['Deleting old VOIs for ' subject '...']);
subj_glmdir = [main_dir subject '/GLM_Long/'];
filelist = dir([subj_glmdir 'VOI*']);
for f = 1:length(filelist)
   delete([subj_glmdir filelist(f).name]);
end  

 
disp(['Running subject ' subject '...']);   
cd(subj_glmdir);

for sess = 1:2
   for r = 1:length(ROI_labels)

       clear matlabbatch;

       matlabbatch{1}.spm.util.voi.spmmat = {[subj_glmdir 'SPM.mat']};
       matlabbatch{1}.spm.util.voi.adjust = sess+9;
       matlabbatch{1}.spm.util.voi.session = sess;
       matlabbatch{1}.spm.util.voi.name = [ROI_labels{r,1} '_sess' num2str(sess)];

       matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
       matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = sess;
       matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
       matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
       matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
       matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
       matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});

       if r <= length(mask_list)
           matlabbatch{1}.spm.util.voi.roi{2}.mask.image = {[top_dir 'Masks/MNI_Resliced2mm/resliced2mm_' mask_list{r,1} '.nii']};
           matlabbatch{1}.spm.util.voi.roi{2}.mask.threshold = 0;
       else
           matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = group_coords(r-length(mask_list),:);
           matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = 4;
           matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.local.spm = 1;
           matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.local.mask = 'i3';
           matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = group_coords(r-length(mask_list),:);
           matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 8;
           matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.fixed = 1; 
       end

       matlabbatch{1}.spm.util.voi.expression = 'i1&i2';

       try
           spm_jobman('initcfg');
           spm_jobman('run',matlabbatch);
       catch
           msg = ['Error with ' subject ', session ' num2str(sess) ', ' ROI_labels{r,1}];
           warning(msg);
       end
   end   
end

end
