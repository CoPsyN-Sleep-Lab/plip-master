# Config

This folder contain the only files that you need to edit to run PLIP.  You may change these files without reinstalling PLIP on your machine.

For best practices, it's recommended this folder be stored in $root/processed

### `act_models.csv`

The activation models to run.  All masks are run over the task/contrast specified.  The filename can be found here `plip/modeling/tasks/$task/contrasts_$task.m` (you just need the number)

### `biotypes.json`

This file should only be changed after Dr. Leanne Williams approval

### `config.json`

**NOTE:** This is likely the only file that needs to be changed between runs

The variables should be self-explanatory, however a few notes on some of them

- `sessions`: multiple sessions are allowed just make sure the naming matches between `$root/raw`, `$root/buttons`, `$root/slice_timing.csv`, and `$root/average_onsets.csv`  
- `dof`: For the Biotypes Paper, a dof=6 flag is used.  There seems to be a slight improvement in output images using dof=12 however.  Individuals that don't review the sample `config.json` carefully, will cause the pipeline to break because the `dof` here does not equal that of `standardization` and they should be the same  
- `t1_type`: Multiple options are allowed here, for instance `["T1w_MPRAGE_PROMO", "T1w_1mm"]`.  If the first T1 pick isn't found, it looks for the second pick, and so on  
- `mask_dir`: This folder should contain all the names in `masks.txt` and end with ".nii"  

### `masks.txt`

The masks needed for any of the `act_models.csv`, `ppi_models.csv`, or `biotypes.json`.  Any masks are okay, they just need to be in `config.json`:`mask_dir` and be only 0s and 1s in data

### `ppi_models.csv`

The PPI models to run.  All masks are run over the task/contrast/seed specified.  The filename can be found here `plip/modeling/tasks/$task/contrasts_$task.m` (you just need the number)

### `tasks.json`

**NOTE:** Check this file over before processing.  The same task has a different TR or is multiband/singleband depending on the study (i.e. scanner)

This file specifies the task information:

- `volumes`: The number of useable volumes (after cutting non-steady-state)  
- `dummy_scans`: The number of non-steady-state scans to cut before preprocessing  
- `is_mb`: 0 for singleband and 1 for multiband.  Determines whether slice time correction should be used  
- `tr`: TR in seconds
- `onsets`: The onsets to be used in 1st level modeling and the number of expected  
