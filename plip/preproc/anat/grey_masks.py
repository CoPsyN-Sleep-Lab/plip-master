#!/usr/bin/python3
"""
Imports
"""
import os
import logging
import numpy as np
import nibabel as nib
from pathlib import Path

import plip.utils.mri as mri
import plip.utils.paths as paths
import plip.utils.os as plipos
from plip.utils.config_get import config_get
from plip.utils.fsl_in_docker import fsl_in_docker

FSLDIR = os.environ["FSLDIR"]


def binarize(data):
    # Round because some masks are not perfectly binary
    data = data.round()
    unique_vals = set(np.unique(data))
    non_binary = len(unique_vals - {0, 1})

    assert non_binary == 0, (f"Mask has {non_binary} unique values that are "
                             "not 0 or 1")
    return data


def calc_percent_overlap(roi_data, grey_data):
    assert roi_data.shape == grey_data.shape, ("Shapes of ROI and grey matter "
                                               "do not match")
    num_non_zero = roi_data.sum()
    # number of voxels in both roi and grey matter
    num_overlap = roi_data[grey_data > 0].sum()
    return 100 * (num_overlap / num_non_zero)


def threshold_image(data, threshold):
    assert threshold >= 0 and threshold <= 1, ("Threshold should be between 0 "
                                               "and 1, not %04f" % threshold)
    data[data < threshold] = 0


def create_threshed_image(grey_mask_path, grey_mask_dir, threshold):
    # FIXME: Check if this is already done
    grey_mask = mri.load_image(grey_mask_path)
    grey_data = mri.load_data(grey_mask)
    threshold_image(grey_data, threshold)

    new_path = grey_mask_dir / "greymatter_mask_thresh6.nii"
    new_image = nib.Nifti1Image(grey_data, affine=grey_mask.affine,
                                header=grey_mask.header)
    mri.save_image(new_image, new_path)


def apply_warp(grey_mask_dir):
    in_path = grey_mask_dir / "greymatter_mask_thresh6.nii"
    out_path = grey_mask_dir / "w_greymatter_mask_thresh6.nii"
    warp_path = grey_mask_dir / ".." / "reg" / "highres2standard_warp"
    assert in_path.is_file(), "The input %s is not found" % in_path
    # assert isfile(warp_path), "The warp file %s is not found" % warp_path
    fsl_in_docker("applywarp",
                  "-i", in_path,
                  "-w", warp_path,
                  "-r", f"{FSLDIR}/data/standard/MNI152_T1_2mm_brain",
                  "-o", out_path)


def grey_roi_mask(roi_data, grey_data):
    grey_roi_data = roi_data.copy()
    grey_roi_data[grey_data <= 0] = 0
    return grey_roi_data


def create_grey_roi_mask(grey_mask_dir, grey_mask_path, masks):
    for roi_path in masks:  # Loop Through Masks and save individualized list

        # Grey matter
        grey_mask = mri.load_image(grey_mask_path)
        grey_data = mri.load_data(grey_mask)

        # ROI
        roi = mri.load_image(roi_path)
        roi_data = mri.load_data(roi)
        roi_data = binarize(roi_data)

        msg = f"Affine's {roi.affine} and {grey_mask.affine} do not match"
        assert (roi.affine == grey_mask.affine).all(), msg

        # percent_overlap = calc_percent_overlap  # FIXME: Log this!

        grey_roi_data = grey_roi_mask(roi_data, grey_data)
        grey_roi_path = grey_mask_dir / roi_path.name
        grey_roi = nib.Nifti1Image(grey_roi_data, affine=roi.affine)
        mri.save_image(grey_roi, grey_roi_path)


def copy_thresh_mask(grey_mask_dir):
    """
    Copy over the grey matter mask as for normalization (self-standardization
    is not currently implemented)
    FIXME: change this thresh 6 from being hard coded
    """
    src = grey_mask_dir / "w_greymatter_mask_thresh6.nii"
    dst = grey_mask_dir / "biLat_greyMatter_Standardize_cluster.nii"

    plipos.copy(src, dst)


def pl_grey_masks(anat_dir, grey_mask_dir, mask_dir, mask_names,
                  threshold=0.6):
    """
    The default threshold of 0.6 was chosen by Zoe Samara and Andrea Goldstein.
    """
    grey_mask_path = anat_dir / "FSL_segmentation" / "brain_pve_1.nii"

    if len(list(grey_mask_dir.glob("*.nii"))) == len(mask_names) + 3:
        return

    plipos.rmtree(grey_mask_dir)
    plipos.makedirs(grey_mask_dir)
    create_threshed_image(grey_mask_path, grey_mask_dir, threshold)
    apply_warp(grey_mask_dir)
    masks = [mask_dir / f"{name}.nii" for name in mask_names]
    grey_mask_path = grey_mask_dir / "w_greymatter_mask_thresh6.nii"
    create_grey_roi_mask(grey_mask_dir, grey_mask_path, masks)
    copy_thresh_mask(grey_mask_dir)


def run(config_dir, session, subject):
    """
    Given a config, this will format pull appropriate inputs and run the method
    `pl_grey_masks`
    """

    # load arguments from config
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = Path(config_get(config, "root"))
    mask_dir = Path(config_get(config, "mask_dir"))

    anat_dir = paths.anat_path(root, session, subject)
    grey_mask_dir = paths.grey_path(root, session, subject)
    log = logging.getLogger(f"preproc_{session}_{subject}")

    with open(config_dir / "masks.txt", "r") as f:
        mask_names = f.readlines()
        mask_names = [m.replace("\n", "") for m in mask_names]

    # Create grey matter masks
    pl_grey_masks(anat_dir, grey_mask_dir, mask_dir, mask_names)
    log.info("Gray matter masks complete")


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    session = args[1]
    subject = args[2]
    run(config_dir, session, subject)
