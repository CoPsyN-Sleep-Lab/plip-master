There are two pipelines for PLIP preprocessing which will be referred to as the "activation" and "connectivity" pipelines

The activation pipeline has an `a` suffix and the connectivity pipeline has a `b` suffix.  Following the numbers indicate the processes applied.  So if a `03b_slice_time_correction.nii` and `04b_warp.nii` file exist, that means an `applywarp` command was applied to the `03b_slice_time_correction.nii` image which in turn had slice time correction applied to a `02*` image
