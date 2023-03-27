#!/usr/bin/python3
import os
import logging
import pandas as pd
from pathlib import Path

import plip.utils.os as plipos
from plip.definitions import (PLIP_ROOT, realign_path, bet_path, global_path,
                              smooth_path_a)
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.utils.fsl_commands import fsl_command, fsl_warp
from plip.utils.run_matlab import run_matlab
import plip.utils.paths as paths
from plip.utils.config_get import config_get


def global_signal_removal(task_dir, src, dst):
    # FIXME: I think I heard this isn't doing quite global signal removal
    mask = task_dir / "activation" / "wm_csf_mask"
    regressor_path = task_dir / "activation" / "global_signal_design.txt"

    # combined estimate "global signal" and columns of ones. This corresponds
    # to the methods used in Amit's original matlab script
    global_signal = fsl_command("fslstats", "-t", src, "-k", mask, "-M")
    global_signal = [float(sig) for sig in
                     global_signal.decode("ascii").split(" \n") if sig]
    global_signal = pd.DataFrame(global_signal, columns=["global_signal"])
    global_signal["weight"] = 1
    global_signal.to_csv(regressor_path, sep="\t", header=None, index=False)

    # perform regression and claculate output residual
    fsl_in_docker("fsl_glm",
                  "-i", src,
                  "-d", regressor_path,
                  "-o", task_dir / "activation" / "global_signal_betas",
                  f"--out_res={dst}")

    # add back the mean to the residual (was removed by the regression)
    fsl_in_docker("fslmaths", src, "-Tmean", "-add", dst, dst)


def warp_global_signal(directory_info):
    fsl_warp(directory_info, **{
        "i": Path("{PLIP_ROOT}") / "data" / "white_0.9_csf_0.5_mask.nii.gz",
        "r": Path("{task_dir}") / "data" / "example_func",
        "w": Path("{anat_dir}") / "reg" / "standard2highres_warp",
        "postmat": Path("{task_dir}") / "data" / "highres2example_func.mat",
        "o": Path("{task_dir}") / "activation" / "wm_csf_mask"
    })


def func_activation(directory_info, smooth_param, config):
    task_dir = directory_info["task_dir"]
    act_dir = directory_info["act_dir"]

    warp_global_signal(directory_info)  # is that what's actually going on?

    fsl_in_docker("fslmaths",
                  act_dir / "wm_csf_mask",
                  "-thr", "1", act_dir / "wm_csf_mask")
    fsl_in_docker("fslmaths",
                  str(realign_path).format(task_dir=task_dir),
                  "-mas", task_dir / "data" / "mask",
                  str(bet_path).format(task_dir=task_dir),
                  "-odt", "float")
    global_signal_removal(task_dir, str(bet_path).format(task_dir=task_dir),
                          str(global_path).format(task_dir=task_dir))

    run_matlab(config, "pl_smooth", act_dir, global_path.name, smooth_param)
    plipos.mv(act_dir / ("s" + global_path.name),
              str(smooth_path_a).format(task_dir=task_dir))


def run(config_dir, session, subject, task):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"

    root = config_get(config, "root")
    smooth_param = str(config_get(config, "smooth_param"))

    log = logging.getLogger(f"preproc_{session}_{subject}")
    directory_info = {
        "FSLDIR": os.environ["FSLDIR"],
        "task_dir": paths.task_path(root, session, subject, task),
        "anat_dir": paths.anat_path(root, session, subject),
        "act_dir": paths.task_path(root, session, subject, task,
                                   folder="activation"),
        "PLIP_ROOT": PLIP_ROOT,
    }
    func_activation(directory_info, smooth_param, config)
    log.info(f"Activation pipeline for {task} complete")


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    task = args[3]
    run(config_dir, session, subject, task)
