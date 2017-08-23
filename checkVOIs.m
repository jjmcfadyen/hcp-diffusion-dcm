%% Check if VOIs overlap and were completed

clear all;
clc;

top_dir = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/';
main_dir = '/scratch/ap66/';

subjects = load([top_dir 'Subjects/subjectlist.txt']);

ROI_labels = {
                'lSC'
                'rSC'
                'lPUL'
                'rPUL'
                'lAMY'  
                'rAMY'
                'lFG'
                'rFG'
                        };

% Check VOIs don't overlap
overlap = {};   
counter = 0;
complete_vois = zeros(length(subjects),length(ROI_labels)*2);
for s = 1:length(subjects)
    
    subject = num2str(subjects(s));
    
    subj_glmdir = [main_dir subject '/GLM_Long/'];
    cd(subj_glmdir);
    
    for sess = 1:2
        
        % Load VOIs
        voi_list = [];
        for r = 1:length(ROI_labels)
            
            voi_name = [subj_glmdir 'VOI_' ROI_labels{r,1} '_sess' num2str(sess) '_' num2str(sess) '.mat'];
            if exist(voi_name)
                load([subj_glmdir 'VOI_' ROI_labels{r,1} '_sess' num2str(sess) '_' num2str(sess) '.mat']);
                VOI{r} = xY;
                voi_list = [voi_list r];
            end
        end
        if sess == 1
            complete_vois(s,voi_list) = 1;
        elseif sess == 2
            complete_vois(s,voi_list+length(ROI_labels)) = 1;
        end
        
        % Check overlap in each session
        disp(['Checking ' subject ', session ' num2str(sess) ' for overlapping voxels...']);
        combos = combntns(voi_list,2);
        if length(combos) > 1
            for c = 1:size(combos,1)
                V1 = combos(c,1);
                V2 = combos(c,2);
                for voxel = 1:size(VOI{V1}.XYZmm,2)

                    check = strmatch([VOI{V1}.XYZmm(:,voxel)], VOI{V2}.XYZmm');
                    if ~isempty(check)
                        counter = counter + 1;
                        overlap{counter,1} = ['! Voxels overlap for ' subject ', session ' num2str(sess) ...
                            ', between ROI ' ROI_labels{combos(c,1),1} ' and ' ROI_labels{combos(c,2),1} ', voxel ' num2str(voxel) '!'];
                        warning(overlap{counter,1});
                    end
                end
            end
        end
    end
end

% Re-do compelte vois
ROIs = {'SC','PUL','AMY','FG','V1'};
hemispheres = {'l','r'};
complete_vois = [];
complete_vois_long = zeros(length(subjects),length(ROIs)*length(hemispheres)*2);
labels = {};
for s = 1:length(subjects)
    counter = 0;
    for r = 1:length(ROIs)
        for h = 1:length(hemispheres)
            for sess = 1:2
                counter = counter + 1;
                labels = [labels [hemispheres{h} ROIs{r} num2str(sess)]];
                if exist(['/scratch/ap66/' num2str(subjects(s)) '/GLM_Long/VOI_' hemispheres{h} ROIs{r} '_sess' num2str(sess) '_' num2str(sess) '.mat'])
                    complete_vois(s,r,h,sess) = 1;
                    complete_vois_long(s,counter) = 1;
                else complete_vois(s,r,h,sess) = 0;
                end
            end
        end
    end
end

save([top_dir 'Results/fMRI/GLM_Long/voi_overlap.mat'],'overlap');
save([top_dir 'Results/fMRI/GLM_Long/complete_vois.mat'],'complete_vois');
save([top_dir 'Results/fMRI/GLM_Long/complete_vois_long.mat'],'complete_vois_long');

figure(11);
imagesc(complete_vois_long);
colormap([1 0 0; 0 0 1]); % blue for complete, red for incomplete
title('Successful VOIs');
ylabel('Subjects');
xlabel('ROIs');
set(gca,'XTick',1:16);
set(gca,'XTickLabels',labels);
