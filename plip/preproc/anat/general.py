#!/usr/bin/python3
"""
Create eroded version of CSF and white matter since spm white matter
mask includes brain stem will need to intersect with wm mask from aal
"""
import os
import logging
import numpy as np
from glob import glob
from pathlib import Path

import plip.utils.mri as mri
import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.utils.run_matlab import run_matlab
from plip.utils.config_get import config_get
from plip.definitions import PLIP_ROOT, mni_mask
from plip.definitions import fnirt_cfg1, fnirt_cfg2, fnirt_cfg3

FSLDIR = Path(os.environ["FSLDIR"])
mni_brain = FSLDIR / "data" / "standard" / "MNI152_T1_2mm_brain"


def fsl_normalization(anat_dir):
    fsl_in_docker("applywarp",
        "-i", anat_dir / "struct" / "brain.nii.gz",
        "-w", anat_dir / "reg" / "highres2standard_warp.nii.gz",
        "-r", FSLDIR / "data" / "standard/MNI152_T1_2mm_brain",
        "-o", anat_dir / "FSL_segmentation" / "wbrain.nii"
    )
    fsl_in_docker("applywarp",
        "-i", anat_dir / "struct" / "brain_mask.nii.gz",
        "-w", anat_dir / "reg" / "highres2standard_warp.nii.gz",
        "-r", FSLDIR / "data" / "standard/MNI152_T1_2mm_brain",
        "-o", anat_dir / "FSL_segmentation" / "wbrain_mask.nii"
    )
    fsl_in_docker("applywarp",
        "-i", anat_dir / "FSL_segmentation" / "wm_FSL_eroded.nii",
        "-w", anat_dir / "reg" / "highres2standard_warp.nii.gz",
        "-r", FSLDIR / "data" / "standard/MNI152_T1_2mm_brain",
        "-o", anat_dir / "FSL_segmentation" / "wwm_FSL_eroded_mask.nii"
    )
    fsl_in_docker("applywarp",
        "-i", anat_dir / "FSL_segmentation" / "csf_FSL_eroded.nii",
        "-w", anat_dir / "reg" / "highres2standard_warp.nii.gz",
        "-r", FSLDIR / "data" / "standard" / "MNI152_T1_2mm_brain",
        "-o", anat_dir / "FSL_segmentation" / "wcsf_FSL_eroded_mask.nii"
    )
    fsl_in_docker("applywarp",
        "-i", anat_dir / "FSL_segmentation" / "brain_pve_1.nii",
        "-w", anat_dir / "reg" / "highres2standard_warp.nii.gz",
        "-r", FSLDIR / "data" / "standard" / "MNI152_T1_2mm_brain",
        "-o", anat_dir / "FSL_segmentation" / "w_FSL_greymatter_mask.nii"
    )


def fix_probseg(anat_dir, config):
    for name, num in [("csf", 0), ("gm", 1), ("wm", 2)]:
        pve = anat_dir / "FSL_segmentation" / f"brain_pve_{num}.nii"
        dst = anat_dir / "FSL_segmentation" / f"{name}_FSL_eroded.nii"
        run_matlab(config, "fix_white_matter", pve, dst)  # What does this do?


def remove_brainstem_and_thalamus(anat_dir, config):
    """
    Intersect new wmmask with AAL white matter mask to remove brainstem and
    thalamus.
    What are the wwm_FSL_eroded_mask and AAL_wmMask images?
    """
    spm_wm_mask = anat_dir / "FSL_segmentation" / "wwm_FSL_eroded_mask.nii"
    aal_wm_mask = PLIP_ROOT / "data" / "AAL_wmMask.nii"
    dst = anat_dir / "FSL_segmentation" / "wwm_FSL_eroded_mask_fin.nii"

    data1  = mri.load_data(spm_wm_mask)
    data2  = mri.load_data(aal_wm_mask)
    new_data = np.logical_and(data1 >= 0.5, data2 >= 0.5)
    new_image = mri.create_image(data=new_data,
                                 like=mri.load_image(spm_wm_mask))
    mri.save_image(new_image, dst)


