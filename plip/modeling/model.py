#!/usr/bin/python3
import os
import sys
import logging
from pathlib import Path

import plip.utils.paths as paths
from plip.definitions import PLIP_ROOT
from plip.utils.run_matlab import run_matlab
from plip.utils.config_get import config_get
from plip.utils.fsl_in_docker import fsl_in_docker


def modeling(model_dir, task, filename, TR, config):
    jobfile = PLIP_ROOT / "modeling" / "tasks" / task / f"stats_{task}.m"
    # HACK: I think ,1 is needed for SPM
    brain_mask = model_dir / "modeling_mask.nii,1"
    run_matlab(config, "ppi_stats",
               jobfile, brain_mask, model_dir, filename, TR)

    jobfile = PLIP_ROOT / "modeling" / "estimate_job.m"
    run_matlab(config, "ppi_estimate", jobfile, model_dir)

    jobfile = PLIP_ROOT / "modeling" / "tasks" / task / f"contrasts_{task}.m"
    run_matlab(config, "ppi_contrast", jobfile, model_dir)


def convert_to_mni(task_dir, model_dir, anat_dir):
    anat_warp = anat_dir / "reg" / "highres2standard_warp"
    func_warp_mat = task_dir / "data" / "example_func2highres.mat"
    fsl_dir = Path(os.environ["FSLDIR"]) / "data" / "standard"
    for src in model_dir.glob("con*.hdr"):
        dst = src.parent / ("mni_" + src.name)
        fsl_in_docker("applywarp",
                      "-i", src,
                      "-w", anat_warp,
                      "--premat=%s" % func_warp_mat,
                      "-r", fsl_dir / "MNI152_T1_2mm_brain",
                      "-o", dst,
                      "-m", fsl_dir / "MNI152_T1_2mm_brain_mask_dil")


def run(config_dir, session, subject, task, rel_folder, filename):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    task_config = config_dir / "tasks.json"
    log = logging.getLogger(f"preproc_{session}_{subject}")

    root = config_get(config, "root")
    TR = config_get(task_config, [task, "tr"])
    task_dir = paths.task_path(root, session, subject, task)
    anat_dir = paths.anat_path(root, session, subject)

    model_dir = paths.model_path(
        paths.task_path(root, session, subject, task, folder=rel_folder)
    )

    log.info(f"Starting modeling for {session} {subject} {task} {rel_folder}")
    modeling(model_dir, task, filename, TR, config)
    log.info(f"Finished modeling for {session} {subject} {task} {rel_folder}")

    if rel_folder == "activation":
        log.info(f"Converting contrasts to MNI for {session} {subject} {task} "
                 f"{rel_folder}")
        convert_to_mni(task_dir, model_dir, anat_dir)
        log.info(f"Done converting to MNI for {session} {subject} {task} "
                 f"{rel_folder}")


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    task = args[3]
    filename = args[4]
    run(config_dir, session, subject, task, filename)
