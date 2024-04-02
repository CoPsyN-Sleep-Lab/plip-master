#!/bin/bash

## This script will download files from OAK server to local computer and place them in the appropriate location within a local fmriprep project and local plip project to start the plip pipeline at 1st-level modeling (skipping plip preprocessing).
## ~~~ Overview ~~
## 1. Downloads fmriprep derivative files and html report from OAK and moves to local fmriprep project.
## 2. Moves the plip-relevant files (nii.gz's) to plip-locations, unzips to .nii and renames.
## 3. Cuts 3 dummy scans from task-series.
## 3. Creates onset.csv files for 1st level modeling from psychopy log files on the lab's Box. Copies these files to plip.
## 4. confounds_tsv2mat.py Makes nuisance regressors derived from fmriprep confounds.tsv files. Filters the full .tsv for the required nuisance regressors and appends motion_outlier columns (also adds the 1 before/2 after detected spikes), removes first 3 rows for dummy-scans, and converts to .mat file for use by plip [? may need to rename confounds or spike_regressors_wFD.mat or edit plip to expect different names.] To edit the nuisance regressors for 1stlevels, edit or create-new nuisance_params_XX.txt contained within "<local_pliproot_dir>/plipify_fmriprep/"

## Updates 21-March-2-024
## Makes files required for intrinsic connectivity modeling, and places in relevant plip directories.

#-------------------------------------------------------------------------------------------
## User Inputs
Project_name="TIRED"
subject="TIRED022"
local_plipproject_dir="/Users/copsynsleeplab/Desktop/TIRED-plip/"
local_fmriprep_dir="/Users/copsynsleeplab/Desktop/fmriprep-22.1.1/"
local_pliproot_dir="/Users/copsynsleeplab/plip-master/"
MATLAB_DIR=/Applications/MATLAB_R2022b.app/bin


## nuisance_params_XX.txt contains the list of confounds that will be filtered from the *_confounds.tsv file produced by fmriprep and placed into a .mat file for use by plip in nuisance-regression in 1st-level models. The number in the filename refers to the number of regressors, excluding the motion_outliers_xx columns for spikes.
## To change the nuisance_params, create a new txt file with the labels of the confounds that you want to include.
nuisance_params="$local_pliproot_dir/plipify_fmriprep/nuisance_params_14.txt"

#-------------------------------------------------------------------------------------------
## To do:
#### 1. make batch version of script
#### 2. First-level modeling for emoreg task.


#-------------------------------------------------------------------------------------------
## copy <remote_fmriprep_output> to <local_fmriprep_dir>
## [ Warning -- Only downloading minimally-necessary files for plip.]
mkdir -p "${local_fmriprep_dir}/sub-${subject}/anat/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/figures/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-BL/anat/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-ETX/anat/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/"
mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"

