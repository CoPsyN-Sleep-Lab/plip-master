#!/usr/bin/python3
import os
import logging
from pathlib import Path

import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.config_get import config_get
from plip.utils.fsl_in_docker import fsl_in_docker
from plip.utils.run_matlab import run_matlab
from plip.utils.fsl_commands import fsl_command, fsl_warp
from plip.definitions import reorient_path, realign_path


def realign_unwarp(config, reorient_path, realign_path):
    run_matlab(config, "pl_realign_unwarp",
               reorient_path.parent, reorient_path.name)
    plipos.mv(
        reorient_path.parent / ("u" + reorient_path.name),
        realign_path
    )


def warp_prep(task_dir, anat_dir, dof):
    fsl_in_docker("flirt",
                  "-ref", anat_dir / "struct" / "brain_fnirt.nii.gz",
                  "-in", task_dir / "data" / "example_func",
                  "-dof", dof,
                  "-omat", task_dir / "data" / "example_func2highres.mat")
    fsl_in_docker("convert_xfm",
                  "-omat", task_dir / "data" / "highres2example_func.mat",
                  "-inverse", task_dir / "data" / "example_func2highres.mat")


def generate_mask(task_dir):
    fsl_in_docker("bet2",
                  task_dir / "preproc" / "meanu01_reorient.nii",
                  task_dir / "data" / "mask",
                  "-f", "0.3", "-n", "-m")
    plipos.mv(
        task_dir / "data" / "mask_mask.nii",
        task_dir / "data" / "mask.nii"
    )
    fsl_in_docker("fslmaths",
                  str(realign_path).format(task_dir=task_dir),
                  "-mas", task_dir / "data" / "mask",
                  task_dir / "preproc" / "prefiltered_func_data_bet")
    thresh = fsl_command("fslstats",
                         task_dir / "preproc" / "prefiltered_func_data_bet",
                         "-p", "2", "-p", "98")
    upper_thresh = thresh.decode("ascii").replace("\n", "")
    upper_thresh = float(upper_thresh.split(" ")[1]) * 0.1
    fsl_in_docker("fslmaths",
                  task_dir / "preproc" / "prefiltered_func_data_bet",
                  "-thr", upper_thresh, "-Tmin", "-bin",
                  task_dir / "data" / "mask",
                  "-odt", "char")
    fsl_in_docker("fslmaths",
                  task_dir / "data" / "mask",
                  "-dilF", task_dir / "data" / "mask")


def warp_func(directory_info):
    warp_params = {
        "i": Path("{task_dir}") / "data" / "example_func",
        "premat": Path("{task_dir}") / "data" / "example_func2highres.mat",
        "r": Path("{anat_dir}") / "struct" / "orig",
        "o": Path("{task_dir}") / "data" / "example_func2highres",
        "interp": "spline"
    }
    fsl_warp(directory_info, **warp_params)


def warp_snr(directory_info):
    fsl_data = Path("{FSLDIR}") / "data" / "standard"
    warp_params = {
        "i": Path("{task_dir}") / "preproc" / "snr.nii",
        "w": Path("{anat_dir}") / "reg" / "highres2standard_warp",
        "premat": Path("{task_dir}") / "data" / "example_func2highres.mat",
        "r": fsl_data / "MNI152_T1_2mm_brain",
        "o": Path("{task_dir}") / "preproc" / "warp_snr.nii",
        "m": fsl_data / "MNI152_T1_2mm_brain_mask_dil"
    }
    fsl_warp(directory_info, **warp_params)


def func_general(directory_info, config, dof, log):
    anat_dir = directory_info["anat_dir"]
    task_dir = directory_info["task_dir"]
    preproc_dir = directory_info["preproc_dir"]

    # Realignunwarp
    src = Path(str(reorient_path).format(task_dir=task_dir))
    dst = Path(str(realign_path).format(task_dir=task_dir))
    log.info(f"Running realign_unwarp on {src} {dst}")
    realign_unwarp(config, src, dst)

    # TS Diffana
    log.info(f"Running TS diffana on {dst}")
    run_matlab(config, "pl_tsdiffana", preproc_dir, realign_path.name)

    # what does this do?
    fsl_in_docker("fslroi",
                  preproc_dir / realign_path.name,
                  task_dir / "data" / "example_func", "0", "1")

    warp_prep(task_dir, anat_dir, dof)
    warp_func(directory_info)

    log.info(f"Warping SNR image in folder {preproc_dir}")
    warp_snr(directory_info)

    log.info(f"Generating mask for {task_dir.name}")
    generate_mask(task_dir)


def run(config_dir, session, subject, task):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"

    root = config_get(config, "root")
    dof = config_get(config, "dof")
    log = logging.getLogger(f"preproc_{session}_{subject}")

    directory_info = {
        "FSLDIR": os.environ["FSLDIR"],
        "task_dir": paths.task_path(root, session, subject, task),
        "anat_dir": paths.anat_path(root, session, subject),
        "preproc_dir": paths.task_path(root, session, subject, task,
                                       folder="preproc"),
    }
    func_general(directory_info, config, dof, log)
    log.info(f"General preproc for {task} complete")


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config = args[0]
    session = args[1]
    subject = args[2]
    task = args[3]
    run(config, session, subject, task)
