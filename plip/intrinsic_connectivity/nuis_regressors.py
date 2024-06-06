#!/usr/bin/python3
"""
Because this was not based on the 1 pre 2 post
frame displacement will need to replace the
previously used spikes with the more conservative movement new regressors
"""
import numpy as np
import pandas as pd
from pathlib import Path
from scipy.io import loadmat
import plip.utils.paths as paths
from plip.definitions import movement_path, smooth_path_b, spikes_path
from plip.utils.fsl_commands import fsl_command


def ic_fmri_inputs(root, session, subject, ic_tasks):
    return _ic_paths_template(smooth_path_b, root, session, subject, ic_tasks)


def spikes_inputs(root, session, subject, ic_tasks):
    return _ic_paths_template(spikes_path, root, session, subject, ic_tasks)


def movement_inputs(root, session, subject, ic_tasks):
    return _ic_paths_template(movement_path, root, session, subject, ic_tasks)


def _ic_paths_template(template_path, root, session, subject, ic_tasks):
    return [
        Path(str(template_path).format(
            task_dir=paths.task_path(root, session, subject, task))
            ) for task in ic_tasks
    ]


def spmmat_inputs(root, session, subject, ic_tasks):
    files = list()
    for task in ic_tasks:
        con_dir = paths.task_path(root, session, subject, task,
                                  folder="connectivity")
        files.append(paths.model_path(con_dir) / "SPM.mat")
    return files


def model_regressors(spmmat):
    spm = loadmat(spmmat)
    reg = spm["SPM"]["xX"][0, 0]["X"][0, 0]  # Regressor values
    names = spm["SPM"]["xX"][0, 0]["name"][0, 0][0]  # Regressor name

    regressors = dict()
    for i, name in enumerate(names):
        name = name[0]  # Mat files have the info in a nested array
        if "constant" not in name and "bf" in name:
            regressors[name] = reg[:, i]
    return pd.DataFrame(regressors)


def var_spikes(spikes_path):
    spm = loadmat(spikes_path)
    df = pd.DataFrame(spm["spike_regressors"])
    df.columns = ["discarded_%d" % i for i in range(df.shape[1])]
    return df


def load_movement(movement_path):
    # NOTE: see if this can be a CSV instead
    # df = pd.read_csv(movement_path, sep="  ", header=None, engine="python")

    ## AJK EDIT using csv
    df = pd.read_csv(movement_path, sep=",", header=None, engine="python")
    ## END AJK EDIT

    dx = df.shift(1).fillna(0) - df # first derivative
    moves = pd.concat([df, dx], axis=1)
    # FIXME HACK, the rp_txt files should really have columns names!
    moves.columns = [f"{i}" for i in range(12)]
    for c in moves.columns:
        moves[f"{c}_sqr"] = np.square(moves[c]) # quadratic expansion
    return moves


# def padded_values(values, pad_num, total_num, index):
#     pad_values = np.zeros(total_num)
#     start = pad_num * index
#     end = pad_num * (index + 1)
#     pad_values[start:end] = values
#     return pad_values

## AJK EDITS: pad_num is a TUPLE (task_vols) and allow for different task-lengths
def padded_values(values, pad_num, total_num, index):
    pad_values = np.zeros(total_num)
    if index == 0:
        start = 0
        end = pad_num[0][1] ## first task
    elif index > 0:
        start = sum(task[1] for task in pad_num[:index])
        end = start + pad_num[index][1]
    pad_values[start:end] = values
    return pad_values