## reports -- this requires 2factor authentication for now.
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}.html" ${local_fmriprep_dir}
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/figures/*" "${local_fmriprep_dir}/sub-${subject}/figures/"
## Raw anat
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/sub-${subject}/ses-BL/anat/sub-${subject}_ses-BL_T1w.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/anat/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/sub-${subject}/ses-ETX/anat/sub-${subject}_ses-ETX_T1w.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/anat/"
## Preprocessed Tasks
#### Con2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-con2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### Noncon2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-noncon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-noncon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### gonogo2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-gonogo2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-gonogo2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### emocon2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emocon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emocon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### emoreg
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emoreg_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emoreg_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
## Confound Files
#### Con2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-"${subject}"_ses-BL_task-con2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-"${subject}"_ses-ETX_task-con2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### Noncon2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-"${subject}"_ses-BL_task-noncon2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-"${subject}"_ses-ETX_task-noncon2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### gonogo2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-"${subject}"_ses-BL_task-gonogo2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-"${subject}"_ses-ETX_task-gonogo2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### emocon2
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-"${subject}"_ses-BL_task-emocon2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emocon2_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"
#### emoreg
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-BL/func/sub-"${subject}"_ses-BL_task-emoreg_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"
scp -r adamkra@login.sherlock.stanford.edu:"/oak/stanford/groups/agoldpie/TIRED/derivatives/fmriprep-22.1.1/sub-${subject}/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emoreg_desc-confounds_timeseries.tsv" "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"

#-------------------------------------------------------------------------------------------
## make new plip subject folders
cp -rv "${local_plipproject_dir}/NEW-PLIP-SUBJECT-TEMPLATE/BL_NEWSUBJECT" "${local_plipproject_dir}/processed/BL/"
mv "${local_plipproject_dir}/processed/BL/BL_NEWSUBJECT" "${local_plipproject_dir}/processed/BL/$subject"
cp -rv "${local_plipproject_dir}/NEW-PLIP-SUBJECT-TEMPLATE/ETX_NEWSUBJECT" "${local_plipproject_dir}/processed/ETX/"
mv "${local_plipproject_dir}/processed/ETX/ETX_NEWSUBJECT" "${local_plipproject_dir}/processed/ETX/$subject"

## Move and rename relevant images to TIRED-plip and use fslroi to remove the 3 dummy scans
## anat
mkdir -p "${local_plipproject_dir}/raw/BL/${subject}/T1w_1mm/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/anat/sub-${subject}_ses-BL_T1w.nii.gz" "${local_plipproject_dir}/raw/BL/${subject}/T1w_1mm/"
gunzip -q "${local_plipproject_dir}/raw/BL/${subject}/T1w_1mm/sub-${subject}_ses-BL_T1w.nii.gz"
mkdir -p "${local_plipproject_dir}/raw/ETX/${subject}/T1w_1mm/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/anat/sub-${subject}_ses-ETX_T1w.nii.gz" "${local_plipproject_dir}/raw/ETX/${subject}/T1w_1mm/"
gunzip -q "${local_plipproject_dir}/raw/ETX/${subject}/T1w_1mm/sub-${subject}_ses-ETX_T1w.nii.gz"


## Faces Conscious Task
#### BL-con
BL_con_fmriprep="${local_fmriprep_dir}/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
BL_con_plip_connectivity="$local_plipproject_dir/processed/BL/${subject}/func/conscious/connectivity/"
BL_con_plip_modeling="$local_plipproject_dir/processed/BL/${subject}/func/conscious/connectivity/modeling/"

cp $BL_con_fmriprep $BL_con_plip_connectivity
cp $BL_con_fmriprep $BL_con_plip_modeling
mv "$BL_con_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_con_plip_connectivity/05b_smooth.nii.gz"
mv "$BL_con_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_con_plip_modeling/05b_smooth.nii.gz"
fslroi "$BL_con_plip_connectivity/05b_smooth.nii.gz" "$BL_con_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$BL_con_plip_modeling/05b_smooth.nii.gz" "$BL_con_plip_modeling/05b_smooth.nii.gz" 3 -1

#### ETX-con
ETX_con_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-con2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
ETX_con_plip_connectivity="$local_plipproject_dir/processed/ETX/${subject}/func/conscious/connectivity/"
ETX_con_plip_modeling="$local_plipproject_dir/processed/ETX/${subject}/func/conscious/connectivity/modeling/"

cp $ETX_con_fmriprep $ETX_con_plip_connectivity
cp $ETX_con_fmriprep $ETX_con_plip_modeling
mv "$ETX_con_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_con_plip_connectivity/05b_smooth.nii.gz"
mv "$ETX_con_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_con_plip_modeling/05b_smooth.nii.gz"
fslroi "$ETX_con_plip_connectivity/05b_smooth.nii.gz" "$ETX_con_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$ETX_con_plip_modeling/05b_smooth.nii.gz" "$ETX_con_plip_modeling/05b_smooth.nii.gz" 3 -1

## Faces Nonconscious Task
#### BL-noncon
BL_noncon_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-noncon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
BL_noncon_plip_connectivity="$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/connectivity/"
BL_noncon_plip_modeling="$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/connectivity/modeling/"

cp $BL_noncon_fmriprep $BL_noncon_plip_connectivity
cp $BL_noncon_fmriprep $BL_noncon_plip_modeling
mv "$BL_noncon_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_noncon_plip_connectivity/05b_smooth.nii.gz"
mv "$BL_noncon_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_noncon_plip_modeling/05b_smooth.nii.gz"
fslroi "$BL_noncon_plip_connectivity/05b_smooth.nii.gz" "$BL_noncon_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$BL_noncon_plip_modeling/05b_smooth.nii.gz" "$BL_noncon_plip_modeling/05b_smooth.nii.gz" 3 -1

#### ETX-noncon
ETX_noncon_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-noncon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
ETX_noncon_plip_connectivity="$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/connectivity/"
ETX_noncon_plip_modeling="$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/connectivity/modeling/"

cp $ETX_noncon_fmriprep $ETX_noncon_plip_connectivity
cp $ETX_noncon_fmriprep $ETX_noncon_plip_modeling
mv "$ETX_noncon_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_noncon_plip_connectivity/05b_smooth.nii.gz"
mv "$ETX_noncon_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_noncon_plip_modeling/05b_smooth.nii.gz"
fslroi "$ETX_noncon_plip_connectivity/05b_smooth.nii.gz" "$ETX_noncon_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$ETX_noncon_plip_modeling/05b_smooth.nii.gz" "$ETX_noncon_plip_modeling/05b_smooth.nii.gz" 3 -1

## GonoGo Task
#### BL-gonogo
BL_gng_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-gonogo2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
BL_gng_plip_connectivity="$local_plipproject_dir/processed/BL/${subject}/func/gonogo/connectivity/"
BL_gng_plip_modeling="$local_plipproject_dir/processed/BL/${subject}/func/gonogo/connectivity/modeling/"

cp $BL_gng_fmriprep $BL_gng_plip_connectivity
cp $BL_gng_fmriprep $BL_gng_plip_modeling
mv "$BL_gng_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_gng_plip_connectivity/05b_smooth.nii.gz"
mv "$BL_gng_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_gng_plip_modeling/05b_smooth.nii.gz"
fslroi "$BL_gng_plip_connectivity/05b_smooth.nii.gz" "$BL_gng_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$BL_gng_plip_modeling/05b_smooth.nii.gz" "$BL_gng_plip_modeling/05b_smooth.nii.gz" 3 -1

#### ETX-gonogo
ETX_gng_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-gonogo2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
ETX_gng_plip_connectivity="$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/connectivity/"
ETX_gng_plip_modeling="$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/connectivity/modeling/"

cp $ETX_gng_fmriprep $ETX_gng_plip_connectivity
cp $ETX_gng_fmriprep $ETX_gng_plip_modeling
mv "$ETX_gng_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_gng_plip_connectivity/05b_smooth.nii.gz"
mv "$ETX_gng_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_gng_plip_modeling/05b_smooth.nii.gz"
fslroi "$ETX_gng_plip_connectivity/05b_smooth.nii.gz" "$ETX_gng_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$ETX_gng_plip_modeling/05b_smooth.nii.gz" "$ETX_gng_plip_modeling/05b_smooth.nii.gz" 3 -1

# ## Emoreg Task
# #### BL-emoreg
BL_emoreg_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emoreg_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
BL_emoreg_plip_connectivity="$local_plipproject_dir/processed/BL/${subject}/func/emoreg/connectivity/"
BL_emoreg_plip_modeling="$local_plipproject_dir/processed/BL/${subject}/func/emoreg/connectivity/modeling/"

cp $BL_emoreg_fmriprep $BL_emoreg_plip_connectivity
cp $BL_emoreg_fmriprep $BL_emoreg_plip_modeling
mv "$BL_emoreg_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_emoreg_plip_connectivity/05b_smooth.nii.gz"
mv "$BL_emoreg_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_emoreg_plip_modeling/05b_smooth.nii.gz"
fslroi "$BL_emoreg_plip_connectivity/05b_smooth.nii.gz" "$BL_emoreg_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$BL_emoreg_plip_modeling/05b_smooth.nii.gz" "$BL_emoreg_plip_modeling/05b_smooth.nii.gz" 3 -1

# #### ETX-emoreg
ETX_emoreg_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emoreg_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
ETX_emoreg_plip_connectivity="$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/connectivity/"
ETX_emoreg_plip_modeling="$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/connectivity/modeling/"

cp $ETX_emoreg_fmriprep $ETX_emoreg_plip_connectivity
cp $ETX_emoreg_fmriprep $ETX_emoreg_plip_modeling
mv "$ETX_emoreg_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_emoreg_plip_connectivity/05b_smooth.nii.gz"
mv "$ETX_emoreg_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_emoreg_plip_modeling/05b_smooth.nii.gz"
fslroi "$ETX_emoreg_plip_connectivity/05b_smooth.nii.gz" "$ETX_emoreg_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$ETX_emoreg_plip_modeling/05b_smooth.nii.gz" "$ETX_emoreg_plip_modeling/05b_smooth.nii.gz" 3 -1

# ## Emocon Task
# #### BL-emocon
BL_emocon_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emocon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
BL_emocon_plip_connectivity="$local_plipproject_dir/processed/BL/${subject}/func/emocon/connectivity/"
BL_emocon_plip_modeling="$local_plipproject_dir/processed/BL/${subject}/func/emocon/connectivity/modeling/"

cp $BL_emocon_fmriprep $BL_emocon_plip_connectivity
cp $BL_emocon_fmriprep $BL_emocon_plip_modeling
mv "$BL_emocon_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_emocon_plip_connectivity/05b_smooth.nii.gz"
mv "$BL_emocon_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$BL_emocon_plip_modeling/05b_smooth.nii.gz"
fslroi "$BL_emocon_plip_connectivity/05b_smooth.nii.gz" "$BL_emocon_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$BL_emocon_plip_modeling/05b_smooth.nii.gz" "$BL_emocon_plip_modeling/05b_smooth.nii.gz" 3 -1

# #### ETX-emocon
ETX_emocon_fmriprep="$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emocon2_space-MNI152NLin2009cAsym_res-2_desc-preproc_smoothed-6mm_bold.nii.gz"
ETX_emocon_plip_connectivity="$local_plipproject_dir/processed/ETX/${subject}/func/emocon/connectivity/"
ETX_emocon_plip_modeling="$local_plipproject_dir/processed/ETX/${subject}/func/emocon/connectivity/modeling/"

cp $ETX_emocon_fmriprep $ETX_emocon_plip_connectivity
cp $ETX_emocon_fmriprep $ETX_emocon_plip_modeling
mv "$ETX_emocon_plip_connectivity/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_emocon_plip_connectivity/05b_smooth.nii.gz"
mv "$ETX_emocon_plip_modeling/"*"preproc_smoothed-6mm_bold.nii.gz" "$ETX_emocon_plip_modeling/05b_smooth.nii.gz"
fslroi "$ETX_emocon_plip_connectivity/05b_smooth.nii.gz" "$ETX_emocon_plip_connectivity/05b_smooth.nii.gz" 3 -1
fslroi "$ETX_emocon_plip_modeling/05b_smooth.nii.gz" "$ETX_emocon_plip_modeling/05b_smooth.nii.gz" 3 -1

#-------------------------------------------------------------------------------------------
## unzip plip-relevant nii.gz's locally
file_paths=("$BL_con_plip_connectivity/05b_smooth.nii.gz"
	"$BL_con_plip_modeling/05b_smooth.nii.gz"
	"$ETX_con_plip_connectivity/05b_smooth.nii.gz"
	"$ETX_con_plip_modeling/05b_smooth.nii.gz"
	"$BL_noncon_plip_connectivity/05b_smooth.nii.gz"
	"$BL_noncon_plip_modeling/05b_smooth.nii.gz"
	"$ETX_noncon_plip_connectivity/05b_smooth.nii.gz"
	"$ETX_noncon_plip_modeling/05b_smooth.nii.gz"
	"$BL_gng_plip_connectivity/05b_smooth.nii.gz"
	"$BL_gng_plip_modeling/05b_smooth.nii.gz"
	"$ETX_gng_plip_connectivity/05b_smooth.nii.gz"
	"$ETX_gng_plip_modeling/05b_smooth.nii.gz"
	"$BL_emoreg_plip_connectivity/05b_smooth.nii.gz"
	"$BL_emoreg_plip_modeling/05b_smooth.nii.gz"
	"$ETX_emoreg_plip_connectivity/05b_smooth.nii.gz"
	"$ETX_emoreg_plip_modeling/05b_smooth.nii.gz"
	"$BL_emocon_plip_connectivity/05b_smooth.nii.gz"
	"$BL_emocon_plip_modeling/05b_smooth.nii.gz"
	"$ETX_emocon_plip_connectivity/05b_smooth.nii.gz"
	"$ETX_emocon_plip_modeling/05b_smooth.nii.gz"
	)

for file_path in "${file_paths[@]}"; do
    if [[ -e "$file_path" ]] && [[ $file_path == *.nii.gz ]]; then
    	echo "Unzipping ${file_path}"
        file_name="${file_path%.nii.gz}"
        gunzip -cq "$file_path" > "$file_name.nii" && rm -f "$file_path"
    else
    	echo "FILE DOES NOT EXIST: $file_path"
    fi
done

#-------------------------------------------------------------------------------------------
## Create and move onset files to plip directories

cd "/Users/copsynsleeplab/Desktop/code"
./psychopy_parser_helper_ajk.sh "$subject" "$local_fmriprep_dir"

## BL
mkdir -p "${local_plipproject_dir}/button/${subject}/BL/conscious/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/BL/nonconscious/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/BL/gonogo/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/BL/emoreg/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/BL/emocon/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/con2/"*.csv "${local_plipproject_dir}/button/${subject}/BL/conscious/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/noncon2/"*.csv "${local_plipproject_dir}/button/${subject}/BL/nonconscious/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/gonogo2/"*.csv "${local_plipproject_dir}/button/${subject}/BL/gonogo/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/emoreg/"*.csv "${local_plipproject_dir}/button/${subject}/BL/emoreg/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/beh/emotional_stroop/"*.csv "${local_plipproject_dir}/button/${subject}/BL/emocon/onsets/"

## ETX
mkdir -p "${local_plipproject_dir}/button/${subject}/ETX/conscious/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/ETX/nonconscious/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/ETX/gonogo/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/ETX/emoreg/onsets/"
mkdir -p "${local_plipproject_dir}/button/${subject}/ETX/emocon/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/con2/"*.csv "${local_plipproject_dir}/button/${subject}/ETX/conscious/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/noncon2/"*.csv "${local_plipproject_dir}/button/${subject}/ETX/nonconscious/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/gonogo2/"*.csv "${local_plipproject_dir}/button/${subject}/ETX/gonogo/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/emoreg/"*.csv "${local_plipproject_dir}/button/${subject}/ETX/emoreg/onsets/"
cp "${local_fmriprep_dir}/sub-${subject}/ses-ETX/beh/emotional_stroop/"*.csv "${local_plipproject_dir}/button/${subject}/ETX/emocon/onsets/"


#-------------------------------------------------------------------------------------------
## make denoising regressors -- these are derived from fmriprep output -- https://fmriprep.org/en/20.2.0/outputs.html#confounds
## this also strips the confounds_filtered.mat regressors of the first three dummy volumes
## two files produced here
## 1. The *confounds_filtered.mat file containing the time series of the nuisance regressors filtered from fmriprep output
## 2. A single txt file showing the total and percent volumes marked as outliers for 1st level regressors.

#### BL
######## Con
cd "${local_pliproot_dir}/plipify_fmriprep"
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-con2_desc-confounds_timeseries.tsv
if [ -f "$con_tsv" ]; then
	python confounds_tsv2mat.py "$con_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/sub-${subject}_ses-BL_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/conscious/connectivity/modeling/sub-${subject}_ses-BL_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"
fi

######## Noncon
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-noncon2_desc-confounds_timeseries.tsv
if [ -f "$noncon_tsv" ]; then
	python confounds_tsv2mat.py "$noncon_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/sub-${subject}_ses-BL_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/connectivity/modeling/sub-${subject}_ses-BL_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"
fi
######## Gonogo
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-gonogo2_desc-confounds_timeseries.tsv
if [ -f "$gng_tsv" ]; then
	python confounds_tsv2mat.py "$gng_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/sub-${subject}_ses-BL_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/connectivity/modeling/sub-${subject}_ses-BL_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/"
fi
######## emoreg
emoreg_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-emoreg_desc-confounds_timeseries.tsv
if [ -f "$emoreg_tsv" ]; then
	python confounds_tsv2mat.py "$emoreg_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/sub-${subject}_ses-BL_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/connectivity/modeling/sub-${subject}_ses-BL_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/"
fi
######## emocon
emocon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-emocon2_desc-confounds_timeseries.tsv
if [ -f "$emocon_tsv" ]; then
	python confounds_tsv2mat.py "$emocon_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/sub-${subject}_ses-BL_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/BL/${subject}/func/emocon/connectivity/modeling/sub-${subject}_ses-BL_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/"
fi

#### ETX
######## Con
cd "${local_pliproot_dir}/plipify_fmriprep"
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-con2_desc-confounds_timeseries.tsv
if [ -f "$con_tsv" ]; then
	python confounds_tsv2mat.py "$con_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/sub-${subject}_ses-ETX_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/connectivity/modeling/sub-${subject}_ses-ETX_task-con2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"
fi

######## Noncon
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-noncon2_desc-confounds_timeseries.tsv
if [ -f "$noncon_tsv" ]; then
	python confounds_tsv2mat.py "$noncon_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/sub-${subject}_ses-ETX_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/connectivity/modeling/sub-${subject}_ses-ETX_task-noncon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"
fi
######## Gonogo
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-gonogo2_desc-confounds_timeseries.tsv
if [ -f "$gng_tsv" ]; then
	python confounds_tsv2mat.py "$gng_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/sub-${subject}_ses-ETX_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/connectivity/modeling/sub-${subject}_ses-ETX_task-gonogo2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/"
fi
######## emoreg
emoreg_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emoreg_desc-confounds_timeseries.tsv
if [ -f "$emoreg_tsv" ]; then
	python confounds_tsv2mat.py "$emoreg_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/sub-${subject}_ses-ETX_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/connectivity/modeling/sub-${subject}_ses-ETX_task-emoreg_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/"
fi
####### emocon
emocon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emocon2_desc-confounds_timeseries.tsv
if [ -f "$emocon_tsv" ]; then
	python confounds_tsv2mat.py "$emocon_tsv" "$subject" "$nuisance_params"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/sub-${subject}_ses-ETX_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/confounds_filtered.mat"
	cp "$local_fmriprep_dir/sub-${subject}/ses-ETX/func/sub-${subject}_ses-ETX_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/connectivity/modeling/"
	mv "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/connectivity/modeling/sub-${subject}_ses-ETX_task-emocon2_desc-confounds_timeseries_filtered.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/connectivity/modeling/confounds_filtered.mat"
	mv "${local_pliproot_dir}/plipify_fmriprep/OutlierVolInfo_total"*.txt "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/"
fi

#-------------------------------------------------------------------------------------------
## make files required for intrinsic connectivity modeling
## 1. rp_01_reorient.csv -- creates csv file of 6 movement params [trans_x, trans_y, trans_Z, rot_x, rot_y, rot_z], extracted from fmriprep confounds files. Placed in plip preproc directory. 
## 2. spikes/outlier volumes -- creates .mat file (named spike_regressors_VAR1_1FD2.mat) containing array named 'spike_regressors)'

######## BL 
######## con task 
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-con_desc-confounds_timeseries.tsv
confounds_filtered_con="$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/confounds_filtered.mat"

if [ -f "$con_tsv" ] && [ -f "$confounds_filtered_con" ]; then
	python make_ic_regressors.py "$con_tsv" "$confounds_filtered_con"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"

######## noncon task 
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-noncon_desc-confounds_timeseries.tsv
confounds_filtered_noncon="$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/confounds_filtered.mat"

if [ -f "$noncon_tsv" ] && [ -f "$confounds_filtered_noncon" ]; then
	python make_ic_regressors.py "$noncon_tsv" "$confounds_filtered_noncon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"

######## gonogo task 
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-gonogo_desc-confounds_timeseries.tsv
confounds_filtered_gonogo="$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/confounds_filtered.mat"

if [ -f "$gng_tsv" ] && [ -f "$confounds_filtered_gonogo" ]; then
	python make_ic_regressors.py "$gonogo_tsv" "$confounds_filtered_gonogo"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/"

######## emoreg task 
emoreg_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-emoreg_desc-confounds_timeseries.tsv
confounds_filtered_emoreg="$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/confounds_filtered.mat"

if [ -f "$emoreg_tsv" ] && [ -f "$confounds_filtered_emoreg" ]; then
	python make_ic_regressors.py "$emoreg_tsv" "$confounds_filtered_emoreg"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emoreg/preproc/"

######## emocon task 
emocon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-emocon2_desc-confounds_timeseries.tsv
confounds_filtered_emocon="$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/confounds_filtered.mat"

if [ -f "$emocon_tsv" ] && [ -f "$confounds_filtered_emocon" ]; then
	python make_ic_regressors.py "$emocon_tsv" "$confounds_filtered_emocon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/emocon/preproc/"




######## ETX 
######## con task 
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-con_desc-confounds_timeseries.tsv
confounds_filtered_con="$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/confounds_filtered.mat"

if [ -f "$con_tsv" ] && [ -f "$confounds_filtered_con" ]; then
	python make_ic_regressors.py "$con_tsv" "$confounds_filtered_con"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"

######## noncon task 
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-noncon_desc-confounds_timeseries.tsv
confounds_filtered_noncon="$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/confounds_filtered.mat"

if [ -f "$noncon_tsv" ] && [ -f "$confounds_filtered_noncon" ]; then
	python make_ic_regressors.py "$noncon_tsv" "$confounds_filtered_noncon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"

######## gonogo task 
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-gonogo_desc-confounds_timeseries.tsv
confounds_filtered_gonogo="$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/confounds_filtered.mat"

if [ -f "$gng_tsv" ] && [ -f "$confounds_filtered_gonogo" ]; then
	python make_ic_regressors.py "$gonogo_tsv" "$confounds_filtered_gonogo"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/"

######## emoreg task 
emoreg_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emoreg_desc-confounds_timeseries.tsv
confounds_filtered_emoreg="$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/confounds_filtered.mat"

if [ -f "$emoreg_tsv" ] && [ -f "$confounds_filtered_emoreg" ]; then
	python make_ic_regressors.py "$emoreg_tsv" "$confounds_filtered_emoreg"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emoreg/preproc/"

######## emocon task 
emocon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-emocon2_desc-confounds_timeseries.tsv
confounds_filtered_emocon="$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/confounds_filtered.mat"

if [ -f "$emocon_tsv" ] && [ -f "$confounds_filtered_emocon" ]; then
	python make_ic_regressors.py "$emocon_tsv" "$confounds_filtered_emocon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/emocon/preproc/"



#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
## Miscellaneous / Unused
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
# ## Replicating plip nuisance regressors (spike_regressors_wFD.mat)
# ## Run TSDiffAna
# cd "${local_pliproot_dir}/plip/preproc/func/modular/"

# #### Con-BL
# preproc_dir="${local_plipproject_dir}/processed/BL/${subject}/func/conscious/preproc/"
# if [ -f "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_space-T1w_desc-preproc_bold.nii.gz" ]; then
# 	cp "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/sub-${subject}_ses-BL_task-con2_space-T1w_desc-preproc_bold.nii.gz" $preproc_dir
# 	gunzip "$preproc_dir/"*".nii.gz"
# 	realign_name="sub-${subject}_ses-BL_task-con2_space-T1w_desc-preproc_bold.nii"

# 	exec $MATLAB_DIR/matlab -nodisplay -nosplash -r "copsyn_pl_tsdiffana('$preproc_dir', '$realign_name'); end; quit;"
# fi


### Tsdiffana works, and left off on adapting the next script get_spikes_wMovement_Power.m, which should give us the spike_regressors_wFD.mat, but requires the rp.txt file from spm realignment. To do: edit the confounds_tsv2mat script so that it additionall creates a 6-column txt file with the realignment parameters, names it as plip wants, and makes it accessible to run_despiker_wMovementPower.m (should be in same directory where tsdiffana is run. /.../func/conscious/preproc).
## For the time being, we will bypass all plip-confounds generation. We can just use the motion_outliers_xx from fmriprep, and ammend it to do the 1 volume before / 2 after a spike censoring. Then just use the confounds_tsv2mat.py script to (re)generate confounds files from fmriprep if we want to try different regressors.
