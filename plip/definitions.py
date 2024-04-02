from pathlib import Path
PLIP_ROOT = Path(__file__).absolute().parent

reorient_path = Path("{task_dir}") / "preproc" / "01_reorient.nii"
realign_path = Path("{task_dir}") / "preproc" / "02_realign_unwarp.nii"
# movement_path = Path("{task_dir}") / "preproc" / "rp_01_reorient.txt"

## AJK EDIT - making movement files into csv's derived from fmriprep output
movement_path = Path("{task_dir}") / "preproc" / "rp_01_reorient.csv"

spikes_path = Path("{task_dir}") / "preproc" / "spike_regressors_VAR1_1FD2.mat"

act_dir = Path("{task_dir}") / "activation"
bet_path = act_dir / "03a_bet.nii"
global_path = act_dir / "04a_global_signal_remove.nii"
smooth_path_a = act_dir / "05a_smooth.nii"

con_dir = Path("{task_dir}") / "connectivity"
st_path = con_dir / "03b_slice_time_correction.nii"
warp_path = con_dir / "04b_warp.nii"
#smooth_path_b = con_dir / "05b_smooth.nii" ## AJK EDIT for storage management / use 05b.nii in modeling folder
smooth_path_b = con_dir / "modeling/05b_smooth.nii"

anat_cfg_dir = Path(PLIP_ROOT) / "preproc" / "anat" / "config"
fnirt_cfg1 = anat_cfg_dir / "T1_2_MNI152_2mm.cnf"
fnirt_cfg2 = anat_cfg_dir / "T1_2_MNI152_level2.cnf"
fnirt_cfg3 = anat_cfg_dir / "T1_2_MNI152_level3.cnf"

mni_mask = Path(PLIP_ROOT) / "data" / "mni_bet_1mm_mask.nii"
