#!/usr/bin/python3
import numpy as np
import pandas as pd
from tqdm import tqdm
from pathlib import Path

import plip.utils.os as plipos
import plip.utils.paths as paths
import plip.betadumps.roi_correlation as roi_correlation
from plip.utils.mri import find_image
from plip.utils.fsl_commands import fsl_command


# def batch_act_betadump(root, sessions, subjects, models, masks):
#     for session in sessions:
#         dst_dir = paths.dump_path(root) / "cache_activation" / session
#         for i, row in models.iterrows():
#             task = row["task"]
#             filename = row["filename"]
#             contrast = row["contrast"]
#             act_dir = paths.task_path(root, session, "%s", task,
#                                       folder="activation")
#             model_dir = paths.model_path(act_dir)
#             template_path = model_dir / filename
#
#             model_name = f"{task}-{contrast.lower()}"
#             dst = dst_dir / model_name / "{subject}.csv"
#             print("Gathering Activation betas for %s" % model_name)
#             plipos.makedirs(dst.parent)
#             for subject in tqdm(subjects):
#                 betadump(root, session, subject, template_path, masks, dst)
#         merge_act(dst_dir, paths.dump_path(root) / f"activation_{session}.csv")

def batch_con_betadump(root, sessions, subjects, models, masks):
    for session in sessions:
        dst_dir = paths.dump_path(root) / "cache_connectivity" / session
        for i, row in models.iterrows():
            task = row["task"]
            filename = row["filename"].replace("mni_", "")
            contrast = row["contrast"]
            act_dir = paths.task_path(root, session, "%s", task,
                                      folder="connectivity")
            model_dir = paths.model_path(act_dir)
            template_path = model_dir / filename

            model_name = f"{task}-{contrast.lower()}"
            dst = dst_dir / model_name / "{subject}.csv"
            print("Gathering Connectivity betas for %s" % model_name)
            plipos.makedirs(dst.parent)
            for subject in tqdm(subjects):
                ## ajk edits -- remove NaNs, replace with zeros
                import os
                con_path = str(template_path) % subject
                os.system("fslmaths " + str(con_path) + " -nan " + str(con_path))
                ## end ajk edits
                betadump(root, session, subject, template_path, masks, dst)
        merge_act(dst_dir, paths.dump_path(root) / f"connectivity_{session}.csv")

def merge_act(dst_dir, dst):
    import warnings
    warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)
    df = pd.DataFrame()
    for model_dir in dst_dir.glob("*"):
        if(model_dir.name != '.DS_Store'):
            model = model_dir.name
            task = model.split("-")[0]
            contrast = model.split("-")[1]
            dfs = list()
            for filepath in model_dir.glob("*.csv"):
                # sometimes an empty file is 1 byte
                if filepath.stat().st_size < 5:
                    continue
                dfs.append(pd.read_csv(filepath))
            if len(dfs) == 0:
                continue
            tmp = pd.concat(dfs).set_index("subject")
            for mask in tmp.columns:
                df[f"{task}-{contrast}-{mask}"] = tmp[mask]
    df.to_csv(dst, index=True)


def batch_ppi_betadump(root, sessions, subjects, models, masks):
    """
    Create list of session dirs that will be looped over in pl_betaDump
    (so there is only one loop, not one for sessions and on for subjects)
    """
    for session in sessions:
        dst_dir = paths.dump_path(root) / "cache_ppi" / session
        for i, row in models.iterrows():
            task = row["task"]
            seed = row["seed"]
            # FIXME: Ah!  This makes me nervous.  Trust the SPM.mat instead
            # for what the contrast name is
            contrast = row["contrast"]
            contrast_num = 1  # This is always 1. AKA the positive regressor
            template_path = (paths.task_path(root, session, "%s", task) /
                         "ppi" / f"{seed}_{contrast}" / "con_0001.nii")
                         #"con_%04.nii" % int(contrast_num)) # int(contrast_num)?


            model_name = f"{task}-{contrast.lower()}-{seed}"
            dst = dst_dir / model_name / "{subject}.csv"
            print("Gathering PPI betas for %s" % model_name)
            plipos.makedirs(dst.parent)

            for subject in tqdm(subjects):

                ## ajk edits remove NaN's from PPI con files and replace with zeros so spm beta dump works
                import os
                con_path = str(template_path) % subject

                os.system("fslmaths " + str(con_path) + " -nan " + str(con_path)) ## will output as new .nii.gz?
                #os.system("rm " + str(con_path)) # remove old .nii file with nans
                # temp_conname = str(con_path) + ".gz"
                # temp_conname = str(con_path)
                # os.system('gunzip ' + temp_conname) #convert back to .nii
                ## END AJK EDITS ####################################

                betadump(root, session, subject, template_path, masks, dst)
        merge_ppi(dst_dir, paths.dump_path(root) / f"ppi_{session}.csv")


