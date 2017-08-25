%% BMS

clear all;
clc;

% addpath('/projects/ap66/uqjmcfad/MatlabToolboxes/spm12');
spm('defaults','fmri');
 
dir_dcm = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/DCM/60Models/';
methods = {'FFX','RFX'};
dcm_subjects = load('extended_DCM_subjects.txt');
sessions = 1:2;
models = [1:2 5 6 9:106];

do_BMA = 0; % 1 for yes, 0 for no

ROI_labels = {
                'lSC'
                'rSC'
                'lPUL'
                'rPUL'
                'lAMG'
                'rAMG'
                'lIOG'
                'rIOG'
                'lFG'
                'rFG'
                        };
    
for M = 1:length(methods)
    
    if do_BMA == 0
        dir_method = [dir_dcm methods{M} '/'];
    elseif do_BMA == 1
        dir_method = [dir_dcm methods{M} '_BMA/'];
    end
    if ~exist(dir_method)
        mkdir(dir_method);
    end
    
    if exist([dir_method 'BMS.mat'])
        filelist = dir(dir_method);
        disp(['Deleting old BMS files from ' dir_method '...']);
        for f = 3:length(filelist)
            delete([dir_method filelist(f).name]);
        end
    end
    clear matlabbatch;
    matlabbatch{1}.spm.dcm.bms.inference.dir = {dir_method};
    
    for s = 1:length(dcm_subjects)
        for sess = 1:length(sessions)
            for m = 1:length(models)
                matlabbatch{1}.spm.dcm.bms.inference.sess_dcm{s}(sess).dcmmat{m,1} = [dir_dcm '/SubjectFolders/' num2str(dcm_subjects(s)) '/DCM_sixty_m' num2str(models(m)) '_sess' num2str(sess) '_' num2str(dcm_subjects(s)) '.mat'];
            end
        end
    end

    matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
    matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
    matlabbatch{1}.spm.dcm.bms.inference.method = methods{M};
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_name = 'Cortical SC';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(1).family_models = [1:4 69 70]';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_name = 'Cortical PUL';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(2).family_models = [5:12 71:74]';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_name = 'Cortical SC PUL';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(3).family_models = [13:20 75:78]';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(4).family_name = 'Dual SC';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(4).family_models = [21:36 79:86]';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(5).family_name = 'Dual PUL';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(5).family_models = [37:52 87:94]';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(6).family_name = 'Dual SC PUL';
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family(6).family_models = [53:68 95:102]';
    if do_BMA == 1
        matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_all = 'famwin';
    elseif do_BMA == 0
        matlabbatch{1}.spm.dcm.bms.inference.bma.bma_no = 0;
    end
    matlabbatch{1}.spm.dcm.bms.inference.verify_id = 0;

    spm_jobman('initcfg');
    tic;
    spm_jobman('run',matlabbatch);
    disp(['Time for job to complete = ' num2str(toc/60) ' minutes']);
    
    if exist([dir_method 'BMS.mat'])
	disp(['BMS file exists for ' methods{M}]);
    else disp(['BMS file does not exist for ' methods{M}]);
    end

    % Make figures of results

    load([dir_method 'BMS.mat']);

    if M == 1 % FFX

        bms = BMS.DCM.ffx;

        % Plot F, log evidence, and posterior probability
        figure(11)
        subplot(1,3,1);
        [val, worst_model] = min(bms.SF);
        relative = bms.SF-bms.SF(worst_model);
        bar(relative);
        title('Log Evidence (relative)');
        xlabel('Models')
        subplot(1,3,2);
        bar(bms.model.like);
        title('Estimated Likelihood');
        xlabel('Models');
        ylim([0 1]);
        subplot(1,3,3);
        bar(bms.model.post);
        title('Posterior Likelihood');
        xlabel('Models');
        ylim([0 1]);
        set(figure(11),'Position',get(0,'Screensize'));
        saveas(figure(11),[dir_method 'models.jpg']);
        %close(figure(11));

        % Plot results of Family
        figure(12)
        subplot(1,2,1);
        bar(bms.family.like);
        title('Estimated Likelihood');
        xlabel('Models');
        ylim([0 1]);
        subplot(1,2,2);
        bar(bms.family.post);
        title('Posterior Likelihood');
        xlabel('Models');
        ylim([0 1]);
        set(figure(12),'Position',get(0,'Screensize'));
        saveas(figure(12),[dir_method 'families.jpg']);
        %close(figure(12));

    elseif M == 2 % RFX
        bms = BMS.DCM.rfx;

        figure(21);
        subplot(1,2,1);
        bar(bms.model.exp_r);
        title('Expected Probability');
        xlabel('Models');
        ylim([0 1]);
        subplot(1,2,2);
        bar(bms.model.xp);
        title('Exceedance Probability');
        xlabel('Models');
        ylim([0 1]);
        set(figure(11),'Position',get(0,'Screensize'));
        saveas(figure(11),[dir_method 'models.jpg']);
        %close(figure(11));

        % Plot results of Family
        figure(22)
        subplot(1,2,1);
        bar(bms.family.exp_r);
        title('Expected Probability');
        xlabel('Models');
        ylim([0 1]);
        subplot(1,2,2);
        bar(bms.family.xp);
        title('Exceedance Probability');
        xlabel('Models');
        ylim([0 1]);
        set(figure(12),'Position',get(0,'Screensize'));
        saveas(figure(12),[dir_method 'families.jpg']);
        %close(figure(12));

    end

    if do_BMA == 1
        % Plot results of BMA
        figure(13);
        imagesc(bms.bma.mEp.A);
        title('A Matrix Parameter Estimates');
        set(gca,'XTickLabel',ROI_labels);
        set(gca,'YTickLabel',ROI_labels);
        xlabel('From');
        ylabel('To');
        colormap('jet');
        colorbar;
        saveas(figure(13),[dir_method 'PE_A.jpg']);
        %close(figure(13));

        figure(14);
        imagesc(bms.bma.mEp.B);
        title('B Matrix Parameter Estimates');
        set(gca,'XTickLabel',ROI_labels);
        set(gca,'YTickLabel',ROI_labels);
        xlabel('From');
        ylabel('To');
        colormap('jet');
        colorbar;
        saveas(figure(13),[dir_method 'PE_B.jpg']);
        %close(figure(13));
    end
end
