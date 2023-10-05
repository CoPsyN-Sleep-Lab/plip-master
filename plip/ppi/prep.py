#!/usr/bin/python3
import os
import plip.utils.os as plipos


def setup_ppi(ppi_dir):
    plipos.makedirs(ppi_dir)


def skip_ppi(model_dir, ppi_dir):
    skip = (ppi_dir / "spmT_0002.nii").is_file()
    if skip:
        return skip
    plipos.rmtree(ppi_dir)
    for f in model_dir.glob("PPI_VOI*.mat"):
        os.remove(f)
    for f in model_dir.glob("VOI*.mat"):
        os.remove(f)
    return skip


def incomplete_inputs(model_dir):
    incomplete = not (model_dir / "SPM.mat").is_file()
    return incomplete
