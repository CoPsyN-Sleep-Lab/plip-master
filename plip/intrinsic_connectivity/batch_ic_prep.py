#!/usr/bin/python3
"""
The steps of intrinsic connectivity prep are:

1) First merges all of the smoothed, normalized, slice time corrected and
realigned files into a single file (all_tasks.nii)
2) get_wm_csf_gm_global_signals_FSL.m -- Runs segmentation analysis in FSL to
create time regressors for the white matter and CSF masks
3) Pulls regressors from the first level models to regress out task specific
events and saves together with wm and csf time courses in file: nuisance.txt
4) Confirms session length should be what is expected.
6) Regresses out the task and noise regressors and stores residuals in modeling
7) Residuals are merged into a 4d nifti file, filtered, and stored in
ResidualImages_Filt.nii

NOTE: This has more sig figures than the MATLAB version for some reason
"""
import os
import sys
import logging
from pathlib import Path

import plip.utils.os as plipos
import plip.utils.paths as paths
import plip.intrinsic_connectivity as ic
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.utils.run_matlab import run_matlab
from plip.utils.config_get import config_get


def filt(src, dst, TR):
    """
    Filter residualized time series data using the thresholds defined below.
    """
    HP_FREQ_CUTOFF_HZ = 0.009
    LP_FREQ_CUTOFF_HZ = 0.08
    variable = 2.355  # FIXME: what's a better name for this? - PCS

    HP_SIGMA_CUTOFF_SEC = 1.0 / HP_FREQ_CUTOFF_HZ
    HP_SIGMA_CUTOFF_VOL = (HP_SIGMA_CUTOFF_SEC / TR) / variable
    LP_SIGMA_CUTOFF_SEC = 1.0 / LP_FREQ_CUTOFF_HZ
    LP_SIGMA_CUTOFF_VOL = (LP_SIGMA_CUTOFF_SEC / TR) / variable

    fsl_in_docker(
        "fslmaths",
        src, "-bptf",
        str(HP_SIGMA_CUTOFF_VOL), str(LP_SIGMA_CUTOFF_VOL),
        dst, "-odt", "float"
    )


def merge_images(directory, regex, dst):
    """
    Merge all the residual images from 1st level models into one image.
    Remove all the residual images after to free space
    """
    src = directory.glob(regex)
    src = list(sorted(src))
    fsl_in_docker("fslmerge", "-t", dst, *src)
    for f in src:
        os.remove(f)
        os.remove(f.parent / f.name.replace(".img", ".hdr"))


def ic_est(ic_dir, filename, TR, config):
    """
    Runs SPM8 1st level modeling on the concatenated image.  The SPM_PROCESSING
    flag means the residual images are saved during modeling
    """

    # HACK: this is needed to not delete the residuals
    run_matlab(config, "ic_est", ic_dir, filename, TR,
               env={"SPM_PROCESSING": "intrinsic_connectivity"})


def generate_residual_image(ic_dir, filename, TR, config):
    """
    These are all the steps of intrinsic connectivity after all files are setup
    """
    ic_est(ic_dir, filename, TR, config)

    # Collapse from individual residual files to 4d nifti
    merge_images(ic_dir, "ResI_*.img", ic_dir / "ResidualImages.nii")

    filt(
        ic_dir / "ResidualImages.nii",
        ic_dir / "ResidualImages_Filt.nii",
        TR
    )


def ic_model(config_dir, session, subject):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    ic_tasks = config_get(config, "ic_tasks")

    ic_dir = paths.ic_path(root, session, subject)

    task_config = config_dir / "tasks.json"
    TR = {config_get(task_config, [task, "tr"]) for task in ic_tasks}.pop()

    generate_residual_image(ic_dir, "all_tasks.nii", TR, config)


def ic_prep(config_dir, session, subject):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")

    plipos.subject_logger(root, session, subject, "ic")
    log = logging.getLogger(f"ic_{session}_{subject}")

    if ic.prep.skip_ic(config_dir, session, subject):
        log.info("Skipping IC processing")
        return
    is_incomplete = ic.prep.incomplete_inputs(config_dir, session, subject)
    if is_incomplete:
        log.error(".  ".join(is_incomplete))
        return
    try:
        log.info("Setting up inputs and regressors for IC")
        ic.prep.setup_ic(config_dir, session, subject)
        log.info("Starting model for IC data")
        ic_model(config_dir, session, subject)
        log.info("IC processing complete")
    except Exception:
        log.exception("While processing IC")


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    ic_prep(config_dir, session, subject)
