#!/usr/bin/python3
import logging
from pathlib import Path
import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.config_get import config_get
from plip.utils.fsl_commands import fsl_command


def skip_anat(config_dir, session, subject):
    log = logging.getLogger(f"preproc_{session}_{subject}")
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    anat_dir = paths.anat_path(root, session, subject)

    skip = True
    for f1, f2 in [
        ("FSL_segmentation", "brain_pveseg.nii"),
        ("FSL_segmentation", "wwm_FSL_eroded_mask_fin.nii")
    ]:
        if not (anat_dir / f1 / f2).is_file():
            skip = False
    if skip:
        log.info(f"Skipping anat {session} {subject}")
    else:
        log.info(f"Restarting anat {session} {subject}")
        plipos.rmtree(anat_dir)
    return skip


def setup_anat(config_dir, session, subject):

    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    t1_type = config_get(config, "t1_type")
    anat_dir = paths.anat_path(root, session, subject)


    #debug_log = logging.getLogger(f"DEBUGpreproc_{session}_{subject}")
    #debug_log.info(f"The anat_dir is {anat_dir}")

    src = paths.raw_anat_path(root, session, subject, t1_type)


    dst = anat_dir / "raw" / src.name
    for folder in ["FSL_segmentation", "raw", "reg", "struct"]:
        plipos.makedirs(anat_dir / folder)
    plipos.copy(src, dst)

    # Reorient to match MNI image layout
    orig = anat_dir / "struct" / "orig.nii"
    log.info(f"Reorienting {dst} to {orig}")
    fsl_command('fslreorient2std', dst, orig)
    return src
