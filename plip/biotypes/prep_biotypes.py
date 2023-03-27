#!/usr/bin/python3
"""
Creates an unstandardized biotype file

NOTE: the find_{act,ppi,ic} functions are because some formatting is needed.
The column is labeled slightly differently in the dataframes than in the
biotype file. For instance columns in the dataframes don't start with `act-`,
`ppi-`, or `ic-`. Also when collating the data, the only thing looked at is
the mask code ID, this allows for the biotype file to have shorter names
(like removing _10mm_) and allowing for slight renaming (changing pACC to
pgACC).  Always make sure the code is correct!!!
"""
import sys
import pandas as pd
from pathlib import Path
from datetime import datetime

import plip.utils.paths as paths
from plip.utils.config_get import config_get


def mask_code(mask):
    """ Gets the 6 digit mask code that define all plip masks"""
    return mask.split("_")[0]


def ic_mask_codes(mask_pair):
    """ Mask codes for ic which has two masks """
    mask1 = mask_code(mask_pair.split("-to-")[0])
    mask2 = mask_code(mask_pair.split("-to-")[1])
    return mask1, mask2


def needed_cols(biotypes):
    """
    Determine which values are needed based on the biotype formulas given
    """
    cols = set()
    for name, biotype in biotypes.items():
        task = biotype["task"]
        if "act" in biotype:
            contrast = biotype["contrast"]
            for elem in biotype["act"]:
                mask = elem["component"]
                cols.add(f"act-{task}-{contrast}-{mask}")
        if "ppi" in biotype:
            contrast = biotype["contrast"]
            for elem in biotype["ppi"]:
                mask1, mask2 = elem["component"]
                cols.add(f"ppi-{task}-{contrast}-{mask1}-{mask2}")
                cols.add(f"ppi-{task}-{contrast}-{mask2}-{mask1}")
        if "ic" in biotype:
            for elem in biotype["ic"]:
                mask_pair = elem["component"]
                cols.add(f"ic-{mask_pair}")
    return list(cols)


def find_act(act, col):
    """
    Returns the activation values that belong to the `col` input.
    """
    info = col.split("-")
    matches = [c for c in act.columns if (
        c.split("-")[0] == info[1] and  # task
        c.split("-")[1] == info[2] and  # contrast
        c.split("-")[2].startswith(mask_code(info[3]))
        )]
    assert len(matches) == 1, f"No matches found for {col} in act.csv"
    return act[matches.pop()]


def find_ppi(ppi, col):
    """
    Returns the PPI values that belong to the `col` input.
    """
    info = col.split("-")
    matches = [c for c in ppi.columns if (
        c.split("-")[0] == info[1] and  # task
        c.split("-")[1] == info[2] and  # contrast
        c.split("-")[2].startswith(mask_code(info[3])) and
        c.split("-")[3].startswith(mask_code(info[4]))
        )]
    assert len(matches) == 1, f"No matches found for {col} in ppi.csv"
    return ppi[matches.pop()]


def find_ic(ic, col):
    """
    Returns the IC values that belong to the `col` input
    """
    mask_pair = "-".join(col.split("-")[1:])
    matches = [c for c in ic.columns if
               set(ic_mask_codes(c)) == set(ic_mask_codes(mask_pair))]
    assert len(matches) == 1, f"No matches found for {col} in ic.csv"
    return ic[matches.pop()]


def prep_session(df, cols, act, ic, ppi, movement, dst):
    """
    Collate all the formula values along with the discarded volumes values
    """
    for col in cols:
        category = col.split("-")[0]
        if category == "act":
            df[col] = find_act(act, col)
        elif category == "ppi":
            df[col] = find_ppi(ppi, col)
        elif category == "ic":
            df[col] = find_ic(ic,  col)
        else:
            raise ValueError("Unsupported category %s for biotypes" % category)
    for task in movement["task"].unique():
        tmp = movement.copy()
        tmp = tmp[tmp["task"] == task].set_index("subject")
        df[f"{task}_discarded_percent"] = tmp["discarded_percent"]
    df = df[sorted([c for c in df])]
    df.to_csv(dst)
    return dst


def prep_biotypes(config_dir):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = Path(config_get(config, "root"))

    biotypes = config_dir / "biotypes.json"
    biotypes = config_get(biotypes, [])
    cols = needed_cols(biotypes)

    sessions = config_get(config, "sessions")
    subject_list = config_get(config, "subject_list")
    subjects = pd.read_csv(subject_list)["subject"]

    dump_dir = paths.dump_path(root)
    movement = pd.read_csv(dump_dir / "movement.csv")
    dsts = list()
    for session in sessions:
        act = pd.read_csv(dump_dir / f"activation_{session}.csv",
                          index_col="subject")
        ic = pd.read_csv(dump_dir / f"ic_{session}.csv",  index_col="subject")
        ppi = pd.read_csv(dump_dir / f"ppi_{session}.csv", index_col="subject")
        mm = movement.copy()[movement["session"] == session]

        date = datetime.now().strftime("%Y-%m-%d")
        dst = root / "biotypes" / f"biotypes-{session}-no_std-{date}.csv"

        df = pd.DataFrame(index=subjects)
        prep_session(df, cols, act, ic, ppi, mm, dst)
        dsts.append(dst)
    return dsts


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    prep_biotypes(config_dir)
