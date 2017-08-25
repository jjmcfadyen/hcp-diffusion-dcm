%% Extract parameter estimates

clear all;
clc;

dir_DCM = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/DCM/60Models/';
load([dir_DCM 'extended_DCM_subjects.mat']);
subjects = extended_DCM_subjects;

model = 60;
coords = [
            3,1;    % lSC-lPUL
            4,2;    % rSC-rPUL
            5,3;    % lPUL-lAMG
            6,4;    % rPUL-rAMG
            9,7;    % lIOG-lFG
            10,8;   % rIOG-rFG
            5,9;    % lFG-lAMG
            6,10;   % rFG-rAMG
            5,7;    % lV1-lAMG
            6,8;    % rV1-rAMG
            1,3;    % lPUL-lSC
            2,4;    % rPUL-rSC
            3,5;    % lAMG-lPUL
            4,6;    % rAMG-rPUL
            7,9;    % lFG-lV1
            8,10;   % rFG-rV1
            9,5;    % lAMG-lFG
            10,6;   % rAMG-rFG
            7,5;    % lAMG-lV1
            8,6;    % rAMG-rV1
                ];
            

data = [];
for s = 1:length(subjects)
    subject = num2str(subjects(s,1));
    disp(['Saving data for ' subject '...']);
    for sess = 1:2
        load([dir_DCM 'SubjectFolders/' subject '/DCM_sixty_m' ...
            num2str(model) '_sess' num2str(sess) '_' subject '.mat']);
        for c = 1:size(coords,1)
            data.A(s,c,sess) = DCM.Ep.A(coords(c,1),coords(c,2));
            data.B(s,c,sess) = DCM.Ep.B(coords(c,1),coords(c,2));
        end
    end
end

data.A = squeeze(mean(data.A,3));
data.B = squeeze(mean(data.B,3));

grand.A = mean(data.A,1);
grand.B = mean(data.B,1);
