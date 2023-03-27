#!/usr/bin/python3
"""
##Inputs
tasks
VOIs      - list of masks that were used to create VOIs (volumes of interest)
contrasts - list of contrasts within the first level connectivity analysis

##Outputs
This script loops over the VOIs and the contrasts calls two sub scripts in
order to create the first level PPI analysis.

make_VOI_spikesonly_FD_File_RAD
Creates VOIs using masks specified and saves the eignvariate of the time
course and the VOI data structure within the first level connectivity glm
folder created from the VOIs, and creates a first level GLM for the PPI
analysis with the
   1) psychological variable (task)
   2) physiological variable (deconvolved BOLD signal from VOI) and
   3) the interaction between the psychological and physiological
   variables

NOTE: probably only the contrast number is needed and the name can be
found in the SPM.mat file
"""
import sys
import logging
import pandas as pd
from pathlib import Path

import plip
import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.config_get import config_get
from plip.utils.run_matlab import run_matlab


def ppi_voi_glm(grey_dir, model_dir, ppi_dir, seed, contrast_num, config):
    """
    PL_ROI_PPI This function runs the ROI PPI analysis for a given seed and
    contrast. Thi ROI PPI analysis takes preprocessed images, a seed region, a
    task contrast, and runs a PPI analysis. We use spm_regions to create the
    PPI term and predict mean time courses in the regions defined by maskList.

    For each task Create VOI, deconvolve the bold signal in the VOI and
    generate the the first level PPI glm
    """

    # create eiganvariate and save as VOI_*.mat file in first level
    # connectivity GLM folder
    run_matlab(config, "pl_createVOI",
               grey_dir, model_dir, seed, contrast_num)

    # use VOIs from above to generate PPI GLM and contrasts
    run_matlab(config, "pl_runPPI",
               ppi_dir, model_dir, seed, contrast_num)


def roi_ppi(config_dir, session, subject):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    ppi_models = pd.read_csv(config_dir / "ppi_models.csv")

    plipos.subject_logger(root, session, subject, "ppi")
    log = logging.getLogger(f"ppi_{session}_{subject}")

    grey_dir = paths.grey_path(root, session, subject)

    for i, row in ppi_models.iterrows():
        task = row["task"]
        seed = row["seed"]
        contrast = row["contrast"]
        contrast_num = row["contrast_num"]

        connectivity_dir = paths.task_path(root, session, subject, task,
                                           "connectivity")
        model_dir = paths.model_path(connectivity_dir)
        ppi_dir = paths.ppi_path(root, session, subject, task, seed, contrast)

        if plip.ppi.prep.incomplete_inputs(model_dir):
            log.error(f"Incomplete PPI data for {task} {seed} {contrast}")
            continue
        if plip.ppi.prep.skip_ppi(model_dir, ppi_dir):
            log.info(f"Skipping {task} {seed} {contrast}")
            continue
        log.info(f"Setting up PPI for {task} {seed} {contrast}")
        plip.ppi.prep.setup_ppi(ppi_dir)
        log.info(f"Starting PPI for {ppi_dir}")
        ppi_voi_glm(grey_dir, model_dir, ppi_dir, seed, contrast_num, config)
        log.info(f"PPI complete for {task} {seed} {contrast}")


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    roi_ppi(config_dir, session, subject)
