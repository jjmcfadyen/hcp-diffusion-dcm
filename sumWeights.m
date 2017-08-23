% Run from folder containing SIFT2 textfile output

clear all;
clc;

doclusters = 0; % 0 for no, 1 for yes

dir_results = '/projects/ap66/uqjmcfad/HCP_SubcorticalRoute/Results/SIFT2/';

if docluster
  cd([dir_results 'tckgen_clusters/']);
else cd([dir_Results 'tckgen/']);
end

labels = {'SC-PUL','PUL-AMY','PUL-SC','AMY-PUL'};
hemi = {'l','r'};
clusters = 5;

subjects = load('/scratch/ap66/subjectlist.txt');

data = [];
for s = 1:length(subjects)
    for l = 1:length(labels)
        for h = 1:length(hemi)
        if docluster
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
       else
            disp(['Reading subject ' num2str(subjects(s,1)) ', track ' labels{l} ' ' hemi{h} '...']);
            try
                D = load(['sift2_' labels{l} '_' hemi{h} '_' num2str(subjects(s,1)) '.txt']);
                data(s,l,h) = sum(D);
            catch
                disp(['! File missing for ' num2str(subjects(s,1)) ', track ' labels{l} ' ' hemi{h} '!']);
                data(s,l,h) = 0;
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
  if docluster
    avdirection(:,l,:,:) = mean(data(:,[l l+(length(labels)/2)],:,:),2);
  else
    avdirection(:,l,:) = mean(data(:,[l l+(length(labels)/2)],:),2);
  end
end

if docluster
  tabledata = [];
  colheaders = {};
  counter = 0;
  for l = 1:size(avdirection,2)
      for c = 1:size(avdirection,3)
          for h = 1:size(avdirection,4)
              counter = counter + 1;
              tabledata_clusters = [tabledata squeeze(avdirection(:,l,c,h))]; % save as .mat file
              colheaders{counter} = strjoin({hemi{h},labels{l},'-C',num2str(c)},'');
          end
      end
  end
  save('tabledata_clusters.mat','tabledata_clusters');
  xlswrite('tabledata_clusters.xls',colheaders,1,'A1');
  xlswrite('tabledata_clusters.xls',tabledata_clusters,1,'A2');
else
  tabledata = [];
  colheaders = {};
  counter = 0;
  for l = 1:size(avdirection,2)
          for h = 1:size(avdirection,3)
            counter = counter + 1;
              tabledata = [tabledata squeeze(avdirection(:,l,h))]; % save as .mat file
              colheaders{counter} = strjoin({hemi{h},labels{l}},'');
          end
  end
  save('tabledata.mat','tabledata');
  xlswrite('tabledata.xls',colheaders,1,'A1');
  xlswrite('tabledata.xls',tabledata,1,'A2');
end

% NOTE: if your system doesn't have Excel for Windows installed, the above will be saved 
% as a CSV file without row headers. Refer to "colheaders" to see the column names.
