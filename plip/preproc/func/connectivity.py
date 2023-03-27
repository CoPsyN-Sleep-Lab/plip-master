#!/usr/bin/python3
import os
import logging
import pandas as pd
from pathlib import Path

import plip.utils.os as plipos
from plip.definitions import (PLIP_ROOT, realign_path, st_path, warp_path,
                              smooth_path_b)
from plip.utils.fsl_commands import fsl_warp
from plip.utils.run_matlab import run_matlab
import plip.utils.paths as paths
from plip.utils.config_get import config_get


def slice_timing(realign_path, st_path, TR, order, is_mb, config):
    # Generally anything less than 2 sec shouldn't undergo slice time
    # correction
    if is_mb:
        plipos.copy(realign_path, st_path)
    else:
        tmp_path = st_path.parent / realign_path.name
        plipos.copy(realign_path, tmp_path)

        run_matlab(config, "pl_slice_timing",
                   tmp_path.parent, realign_path.name, TR, order)
        plipos.mv(tmp_path.parent / ("a" + tmp_path.name), st_path)
        os.remove(tmp_path)


def func_connectivity(directory_info, TR, order, is_mb, smooth_param, config):
    task_dir = directory_info["task_dir"]
    con_dir = directory_info["con_dir"]
    FSLDIR = directory_info["FSLDIR"]
    anat_dir = directory_info["anat_dir"]

    slice_timing(Path(str(realign_path).format(task_dir=task_dir)),
                 Path(str(st_path).format(task_dir=task_dir)),
                 TR, order, is_mb, config)
    fsl_warp(directory_info, **{
        "i": str(st_path).format(task_dir=task_dir),
        "w": anat_dir / "reg" / "highres2standard_warp",
        "premat": task_dir / "data" / "example_func2highres.mat",
        "r": FSLDIR / "data" / "standard" / "MNI152_T1_2mm_brain",
        "o": str(warp_path).format(task_dir=task_dir),
        "m": FSLDIR / "data" / "standard" / "MNI152_T1_2mm_brain_mask_dil",
    })
    run_matlab(config, "pl_smooth", con_dir, warp_path.name, smooth_param)
    plipos.mv(
        con_dir / ("s" + warp_path.name),
        Path(str(smooth_path_b).format(task_dir=task_dir))
    )


def get_slice_order(root, session, subject, task):
    slice_time_csv = Path(root) / "slice_timing.csv"
    df = pd.read_csv(slice_time_csv)
    order = df.loc[(
        (df["session"] == session) &
        (df["subject"].astype(str) == subject) &
        (df["task"] == task)
    )]
    assert len(order) == 1, f"Improper slice timing for {subject} {task}"
    return order["order"].iloc[0]


def run(config_dir, session, subject, task):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    task_config = config_dir / "tasks.json"

    root = config_get(config, "root")
    smooth_param = str(config_get(config, "smooth_param"))
    TR = config_get(task_config, [task, "tr"])
    is_mb = config_get(task_config, [task, "is_mb"])
    order = get_slice_order(root, session, subject, task)

    log = logging.getLogger(f"preproc_{session}_{subject}")
    directory_info = {
        "FSLDIR": Path(os.environ["FSLDIR"]),
        "anat_dir": paths.anat_path(root, session, subject),
        "task_dir": paths.task_path(root, session, subject, task),
        "con_dir": paths.task_path(root, session, subject, task,
                                   folder="connectivity"),
        "PLIP_ROOT": PLIP_ROOT,
    }
    func_connectivity(directory_info, TR, order, is_mb, smooth_param, config)
    log.info(f"Connectivity pipeline for {task} complete")


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config = args[0]
    session = args[1]
    subject = args[2]
    task = args[3]
    run(config, session, subject, task)
