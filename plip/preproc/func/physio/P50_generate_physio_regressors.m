%% generate physio regressors and save them in DPARSFA/Physio_Motion_Regressors

clear,clc 
close all

%% need modification
taskU = 'SID'%'MID_placebo'%'SID'%
taskL = 'sid';%'sid'%
ses = 1 % baseline: 0; placebo: 1; lketamine: 2; hketamine: 3
subj_list = [1:7]; % subj
Nscans = 853;

%% code starts
physio_dir = ['/Users/xue/Documents/Stanford/Projects/P50/Analysis/Physio'];
reg_dir = ['/Users/xue/Documents/Stanford/Projects/P50/Analysis/SBvsMB/DPABI/',taskU,'/Physio_Motion_Regressors']
mkdir(reg_dir)
rp_dir = ['/Users/xue/Documents/Stanford/Projects/P50/Analysis/SBvsMB/DPABI/',taskU,'/RealignParameter']
% Scanning parameters
TR = 0.71;
Nslices = 60;
mb_factor = 6;
onset_slice = 8; % near nucleus accumbens, slice 26 actually

% generate regressors
for isub = 1:length(subj_list)
    subj = subj_list(isub)
    if subj < 10
        zeros_pad = '000'
    else
        if subj > 9 && subj < 100
            zeros_pad = '00'
        else
            if subj > 99
               zeros_pad = '0'
            end
        end
    end
    physio_in = [physio_dir, '/s', num2str(ses),'/',taskL, '/sub-P5',zeros_pad,num2str(subj)];
    physio_out = [reg_dir, '/sub-P5',zeros_pad,num2str(subj)];
    rp_dir_subj = [rp_dir,'/sub-P5', zeros_pad,num2str(subj)];
    matlabbatch = P50_tapas_physio_spm_job(physio_in,physio_out,TR,Nslices, mb_factor, Nscans, onset_slice,rp_dir_subj);
    spm_jobman('interactive',matlabbatch)
    spm_jobman('run',matlabbatch)
end
