function pl_createVOI(grey_dir, model_dir, VOI_name, contrast_number)
%This has been adapted from ....
% This batch script was addapted from the piplies used to analyize the Attention to Visual Motion fMRI dataset
% available from the SPM site using PPI:
% http://www.fil.ion.ucl.ac.uk/spm/data/attention/
% as described in the SPM manual:
%  http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf

% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin & Darren Gitelman
% $Id: ppi_spm_batch.m 17 2009-09-28 15:37:01Z guillaume $

% _%%Inputs
% VOI_name = name of mask to create VOIs (volumes of interest)
% contrast_number = contrast from the first level connectivity  analysis
%
% Variables used from SPM structures
% xSPM   - structure containing specific SPM, distribution & filtering details
% SPM    - structure containing generic analysis details
% hReg   - Handle of results section XYZ registry (see spm_results_ui.m)
%
% %% OUTPUTS
% Y and xY are saved in VOI_*.mat in the first level connectivity GLM direcotry
% Y      - first scaled eigenvariate of VOI {i.e. weighted mean}
% xY     - VOI structure
%

%%%%%%%%%%%%Assumes you're not making corrections for specific%%%%%%%%%%%%
%%%%%%%%%%%%Contrast will need to change to be contrast specic if not true%%%%%%%%%%%
% ^^ A bit unclear what this means - PCS

% Initialise SPM
%---------------------------------------------------------------------
spm('fmri');

contrast_number = str2num(contrast_number);
spmmat=fullfile(model_dir,'SPM.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOLUME OF INTERESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

voiname_org=VOI_name;

SPM = load(spmmat);
NUMBER_OF_SESSIONS  = length(SPM.SPM.Sess);

assert(NUMBER_OF_SESSIONS == 1, 'Script is not setup for more than 1 session')

VOI_session=1;
clear jobs

%Create the datastructure for the contrast
xSPM = struct('swd', model_dir,... %location of first level connectivity GLM
 'title', [],... %title will be filled in
 'Ic', contrast_number,... %con number found above
 'Im', [],... %Implict masking
 'u', 1,... %p value
 'k', 0,... %extent threshold
 'thresDesc', 'none'); %correction type

% EXTRACT THE EIGENVARIATE
%---------------------------------------------------------------------
model=load(spmmat); %load the SPM structure that was used in the first level model

%initialize the xSPM structure
[hReg,xSPM,SPM] = spm_results_ui('Setup',xSPM);

%Data structure for defining the mask that will be used to dump Eigenvariate
xY.name = VOI_name;
xY.Ic   = 0;
xY.Sess = 1;
xY.def  = 'mask';
xY.spec = fullfile(grey_dir, [VOI_name, '.nii']);

% this is what actually produces the time series extraction using the mask structure xY
% results are saved in VOI_*
[Y,xY]  = spm_regions(xSPM,model.SPM, hReg, xY); %Y is the eigenvariate of the time series for mask xY

