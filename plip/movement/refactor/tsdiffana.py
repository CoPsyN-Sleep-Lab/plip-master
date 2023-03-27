#!/usr/bin/python3
# flake8: noqa
import pandas as pd
import numpy as np
import plip.utils.mri as mri
from math import pi

"""
This does the most important parts of tsdiffana.
"""

#change upper limits here
TMLIMIT = 10 # mean scaled image variance
SLICELIMIT = 20 # mean scaled mean slice variance per image
XYZLIMIT = .3 # movement limit from image to image in mm taken from Power paper
rotlimit = pi/90 # rotation limit " in rad # FIXME: not used
RADIUS = 50 # assuming 50mm radius sphere.
# ^FIXME: this sounds like it needs to be updated

def get_spikes(data):
    # Old names: globals (g), timediff (td), slicediff
    vol_mean = get_global(data)
    vol_var  = get_vol_var(data)
    slice_var = get_slice_var(data)

    # Divide the diff variance by mean voxel intensity
    norm_vol_var = np.divide(vol_var, vol_mean.mean())

    mean_slice_var = slice_var.mean(axis=0)
    norm_slice_var = np.divide(mean_slice_var, mean_slice_var.mean())
    spikes = list()
    for i in range(len(norm_vol_var)):
        # high change if squared diff > limits
        if norm_vol_var[i] > TMLIMIT or norm_slice_var[i] > SLICELIMIT:
            spikes.append(i)
    return spikes

def get_moves(rp_file):
    # THIS ASPECT WAS TAKEN FROM POWER 2012 TO CREATE THE RMS OF MOVEMENT PARAMTERS
    rp_data = open(rp_file, "r").readlines()
    rp_data = [l.replace("\n", "").strip().split("  ") for l in rp_data]
    rp_data = np.array(rp_data).astype(float)

    #shift to sync with scan number
    rp_data[:, 3:6] = rp_data[:, 3:6] * (RADIUS * (pi / 180))
    rp_diff = (rp_data - np.roll(rp_data, 1, 0))
    rp_diff[0, :] = 0
    abs_diff = np.abs(rp_diff).sum(axis=1)

    # high change if movement is >.2 in x,y,z or >.pi/180 in rotations
    # ^ FIXME: rotation is not included?
    moves = [i for i, diff in enumerate(abs_diff) if diff > XYZLIMIT]
    return moves

def create_spikes_file(spikesandmoves, num_vols, dst, include_next=True):
    spikes = set()
    for spike in spikesandmoves:
        spikes.add(spike)
        if include_next and spike + 1 < num_vols:
            spikes.add(spike + 1)
    spikes = list(sorted(spikes))
    regressors = np.zeros((num_vols, len(spikes)))
    for i, spike in enumerate(spikes):
        regressors[spike, i] = 1
    regressors = pd.DataFrame(regressors.astype(int))
    pd.DataFrame(regressors).to_csv(dst, header=None, index=None)

def run(fp, rp_file, dst):
    data = mri.load_data(fp)
    spikes = get_spikes(data)
    moves  = get_moves(rp_file)
    create_spikes_file(spikes + moves, data.shape[-1], dst)

"""
This is the TLDR of old PLIP's timediff.m
"""
def get_global(data):
    return data.mean(axis=(0, 1, 2))

def get_vol_var(data):
    # FIXME: this can be sped up by taking the output of get_slice_var
    diff = (data - np.roll(data, 1, 3))[:, :, :, 1:]
    return np.square(diff).mean(axis=(0, 1, 2))

def get_slice_var(data):
    diff = (data - np.roll(data, 1, 3))[:, :, :, 1:]
    return np.square(diff).mean(axis=(0, 1))
