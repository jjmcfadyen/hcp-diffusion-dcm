% Run from folder containing SIFT2 textfile output

clear all;
clc;
cd /projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/SIFT2/tckgen_clusters/textfiles;

labels = {'SC-PUL','PUL-AMY','PUL-SC','AMY-PUL'};
hemi = {'l','r'};
clusters = 5;

subjects = load('/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Subjects/subjectlist.txt');

data = [];
for s = 1:length(subjects)
    for l = 1:length(labels)
        for h = 1:length(hemi)
            for c = 1:clusters
                disp(['Reading subject ' num2str(subjects(s,1)) ', track ' labels{l} ' ' hemi{h} ', cluster' num2str(c) '...']);
                try
                    D = load(['sift2_' labels{l} '_Cluster' num2str(c) '_' hemi{h} '_' num2str(subjects(s,1)) '.txt']);
                    data(s,l,c,h) = sum(D);
                catch
                    disp(['! File missing for ' num2str(subjects(s,1)) ', track ' labels{l} ' Cluster ' num2str(c) ' ' hemi{h} '!']);
                    data(s,l,c,h) = 0;
                end
            end
        end
    end
end

cd ..
save('data','data');

% average forwards/backwards
avdirection = [];
for l = 1:length(labels)/2
    avdirection(:,l,:) = mean(data(:,[l l+(length(labels)/2)],:),2);
end

tabledata = [];
for l = 1:size(avdirection,2)
    for c = 1:size(avdirection,3)
        for h = 1:size(avdirection,4)
            tabledata = [tabledata squeeze(avdirection(:,l,c,h))];
        end
    end
end
save('tabledata','tabledata');
