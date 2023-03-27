#!/usr/bin/python3
"""
NOTE: This just looks at the spikes regressors for 1st level modeling
"""
import numpy as np
import pandas as pd
from pathlib import Path

import plip.utils.os as plipos
import plip.utils.paths as paths


def task_movement(root, sessions, subjects, tasks, task_vols):
    rows = list()
    for session in sessions:
        for subject in subjects:
            for task in tasks:
                num_vols = task_vols[task]["volumes"]  # FIXME: handle variable
                row = {"session": session, "subject": subject, "task": task}
                con_dir = paths.task_path(root, session, subject, task,
                                          folder="connectivity")
                filepath = (paths.model_path(con_dir) /
                            "spikes_FD_only_regressors.txt")
                if filepath.is_file() and filepath.stat().st_size == 0:
                    row["discarded"] = 0
                elif filepath.is_file():
                    df = pd.read_csv(filepath, header=None)
                    row["discarded"] = df.shape[1]
                else:
                    row["discarded"] = np.nan
                row["discarded_percent"] = row["discarded"] / num_vols
                rows.append(row)
    return rows


def ic_movement(root, sessions, subjects, ic_tasks, task_vols):
    ic_vols = sum([task_vols[task]["volumes"] for task in ic_tasks])

    rows = list()
    for session in sessions:
        for subject in subjects:
            row = {
                    "session": session,
                    "subject": subject,
                    "task": "intrinsic_connectivity"
                    }
            filepath = (paths.ic_path(root, session, subject) /
                        "nuisance_with_header.csv")
            if filepath.is_file():
                df = pd.read_csv(filepath)
                row["discarded"] = len([c for c in df.columns if
                                        "discarded" in c.lower()])
                row["discarded_percent"] = row["discarded"] / ic_vols
            else:
                row["discarded"] = np.nan
            rows.append(row)
    return rows


def movement(config_dir):
    from plip.utils.config_get import config_get
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    task_config = config_dir / "tasks.json"

    root = config_get(config, "root")
    tasks = config_get(config, "tasks")
    ic_tasks = config_get(config, "ic_tasks")
    sessions = config_get(config, "sessions")
    subject_list = config_get(config, "subject_list")
    subjects = pd.read_csv(subject_list)["subject"].astype(str)

    task_info = config_get(task_config, [])
    tasks = task_movement(root, sessions, subjects, tasks, task_info)
    ic = ic_movement(root, sessions, subjects, ic_tasks, task_info)

    cols = ["session", "subject", "task", "discarded", "discarded_percent"]
    df = pd.DataFrame(tasks + ic)[cols]
    df.sort_values(["subject", "task"], inplace=True)

    dump_dir = paths.dump_path(root)
    plipos.makedirs(dump_dir)

    dst = dump_dir / "movement.csv"
    df.to_csv(dst, index=False)


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    movement(config_dir)
