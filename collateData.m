%% DATA COLLATION

clear all;
clc;

tracks = {
            'SC-PUL'
            'PUL-SC'
            'PUL-AMY'
            'AMY-PUL'
                    };
hemi = {
        'l'
        'r'
            };
subjects = load('/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/DCM/extended_DCM_subjects.txt');
dir_paths = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/ROI_SeedTractography/';

data = []; % 1) subject, 2) track, 3) measurements: 
                                     % b) average path length
                                     % c) streamline count
for h = 1:length(hemi)
    for t = 1:length(tracks)
        
        % Load text file with track length and count 
        P = load([dir_paths 'PathLength/' tracks{t,1} '_' hemi{h} '.txt']);
        
        if h == 2
            t = t + length(tracks); % first half of t (i.e. second dimension of 'data') is left, second half is right
        end
        
        for s = 1:length(subjects)
            
            subj_idx = find(P(:,1) == subjects(s));
            
            if ~isempty(subj_idx)
                data(s,t,:) = [P(subj_idx,2) P(subj_idx,7)];
            else
                data(s,t,:) = [0 0]; % empty tck file
            end
            
        end
    end
end

%% Plot

% Index of tracks so the left and right
idx = [1 5 2 6 3 7 4 8];

% Streamline counts
figure(1);
data = squeeze(data(:,:,2));
plotdata = [];
for t = 1:2:size(data,2)
    plotdata = [plotdata mean(data(:,[t t+1]),2)];
end
bar(mean(plotdata(:,idx)));
set(gca,'XTick',(1:2:size(plotdata,2))+.5);
set(gca,'XTickLabels',tracks(1:2:end));
title('Streamline Count');
local_count = plotdata(:,idx);
save('local_count.mat','local_count');
xlswrite('local_count.xls',local_count);

% Path Length
figure(2);
data = squeeze(data(:,:,1));
plotdata = [];
for t = 1:2:size(data,2)
    plotdata = [plotdata mean(data(:,[t t+1]),2)];
end
bar(mean(plotdata(:,idx)));
set(gca,'XTick',(1:2:size(plotdata,2))+.5);
set(gca,'XTickLabels',tracks(1:2:end));
title('Path Length');
local_path = plotdata(:,idx);
save('local_path.mat','local_path');
xlswrite('local_path.xls',local_path);
