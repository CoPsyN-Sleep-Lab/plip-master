#!/usr/bin/python3
import sys
import numpy as np
import pandas as pd
from datetime import datetime
from pathlib import Path
from plip.utils.config_get import config_get


def standardize_dataframe(df, std_df):
    cols = [c for c in df.columns if c.split("-")[0] in {"act", "ppi", "ic"}]

    # subtract mean and divide by stddev (replacing 0 with 1 to avoid creating
    # nans when stddev is 0)
    df[cols] = ((df[cols] - std_df[cols].mean()) /
                std_df[cols].std().replace(0.0, 1.0))
    return df


def compute_biotypes(df, biotypes):
    for name, biotype in biotypes.items():
        task = biotype["task"]
        score = np.zeros(df.shape[0])
        num_elems = 0
        if "act" in biotype:
            contrast = biotype["contrast"]
            for elem in biotype["act"]:
                mask = elem["component"]
                weight = elem["weight"]
                score += weight * df[f"act-{task}-{contrast}-{mask}"]
                num_elems += 1
        if "ppi" in biotype:
            contrast = biotype["contrast"]
            for elem in biotype["ppi"]:
                mask1, mask2 = elem["component"]
                weight = elem["weight"]
                cols = [
                    f"ppi-{task}-{contrast}-{mask1}-{mask2}",
                    f"ppi-{task}-{contrast}-{mask2}-{mask1}"
                ]
                # NOTE: all PPI scores will be "fixed" meaning the average is
                # taken from both masks
                score += weight * df[cols].mean(axis=1)
                num_elems += 1
        if "ic" in biotype:
            for elem in biotype["ic"]:
                mask_pair = elem["component"]
                weight = elem["weight"]
                score += weight * df[f"ic-{mask_pair}"]
                num_elems += 1
        df[name + "_score"] = score / num_elems
    return df


def create_biotype_file(config_dir, *files):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    biotypes = config_dir / "biotypes.json"
    biotypes = config_get(biotypes, [])

    dof = config_get(config, "dof")
    root = config_get(config, "root")
    std_file = config_get(config, "standardization")
    msg = ("You shouldn't standardize off a group processed differently.  "
           "Check `dof` flag")
    assert std_file.name.endswith(f"_dof{dof}.csv"), msg
    std_df = pd.read_csv(std_file, index_col="subject")
    std_tag = std_file.name.replace(".csv", "")
    assert std_df.isnull().sum().sum() == 0, ("Standardization file should "
                                              "not have missing values")

    dsts = list()
    for f in files:
        print("Standardizing", f)
        session = f.name.split("-")[1]
        df = pd.read_csv(f, index_col="subject")
        df = standardize_dataframe(df, std_df)
        df = compute_biotypes(df, biotypes)

        date_tag = datetime.now().strftime("%Y-%m-%d")
        fp = root / "biotypes" / f"biotypes-{std_tag}-{session}-{date_tag}.csv"
        df = df[sorted([c for c in df])]
        df.to_csv(fp)
        dsts.append(fp)
        print("Generated", fp)
    return dsts


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    create_biotype_file(config_dir, *args[1:])
