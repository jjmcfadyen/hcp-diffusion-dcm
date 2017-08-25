function DCM = specify_DCM_extended(subject,model,session,deleteOld)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DYNAMIC CAUSAL MODELLING

% subject = subject ID (e.g. 100307)
% model = number (e.g. 1)
% session = fMRI session specified in SPM to conduct the DCM on
% deleteOld = 0 to overwrite previous DCM.mat files (can sometimes create files with the wrong parameters) and 1 to delete the old DCM.mat file for this subject/model/session

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(subject)
    subject = num2str(subject);
end

dir_GLM = ['/scratch/ap66/' subject '/GLM_Long/'];
dir_save = ['/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/DCM/60Models/SubjectFolders/' subject '/'];

if ischar(deleteOld)
    deleteOld = str2num(deleteOld);
end
if deleteOld == 1
    disp(['Deleting DCM for model ' num2str(model) ', session ' num2str(session) '...']);
    delete([dir_save 'DCM_extended_m' num2str(model) '_sess' num2str(session) '_' subject '.mat']);
end

ROIs = {
        'SC'
        'PUL'
        'AMY'
        'V1'
        'FG'
            };
hemispheres = {'l','r'};

%% Load template
load('DCM_template.mat');

dcm_filename = ['DCM_m' num2str(model) '_sess' num2str(session) '_' subject];

N = DCM.n; % no. of nodes/regions

DCM.c = zeros(N, 2);
if any(model == [1:8 25:40 73:74 85:92])
    DCM.c([1 2 7 8],:) = 1; % input to IOG and SC
end
if any(model == [9:16 41:56 75:106])
    DCM.c([3 4 7 8],:) = 1; % input to IOG and PUL
end
if any(model == [17:24 57:72 79:82 99:106])
    DCM.c([1 2 3 4 7 8],:) = 1; % input to IOG and SC
end

% FG - IOG
if any(model == [2:2:782 85 86 89 90 93 94 97 98 101 102 105 106])
    DCM.a(7,9) = 1;
    DCM.a(8,10) = 1;
end
% AMG-FG
if any(model == [2:2:72])
    DCM.a(9,5) = 1;
    DCM.a(10,6) = 1;
end
% FG-AMG
if any(model == [1:72])
    DCM.a(5,9) = 1;
    DCM.a(6,10) = 1;
end
if any(model == [73:106])
    DCM.a(5,9) = 0;
    DCM.a(6,10) = 0;
end
% IOG - AMG
if any(model == [5:8 13:16 21:24 29:32 37:40 45:48 53:56 61:64 69:106])
    DCM.a(5,7) = 1;
    DCM.a(6,8) = 1;
end
% AMG-IOG
if any(model == [6 8 14 16 22 24 30 32 38 40 46 48 54 56 62 64 70 72 74:2:82 85 86 89 90 93 94 97 98 101 102 105 106])
    DCM.a(7,5) = 1;
    DCM.a(8,6) = 1;
end
% SC - PUL
if any(model == [25:40 57:72 83:90 99:106])
    DCM.a(3,1) = 1;
    DCM.a(4,2) = 1;
end
% PUL - AMG
if any(model == [25:72 83:106])
    DCM.a(5,3) = 1;
    DCM.a(6,4) = 1;
end
% PUL - SC
if any(model == [26 27 30 31 34 35 38 39 58 59 62 63 66 67 70 71 84 85 88 89 100 101 104 105])
    DCM.a(1,3) = 1;
    DCM.a(2,4) = 1;
end
% AMG - PUL
if any(model == [26 27 30 31 34 35 38 39 42 43 46 47 50 51 54 55 58 59 62 63 66 67 70 71 84 85 88 89 92 93 96 97 100 101 104 105])
    DCM.a(3,5) = 1;
    DCM.a(4,6) = 1;
end
% PUL - IOG
if any(model == [3 4 7 8 11 12 15 16 19 20 23 24 33:40 49:56 65:72 77 78 81 82 87:90 95:98 103:106])
    DCM.a(7,3) = 1;
    DCM.a(8,4) = 1;
end
% IOG - PUL
if any(model == [4 8 12 16 20 24 34 38 36 40 50 54 52 56 66 70 68 72 78 82 89 90 97 98 105 106])
    DCM.a(3,7) = 1;
    DCM.a(4,8) = 1;
end


DCM.b(:,:,1) = DCM.a;
for n = 1:length(DCM.a)
    DCM.b(n,n,1) = 0;
end

cd(dir_save);
save(dcm_filename,'DCM');

%% Estimate VOIs

voi_filenames = {};
counter = 0;
for r = 1:length(ROIs)
    for h = 1:length(hemispheres)
        counter = counter + 1;
        voi_filenames{counter} = [dir_GLM 'VOI_' hemispheres{h} ROIs{r} '_sess' num2str(session) '_' num2str(session) '.mat'];
    end
end

spm_dcm_voi(dcm_filename, voi_filenames);
spm_dcm_U(dcm_filename,[dir_GLM 'SPM.mat'],session,{1 1});

%% Estimate DCM

DCM = spm_dcm_estimate(dcm_filename);

disp(['DCM estimated for ' subject ', model ' num2str(model) ' session ' num2str(session) '!']);

end
