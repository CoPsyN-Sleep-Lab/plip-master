#!/usr/bin/python3
import logging
from pathlib import Path

import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.config_get import config_get
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.definitions import reorient_path


def setup_func(config_dir, session, subject, task):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    task_config = config_dir / "tasks.json"
    log = logging.getLogger(f"preproc_{session}_{subject}")

    root = config_get(config, "root")
    dummy_scans = config_get(task_config, [task, "dummy_scans"])
    task_dir = paths.task_path(root, session, subject, task)

    for folder in ["raw", "preproc", "data", "activation", "connectivity"]:
        plipos.makedirs(Path(task_dir) / folder)

    raw_task = paths.raw_task_path(root, session, subject, task)
    src = Path(task_dir) / "raw" / "00_raw.nii.gz"
    dst = str(reorient_path).format(task_dir=task_dir)

    cut_dummies(raw_task, src, dummy_scans)
    log.info(f"Cut {dummy_scans} dummies from {src}")
    fsl_in_docker("fslreorient2std", src, dst)
    log.info(f"Setup complete for {dst}")


def cut_dummies(with_dummy, dst, dummy_scans):
    if dummy_scans == 0:
        plipos.copy(with_dummy, dst)
    else:
        fsl_in_docker("fslroi", with_dummy, dst, dummy_scans, "-1")


def incomplete_inputs(config_dir, session, subject, task):
    pass


def skip_general(config_dir, session, subject, task):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    log = logging.getLogger(f"preproc_{session}_{subject}")
    task_dir = paths.task_path(root, session, subject, task)
    if (Path(task_dir) / "data" / "mask.nii").is_file():
        log.info(f"Skipping general preproc {session} {subject} {task}")
        return True
    elif incomplete_inputs(config_dir, session, subject, task):
        log.error(f"Missing needed files from {session} {subject} {task}")
        return True
    else:
        log.info(f"Starting general preproc {session} {subject} {task}")
        plipos.rmtree(task_dir)
        return False


def skip_activation(config_dir, session, subject, task):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    log = logging.getLogger(f"preproc_{session}_{subject}")
    act_dir = paths.task_path(root, session, subject, task,
                              folder="activation")
    if (Path(act_dir) / "05a_smooth.nii").is_file():
        log.info(f"Skipping activation preproc {session} {subject} {task}")
        return True
    else:
        plipos.rmtree(act_dir)
        plipos.makedirs(act_dir)
        log.info(f"Starting activation preproc {session} {subject} {task}")
        return False


def skip_connectivity(config_dir, session, subject, task):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    log = logging.getLogger(f"preproc_{session}_{subject}")
    con_dir = paths.task_path(root, session, subject, task,
                              folder="connectivity")
    if (Path(con_dir) / "05b_smooth.nii").is_file():
        log.info(f"Skipping connectivity preproc {session} {subject} {task}")
        return True
    else:
        plipos.rmtree(con_dir)
        plipos.makedirs(con_dir)
        log.info(f"Starting connectivity preproc {session} {subject} {task}")
        return False