def bet(anat_dir):
    raw_T1      = anat_dir / "struct" / "orig.nii"
    brain       = anat_dir / "struct" / "brain.nii"
    brain_mask  = anat_dir / "struct" / "brain_mask.nii"
    cor_mat     = anat_dir / "struct" / "first_flirt_cort.mat"
    cor_inv_mat = anat_dir / "struct" / "first_flirt_cort_inv.mat"
    first_flirt = anat_dir / "struct" / "first_flirt.nii"

    # linear transformation of structural to MNI space
    command = f"first_flirt {raw_T1} {first_flirt} -cort"
    fsl_in_docker(*command.split(" "))

    command = f"convert_xfm -omat {cor_inv_mat} -inverse {cor_mat}"
    fsl_in_docker(*command.split(" "))

    # creates brain mask in subject space
    command = (f"flirt -in {mni_mask} -ref {raw_T1} -out {brain_mask} "
               f"-applyxfm -init {cor_inv_mat}")
    fsl_in_docker(*command.split(" "))

    # Actual BET step
    command = f"fslmaths {raw_T1} -mas {brain_mask} {brain}"
    fsl_in_docker(*command.split(" "))


def fnirt(anat_dir):
    fnirt_mask  = anat_dir / "struct" / "brain_fnirt_mask"
    brain_fnirt = anat_dir / "struct" / "brain_fnirt"
    s2h_warp    = anat_dir / "reg" / "standard2highres_warp"
    h2s_warp    = anat_dir / "reg" / "highres2standard_warp"
    h2s         = anat_dir / "reg" / "highres2standard"
    h2s_mat     = anat_dir / "reg" / "highres2standard.mat"
    brain       = anat_dir / "struct" / "brain"
    raw_T1      = anat_dir / "struct" / "orig"

    command = (f"flirt -ref {mni_brain} -in {brain} -out {h2s_warp} "
              f"-omat {h2s_mat} -cost corratio -dof 12 "
              "-searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp "
              "trilinear")
    fsl_in_docker(*command.split(" "))

    run_fnirt_fine(raw_T1, h2s_mat, h2s)

    command = f"invwarp -w {h2s_warp} -r {brain} -o {s2h_warp}"
    fsl_in_docker(*command.split(" "))

    command = (f"applywarp -i {mni_mask} -w {s2h_warp} -r {raw_T1} -o {fnirt_mask} -d float")
    fsl_in_docker(*command.split(" "))

    command = f"fslmaths {fnirt_mask} -thr 0.0 -bin {fnirt_mask} -odt short"
    fsl_in_docker(*command.split(" "))

    # subject space but brain extracted using mask
    command = f"fslmaths {raw_T1} -mas {fnirt_mask} {brain_fnirt}"
    fsl_in_docker(*command.split(" "))


def run_fnirt_fine(src, mat, out):
    """
    Runs fnirt x3 to warp T1 into MNI space output
    T1 image is highres2standard_warped
    """
    ref = FSLDIR / "data" / "standard" / "MNI152_T1_2mm"
    command1 = (f"fnirt --in={src} --ref={ref} --config={fnirt_cfg1} "
                f"--aff={mat} --cout={out}_warp1 --intout={out}_intensities "
                f"--iout={out}_warped1")
    command2 = (f"fnirt --in={src} --ref={ref} --config={fnirt_cfg2} "
                f"--inwarp={out}_warp1 --intin={out}_intensities "
                f"--cout={out}_warp2 --iout={out}_warped2")
    command3 = (f"fnirt --in={src} --ref={ref} --config={fnirt_cfg3} "
                f"--inwarp={out}_warp2 --intin={out}_intensities "
                f"--cout={out}_warp3 --iout={out}_warped3")
    for command in [command1, command2, command3]:
        fsl_in_docker(*command.split(" "))
    warp = glob(f"{out}_warp3*").pop()
    warped = glob(f"{out}_warped3*").pop()
    plipos.copy(warp,   f"{out}_warp.nii", overwrite=True)
    plipos.copy(warped, f"{out}_warped.nii", overwrite=True)


def fast(anat_dir):
    src = anat_dir / "struct" / "brain.nii"
    dst = anat_dir / "FSL_segmentation" / "brain.nii"
    plipos.copy(src, dst)
    fsl_in_docker("fast", dst)


def run(config_dir, session, subject):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")

    anat_dir = paths.anat_path(root, session, subject)
    log = logging.getLogger(f"preproc_{session}_{subject}")

    log.info("Starting anat bet")
    bet(anat_dir)
    log.info("Starting anat fnirt")
    fnirt(anat_dir)
    log.info("Running fast segmentation")
    fast(anat_dir)
    log.info("Fixing anat probseg")
    fix_probseg(anat_dir, config)
    log.info("Anat normalization")
    fsl_normalization(anat_dir)
    log.info("Removing brainstem and thalamus")
    remove_brainstem_and_thalamus(anat_dir, config)


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    run(config_dir, session, subject)
