clear all;
close all;
clc;

session = 1;
subject=100307;

for model = 73:106
    
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
if any(model == [73:106])
    DCM.a(5,9) = 0;
    DCM.a(6,10) = 0;
end


    DCM.b(:,:,1) = DCM.a;
    for n = 1:length(DCM.a)
        DCM.b(n,n,1) = 0;
    end
    
    %% Draw figure
    roi_coords = [2,4;  %lSC
                  2,9;  %rSC
                  4,4;  %lPUL
                  4,9;  %rPUL
                  6,4;  %lAMG
                  6,9;  %rAMG
                  4,2;  %lV1
                  4,7;  %rV1
                  6,2;  %lFG
                  6,7]; %rFG
    
              
    roi_labels = {'lSC'
                 'rSC'
                  'lPUL'
                  'rPUL'
                  'lAMG'
                  'rAMG'
                  'lV1'
                  'rV1'
                  'lFG'
                  'rFG'};
              
    [TO FROM] = find(squeeze(DCM.b(:,:,1)));
    figure(model);
    for i = 1:length(FROM)
        p1 = [roi_coords(FROM(i),2) roi_coords(FROM(i),1)];
        p2 = [roi_coords(TO(i),2) roi_coords(TO(i),1)];
        dp = p2-p1;
        
        quiver(p1(1),p1(2),dp(1),dp(2),0);
        text(p1(1),p1(2)+.33,roi_labels{FROM(i)});
        text(p2(1),p2(2)+.33,roi_labels{TO(i)});
        hold on;
        
    end
    grid;
    axis([1 10 1 7]);
    
    input('Press ENTER to continue ')
    close all;
    
end