def merge_ppi(dst_dir, dst):
    df = pd.DataFrame()
    import warnings
    warnings.filterwarnings("ignore", category=pd.errors.PerformanceWarning)
    for model_dir in dst_dir.glob("*"):
        if(model_dir.name != '.DS_Store'):
            model = model_dir.name
            task = model.split("-")[0]
            contrast = model.split("-")[1]
            mask_1 = model.split("-")[2]
            dfs = list()
            for filepath in model_dir.glob("*.csv"):
                # sometimes an empty file is 1 byte
                if filepath.stat().st_size < 5:
                    continue
                dfs.append(pd.read_csv(filepath))
            if len(dfs) == 0:
                continue
            tmp = pd.concat(dfs).set_index("subject")
            for mask_2 in tmp.columns:
                df[f"{task}-{contrast}-{mask_1}-{mask_2}"] = tmp[mask_2]
    df.to_csv(dst, index=True)


def batch_ic_betadump(root, sessions, subjects, masks):
    print("Calculating intrinsic connectivity correlations")
    filename = "ResidualImages_Filt.nii"
    for session in sessions:
        subjects_paths = dict()
        for subject in subjects:
            ic_dir = paths.ic_path(root, session, subject)
            subjects_paths[subject] = {
                "grey_dir": paths.grey_path(root, session, subject),
                "filepath": ic_dir / filename
            }
        dst_dir = paths.dump_path(root) / "cache_ic" / session
        plipos.makedirs(dst_dir)
        roi_correlation.run(subjects_paths, masks, dst_dir)
        merge_ic(dst_dir, paths.dump_path(root) / f"ic_{session}.csv")


def merge_ic(ic_dir, dst):
    rows = list()
    for f in ic_dir.glob("fisher_z_corr_*.csv"):
        # FIXME: this is brittle!
        subject = f.name.replace("fisher_z_corr_", "").replace(".csv", "")
        df = pd.read_csv(f, index_col=0)
        subject = {"subject": subject}
        for i, row in df.iterrows():
            roi_1 = row.name
            for roi_2 in row.keys():
                # We only care about one pair
                if roi_1 >= roi_2:
                    continue
                subject["%s-to-%s" % (roi_1, roi_2)] = df.loc[roi_1, roi_2]
        rows.append(subject)
    pd.DataFrame(rows).to_csv(dst, index=False)


def betadump(root, session, subject, template_path, masks, dst):
    """
    This function is used for activation and ppi betadumps
    """
    filepath = Path(str(dst).format(subject=subject))
    if filepath.is_file():
        return
    contrast = Path(str(template_path) % subject)
    if not contrast.is_file():
        return
    row = {"subject": subject}
    for mask in masks:
        grey_mask = find_image(paths.grey_path(root, session, subject), mask)
        if not contrast.is_file() or not grey_mask.is_file():
            beta = np.nan
        else:

            ## AJK EDIT - ADD IN 3DRESAMPLE COMMAND TO RESAMPLE ALL MASK IMAGES TO MATCH CON images
            import os
            os.system("3dresample -prefix " + str(grey_mask)[:-4] + "_resampled.nii " + " -master " + str(contrast) + " -input " + str(grey_mask))
            os.system("rm " + str(grey_mask))
            os.system("mv " + str(grey_mask)[:-4] + "_resampled.nii " + str(grey_mask))
            ### END AJK EDITS

            beta = fsl_command("fslstats", contrast, "-k", grey_mask, "-M") ## ajk edit -M ignores zeroes, -m includes zero's
            beta = float(beta.decode("utf-8").replace("\n", ""))
        row[mask] = beta
    pd.DataFrame([row]).to_csv(filepath, index=False)


def batch_betadumps(config_dir):
    # NOTE: Maybe use the tempfile checkpoints used in old PLIP
    from plip.utils.config_get import config_get
    config_dir = Path(config_dir)
    config = config_dir / "config.json"

    root = config_get(config, "root")
    sessions = config_get(config, "sessions")
    subject_list = config_get(config, "subject_list")
    subjects = pd.read_csv(subject_list)["subject"].astype(str)

    with open(config_dir / "masks.txt", "r") as f:
        masks = f.readlines()
        masks = [m.replace("\n", "") for m in masks]

    act_models = pd.read_csv(config_dir / "act_models.csv")
    ppi_models = pd.read_csv(config_dir / "ppi_models.csv")

    #batch_act_betadump(root, sessions, subjects, act_models, masks)
    batch_con_betadump(root, sessions, subjects, act_models, masks)
    batch_ppi_betadump(root, sessions, subjects, ppi_models, masks)
    #batch_ic_betadump(root, sessions, subjects, masks) #Andrea commented since not currently getting IC



if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    batch_betadumps(config_dir)
