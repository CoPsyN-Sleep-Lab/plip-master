function pl_runPPI(ppi_dir, model_dir, VOI_name, contrast_number)
%This has been adapted from ....

% This batch script analyses the Attention to Visual Motion fMRI dataset
% available from the SPM site using PPI:
% http://www.fil.ion.ucl.ac.uk/spm/data/attention/
% as described in the SPM manual:
%  http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf

% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin & Darren Gitelman
% $Id: ppi_spm_batch.m 17 2009-09-28 15:37:01Z guillaume $

%% OUTPUTS
% For each mask and contrast use the SPM data structure of the first level
% connectivity GLM to generate a new PPI first level analysis with the
%    1) psychological variable (task)
%    2) physiological variable (deconvolved BOLD signal from VOI) and
%    3) the interaction between the psychological and physiological
%    variables

%%%Assumptions
% 3) a first level GLM has been run with the contrasts of interst using the connectivity pipeline.
%    This is where the time course for the VOI will be dumped from
% 4) The new PPI first level model will be created and include the task
%    processing pipeline, the mask used to create the VOI and the specific
%    contrast from the first level GLM from which the psychological variable
%    was created

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSYCHO-PHYSIOLOGIC INTERACTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

orig_dir = pwd;
spmmat = fullfile(model_dir, 'SPM.mat');
model = load(spmmat);
NUMBER_OF_SESSIONS = length(model.SPM.Sess); % Will this ever be more than one? - PCS
contrast_number = str2num(contrast_number);

assert(NUMBER_OF_SESSIONS == 1, 'This script is currently not able to handle more than one run')
session_index = 1;

PPI=[];
voiname_org=VOI_name;

% load generated VOI extrcation
VOI_name=strcat('VOI_', VOI_name,'_1.mat');
VOI=load(fullfile(model_dir, VOI_name));

%-----------END OF VOI ----------------

[TASK_NAME TASK_AND_CONTRAST]=get_ppi_task_matrix(spmmat, contrast_number, NUMBER_OF_SESSIONS);
% For each run calculate the three columns 1) psychological (onset times of task contrasts) 2) physiological (deconvolved time course) 3) interaction of 1 and 2 used in design matrix of PPI analysis
PPI= [ PPI spm_peb_ppi(spmmat, 'ppi' , VOI.xY, TASK_AND_CONTRAST, VOI_name, 0)];

scans_per_session=length(cellstr(model.SPM.xY.P))/NUMBER_OF_SESSIONS;

VOI_name = voiname_org;


% MODEL SPECIFICATION
%=====================================================================
% Set up the stats model using a combination of the new information
% from the PPI as well as information from the original first level GLM
%---------------------------------------------------------------------

f=cellstr(model.SPM.xY.P);
jobs{1}.stats{1}.fmri_spec.sess(session_index).scans = f( ((session_index-1) * scans_per_session +1 ) : (session_index * scans_per_session)   );  %only input appropriate session
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(1).name = 'PPI-interaction';
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(1).val  = PPI(session_index).ppi;
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(2).name = 'Signal (BOLD)';
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(2).val  = PPI(session_index).Y;
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(3).name = 'Task';
jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(3).val  = PPI(session_index).P;
jobs{1}.stats{1}.fmri_spec.sess(session_index).hpf = 128;

%Get number of task conditions
num_cond = size(model.SPM.Sess(session_index).U, 2);
conditions_from_contrast = TASK_AND_CONTRAST(:, 1)';

%Pull these conditions as regressors
other_events = setdiff([1:num_cond], conditions_from_contrast);

%Will need to fix this with multiple runs
other_task_regressors = model.SPM.xX.X(:, other_events);

regressors=[other_task_regressors, model.SPM.Sess(session_index).C.C]; %these are the nuisance regressors used in the original PPI analysis
[r c ] = size(regressors);

%transfer over the nuisance regressors used from the original
%first level GLM into the the new ppi analysis
for i = 1 : c
    jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(3+i).name = strcat('Extra Regressor ',num2str(i));
    jobs{1}.stats{1}.fmri_spec.sess(session_index).regress(3+i).val  = regressors(:,i);
end

jobs{1}.stats{1}.fmri_spec.dir = cellstr(fullfile(ppi_dir));
jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
jobs{1}.stats{1}.fmri_spec.timing.RT = model.SPM.xY.RT;
jobs{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(ppi_dir,'SPM.mat'));
spm_jobman('run',jobs); %Run the PPI first level


set(gcf, 'PaperPositionMode', 'auto');
print(gcf, '-djpeg', '-r100',  fullfile(ppi_dir, 'DesignMatrix.jpg'))

% INFERENCE & RESULTS
% Creates contrasts for the new PPI first level model
%=====================================================================
clear jobs;

tcon_pos=[];
tcon_pos = [ tcon_pos 1 zeros(1,c+2) ];
tcon_pos = [tcon_pos zeros(1,NUMBER_OF_SESSIONS) ] ;
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(ppi_dir,'SPM.mat'));
jobs{1}.stats{1}.con.consess{1}.tcon.name = 'PPI-Interaction-Positive';
jobs{1}.stats{1}.con.consess{1}.tcon.convec = tcon_pos;
spm_jobman('run',jobs);

clear jobs;
tcon_neg = tcon_pos * -1;
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(ppi_dir,'SPM.mat'));
jobs{1}.stats{1}.con.consess{1}.tcon.name = 'PPI-Interaction-Negative';
jobs{1}.stats{1}.con.consess{1}.tcon.convec = tcon_neg;
spm_jobman('run',jobs);

cd(orig_dir)