def combine_mean_signals(ic_dir, anat_dir):
    # """ Create time courses from wm and csf masks """
    # all_tasks = ic_dir / "all_tasks.nii.gz"
    # data = dict()
    # for name, filename in [("wm", "wwm_FSL_eroded_mask_fin.nii"),
    #                        ("csf", "wcsf_FSL_eroded_mask.nii")]:
    #     mask = anat_dir / "FSL_segmentation" / filename
    #     res = fsl_command("fslstats", "-t", all_tasks, "-k", mask, "-M")
    #
    #     # convert the fsl output to something usable
    #     data[name] = [float(elem) for elem in
    #                   res.decode("utf-8").split("\n") if elem]
    # return pd.DataFrame(data)

    #### AJK EDITS (added in resampling between masks and all_tasks.nii)
    """ Create time courses from wm and csf masks """
    all_tasks = ic_dir / "all_tasks.nii"
    data = dict()
    for name, filename in [("wm", "wwm_FSL_eroded_mask_fin.nii"),
                            ("csf", "wcsf_FSL_eroded_mask.nii")]:
        mask = anat_dir / "FSL_segmentation" / filename
        ## 3Dresample masks and all_tasks.nii
        import os
        os.system("3dresample -prefix " + str(mask)[:-4] + "_resampled.nii " + " -master " + str(all_tasks) + " -input " + str(mask))
        os.system("rm " + str(mask))
        os.system("mv " + str(mask)[:-4] + "_resampled.nii " + str(mask))
        ## END AJK EDITS
        res = fsl_command("fslstats", "-t", all_tasks, "-k", mask, "-M")

        # convert the fsl output to someting usable
        data[name] = [float(elem) for elem in res.decode("utf-8").split("\n") if elem]
    return pd.DataFrame(data)


def nuis_regressors(movement_paths, spikes_paths, spmmat_paths, ic_tasks,
                    task_vols):
    """
    Generates the nuisance regressors for intrinsic connectivity first level
    modeling. The nuisance regressors are:
      1.) Spikes (encoded as volumes) that are either high movement or high
      variance
      2.) Stimuli displayed during each task
      3.) 24 Movement regressors given by {derivative}_{rot,trans}_{x,y,z}_{^2}
    """
    # NOTE: It's super important that these lists are given in the same task
    # order
    movement = [load_movement(path) for path in movement_paths]
    df = pd.concat(movement, axis=0, sort=False)
    df.reset_index(drop=True, inplace=True)
    ## AJK EDIT (sum volumes of all tasks)
    # ic_vols = len(ic_tasks) * task_vols
    ic_vols = sum(task[1] for task in task_vols)

    task_info = zip(ic_tasks, spikes_paths, spmmat_paths)
    for i, (task, spikes_fp, spmmat) in enumerate(task_info):
        stimuli = model_regressors(spmmat)
        if spikes_fp.is_file():
            spikes = var_spikes(spikes_fp)
            regressors = pd.concat([stimuli, spikes], axis=1)
        else:
            regressors = stimuli.copy()
        for col in regressors.columns:
            df[f"{task}_{col}"] = padded_values(regressors[col], task_vols,
                                                ic_vols, i)
        ## AJK EDIT
        # df[task] = padded_values([1] * task_vols, task_vols, ic_vols, i)
        df[task] = padded_values([1]*task_vols[i][1], task_vols, ic_vols, i)
    return df


def run(root, session, subject, ic_tasks, task_vols):
    anat_dir = paths.anat_path(root, session, subject)
    ic_dir = paths.ic_path(root, session, subject)
    movement_paths = movement_inputs(root, session, subject, ic_tasks)
    spikes_paths = spikes_inputs(root, session, subject, ic_tasks)
    spmmat_paths = spmmat_inputs(root, session, subject, ic_tasks)

    glb = combine_mean_signals(ic_dir, anat_dir)
    nuis = nuis_regressors(
        movement_paths, spikes_paths, spmmat_paths,
        ic_tasks, task_vols)

    nuis_reg = pd.concat([nuis, glb[["wm", "csf"]]], axis=1)
    nuis_reg.to_csv(ic_dir / "nuisance.txt", index=False, header=False)
    nuis_reg.to_csv(ic_dir / "nuisance_with_header.csv", index=False)
