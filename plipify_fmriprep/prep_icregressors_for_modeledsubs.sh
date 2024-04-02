#!/bin/bash

Project_name="TIRED"
subject="TIRED321"
local_plipproject_dir="/Users/copsynsleeplab/Desktop/TIRED-plip/"
local_fmriprep_dir="/Users/copsynsleeplab/Desktop/fmriprep-22.1.1/"
local_pliproot_dir="/Users/copsynsleeplab/plip-master/"
MATLAB_DIR="/Applications/MATLAB_R2022b.app/bin"


mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-BL/func/"

mkdir -p "${local_fmriprep_dir}/sub-${subject}/ses-ETX/func/"


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


######## BL 
######## con task 
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-con2_desc-confounds_timeseries.tsv
confounds_filtered_con="$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/confounds_filtered.mat"

if [ -f "$con_tsv" ] && [ -f "$confounds_filtered_con" ]; then
	python make_ic_regressors.py "$con_tsv" "$confounds_filtered_con"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/conscious/preproc/"

######## noncon task 
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-noncon2_desc-confounds_timeseries.tsv
confounds_filtered_noncon="$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/confounds_filtered.mat"

if [ -f "$noncon_tsv" ] && [ -f "$confounds_filtered_noncon" ]; then
	python make_ic_regressors.py "$noncon_tsv" "$confounds_filtered_noncon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/BL/${subject}/func/nonconscious/preproc/"

######## gonogo task 
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-BL/func/sub-"${subject}"_ses-BL_task-gonogo2_desc-confounds_timeseries.tsv
confounds_filtered_gonogo="$local_plipproject_dir/processed/BL/${subject}/func/gonogo/preproc/confounds_filtered.mat"

if [ -f "$gng_tsv" ] && [ -f "$confounds_filtered_gonogo" ]; then
	python make_ic_regressors.py "$gng_tsv" "$confounds_filtered_gonogo"
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
con_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-con2_desc-confounds_timeseries.tsv
confounds_filtered_con="$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/confounds_filtered.mat"

if [ -f "$con_tsv" ] && [ -f "$confounds_filtered_con" ]; then
	python make_ic_regressors.py "$con_tsv" "$confounds_filtered_con"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/conscious/preproc/"

######## noncon task 
noncon_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-noncon2_desc-confounds_timeseries.tsv
confounds_filtered_noncon="$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/confounds_filtered.mat"

if [ -f "$noncon_tsv" ] && [ -f "$confounds_filtered_noncon" ]; then
	python make_ic_regressors.py "$noncon_tsv" "$confounds_filtered_noncon"
fi

mv "rp_01_reorient.csv" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"
mv "spike_regressors_VAR1_1FD2.mat" "$local_plipproject_dir/processed/ETX/${subject}/func/nonconscious/preproc/"

######## gonogo task 
gng_tsv="${local_fmriprep_dir}"/sub-"${subject}"/ses-ETX/func/sub-"${subject}"_ses-ETX_task-gonogo2_desc-confounds_timeseries.tsv
confounds_filtered_gonogo="$local_plipproject_dir/processed/ETX/${subject}/func/gonogo/preproc/confounds_filtered.mat"

if [ -f "$gng_tsv" ] && [ -f "$confounds_filtered_gonogo" ]; then
	python make_ic_regressors.py "$gng_tsv" "$confounds_filtered_gonogo"
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