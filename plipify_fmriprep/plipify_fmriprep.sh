#!/bin/bash

## This script will download files from OAK server to local computer and place them in the appropriate location within a local plip project to start the plip pipeline at 1st-level modeling (skipping plip preprocessing).


## User Inputs
Project_name="TIRED"
subject="TIRED022"
local_plipproject_dir="/Users/adamkrause/TIRED-plip/"



## BL
## copy <file> to local_plipproject_dir/<location>
## This file is for ... (e.g. 1st level modeling; separate preprocessing for PPI connectivity)

# anatomical T1w_1mm (preprocessed/normalized-MNI)
scp adamkra@login.sherlock.stanford.edu:/oak/stanford/groups/agoldpie/${Project_name}/derivatives/fmriprep-22.1.1/sub-${subject}/anat/sub-${subject}_space-MNI152NLin2009cAsym_res-2_desc-preproc_T1w.nii.gz local_foo













## ETX



## unzip nii.gz's locally
