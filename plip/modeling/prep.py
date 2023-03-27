#!/usr/bin/python3
import logging
import pandas as pd
from pathlib import Path
import plip.utils.paths as paths
import plip.utils.os as plipos
from plip.utils.config_get import config_get
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.definitions import PLIP_ROOT


def skip_model(config_dir, session, subject, task, rel_folder):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    folder = paths.task_path(root, session, subject, task, folder=rel_folder)
    model_dir = paths.model_path(folder)
    log = logging.getLogger(f"preproc_{session}_{subject}")

    # FIXME: get a better check
    if rel_folder == "activation" and list(model_dir.glob("mni_con*.nii")):
        log.info(f"Skipping {session} {subject} {task} {rel_folder} modeling")
        return True
    elif rel_folder != "activation" and list(model_dir.glob("con*.hdr")):
        log.info(f"Skipping {session} {subject} {task} {rel_folder} modeling")
        return True
    else:
        log.info(f"Restarting {session} {subject} {task} {rel_folder} "
                 "modeling")
        plipos.rmtree(model_dir)
        return False


def setup_model(config_dir, session, subject, task, rel_folder, filename):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    folder = paths.task_path(root, session, subject, task, folder=rel_folder)
    model_dir = paths.model_path(folder)

    log = logging.getLogger(f"preproc_{session}_{subject}")
    log.info(f"Prepping modeling for {session} {subject} {task} {rel_folder}")

    # fMRI image
    plipos.copy(folder / filename, model_dir / filename)

    # Regressors spikes
    task_dir = paths.task_path(root, session, subject, task)
    plipos.copy(
        task_dir / "preproc" / "spike_regressors_wFD.mat",
        model_dir / "spike_regressors_wFD.mat"
    )

    # Onsets
    transfer_onsets(root, session, subject, task, model_dir)

    # Mask
    anat_dir = paths.anat_path(root, session, subject)
    setup_mask(anat_dir, task_dir, model_dir, rel_folder)
    log.info(f"Modeling is prepped for {session} {subject} {task} "
             f"{rel_folder}")


def transfer_onsets(root, session, subject, task, model_dir):
    button_dir = paths.button_path(root, session, subject, task)
    onsets = list(button_dir.glob("*.csv"))
    for onset in onsets:
        plipos.copy(onset, model_dir / onset.name)
    if len(onsets):
        return

    avg_onsets_csv = root / "average_onsets.csv"
    if avg_onsets_csv.is_file():
        avg_onsets = pd.read_csv(avg_onsets_csv)
        avg_onsets = avg_onsets[(
            (avg_onsets["session"] == session) &
            (avg_onsets["subject"].astype(str) == subject) &
            (avg_onsets["task"] == task)
        )]
        assert len(avg_onsets) < 2, (f"Check {avg_onsets_csv} for duplicates "
                                     f"in {session} {subject} {task}")
        assert len(avg_onsets) != 0, (f"Found no onsets for {session} "
                                      f"{subject} {task} and avg onsets not "
                                      "speficied")
        # FIXME, put this path in paths.py
        avg_onsets_path = root / "button" / "average_onsets" / task
        assert avg_onsets_path.is_dir()
        onsets = avg_onsets_path.glob("*.csv")
        for onset in onsets:
            plipos.copy(onset, model_dir / onset.name)
        if len(onsets):
            return
        raise Exception("Onsets were not transferred")
    raise Exception(f"Onsets not found in {button_dir}")


def setup_mask(anat_dir, task_dir, model_dir, folder):
    dst = model_dir / "modeling_mask.nii"
    if folder == "activation":
        premat = task_dir / "data" / "highres2example_func.mat"
        fsl_in_docker("applywarp",
                      "-i", anat_dir / "struct" / "brain_fnirt_mask.nii",
                      "-r", task_dir / "data" / "example_func.nii",
                      "-o", dst,
                      f"--premat={premat}")
        fsl_in_docker("fslmaths", dst, "-thr", "1", dst)
        fsl_in_docker("fslmaths", dst, "-dilF", "-dilF", dst)
    elif folder == "connectivity":
        brain_mask = PLIP_ROOT / "data" / "mni_bet_1mm_mask.nii"
        plipos.copy(brain_mask, dst)
    else:
        raise Exception(f"Modeling of {folder} is not setup currently")
