#!/usr/bin/python3
from pathlib import Path
import plip.utils.os as plipos
import plip.utils.paths as paths
from plip.utils.config_get import config_get


def setup_ic(config_dir, session, subject):
    import plip.intrinsic_connectivity as ic
    from plip.utils.fsl_in_docker import fsl_in_docker
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    ic_tasks = config_get(config, "ic_tasks")

    ic_dir = paths.ic_path(root, session, subject)
    plipos.makedirs(ic_dir)
    task_vols = task_attr(config_dir / "tasks.json", ic_tasks, "volumes").pop()

    # Concatenate tasks together
    fmri_paths = ic.nuis_regressors.ic_fmri_inputs(root, session, subject,
                                                   ic_tasks)
    fsl_in_docker("fslmerge", "-t", f"{ic_dir}/all_tasks.nii", *fmri_paths)

    # Creates nuisance.txt
    ic.nuis_regressors.run(root, session, subject, ic_tasks, task_vols)


def incomplete_inputs(config_dir, session, subject):
    import plip.intrinsic_connectivity as ic
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    ic_tasks = config_get(config, "ic_tasks")
    is_incomplete = list()

    for path in ic.nuis_regressors.ic_fmri_inputs(root, session, subject,
                                                  ic_tasks):
        if not path.is_file():
            is_incomplete.append(f"Missing --> {path}")

    for path in ic.nuis_regressors.movement_inputs(root, session, subject,
                                                   ic_tasks):
        if not path.is_file():
            is_incomplete.append(f"Missing --> {path}")

    task_config = config_dir / "tasks.json"
    if len(task_attr(task_config, ic_tasks, "tr")) != 1:
        is_incomplete.append("Inconsistent TR between ic_tasks")

    if len(task_attr(task_config, ic_tasks, "volumes")) != 1:
        is_incomplete.append("Inconsistent volumes between ic_tasks")

    return is_incomplete


def task_attr(task_config, ic_tasks, attr):
    return {config_get(task_config, [task, attr]) for task in ic_tasks}


def skip_ic(config_dir, session, subject):
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    ic_dir = paths.ic_path(root, session, subject)
    skip = (ic_dir / "ResidualImages_Filt.nii").is_file()
    if not skip:
        plipos.rmtree(ic_dir)
    return skip
