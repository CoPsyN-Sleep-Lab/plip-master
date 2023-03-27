#!/usr/bin/python3
import numpy as np
import pandas as pd
from tqdm import tqdm

import plip.utils.mri as mri


def time_course_correlation(time_courses):
    roi_corr = time_courses.corr(method="pearson")
    return roi_corr


def fisher_z_corr(roi_corr):
    with np.errstate(divide='ignore'):
        fisher_z = 0.5 * np.log(np.divide(1 + roi_corr, 1 - roi_corr))
    return fisher_z


def roi_time_course(filepath, mask_paths):
    fmri = mri.load_image(filepath, closest_canonical=False)
    fmri_data = mri.load_data(fmri)
    time_course = dict()
    for mask_path in mask_paths:
        mask = mri.load_image(mask_path, closest_canonical=False)
        mask_data = mri.load_data(mask)

        assert (mask.affine == fmri.affine).all()
        mask_time_course = list()
        for i in range(fmri.shape[3]):
            volume = fmri_data[:, :, :, i]
            mask_time_course.append(np.mean(np.multiply(volume, mask_data)))

        time_course[mask_path.name.split(".")[0]] = mask_time_course
    return pd.DataFrame(time_course)


def roi_correlation(subject, filepath, mask_paths, dst_dir):
    time_course = roi_time_course(filepath, mask_paths)
    time_course.to_csv(dst_dir / f"time_course_{subject}.csv", index=False)

    roi_corr = time_course_correlation(time_course)
    roi_corr.to_csv(dst_dir / f"pearson_corr_{subject}.csv")

    fisher_z = fisher_z_corr(roi_corr)
    fisher_z.to_csv(dst_dir / f"fisher_z_corr_{subject}.csv")


def run(subjects_paths, masks, dst_dir):
    for subject in tqdm(subjects_paths):
        if (dst_dir / f"fisher_z_corr_{subject}.csv").is_file():
            continue

        filepath = subjects_paths[subject]["filepath"]
        grey_dir = subjects_paths[subject]["grey_dir"]
        # Are grey masks really necessary?  WM/CSF gets regressed out
        # during ic prep
        if not filepath.is_file():
            continue

        mask_paths = [mri.find_image(grey_dir, mask) for mask in masks]
        roi_correlation(subject, filepath, mask_paths, dst_dir)


if __name__ == "__main__":
    print("This script is meant to be imported")
