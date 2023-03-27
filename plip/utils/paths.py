#!/usr/bin/python3
from pathlib import Path


class DuplicateFileError(Exception):
    pass


class MissingFileError(Exception):
    pass


def button_path(root, session, subject, task):
    return Path(root) / "button" / subject / session / task / "onsets"


def raw_path(root, session, subject):
    return Path(root) / "raw" / session / subject


def raw_anat_path(root, session, subject, t1_type):
    # Iterate over the T1s provided until a match
    for t1 in t1_type:
        try:
            return raw_task_path(root, session, subject, t1)
        except MissingFileError as e:
            print(e)
    raise MissingFileError(f"No T1s found for {session} {subject} {t1_type}")


def raw_task_path(root, session, subject, task):
    raw_dir = raw_path(root, session, subject)
    search = Path(raw_dir) / task
    matches = list(search.glob("*.nii*"))
    if len(matches) > 1:
        raise DuplicateFileError(f"Duplicates found for {search}")
    elif len(matches) == 0:
        raise MissingFileError(f"No images found for {search}")
    return Path(matches.pop())


def subject_path(root, session, subject):
    return Path(root) / "processed" / session / subject


def anat_path(root, session, subject):
    return subject_path(root, session, subject) / "anat"


def grey_path(root, session, subject):
    return anat_path(root, session, subject) / "grey_masks"


def func_path(root, session, subject):
    return subject_path(root, session, subject) / "func"


def task_path(root, session, subject, task, folder=None):
    task_dir = func_path(root, session, subject) / task
    if folder is None:
        return task_dir
    return task_dir / folder


def ppi_path(root, session, subject, task, seed, contrast):
    return (task_path(root, session, subject, task) / "ppi" /
            f"{seed}_{contrast}")


def model_path(directory):
    return Path(directory) / "modeling"


def ic_path(root, session, subject):
    return subject_path(root, session, subject) / "ic"


def biotype_path(root):
    return Path(root) / "biotypes"


def dump_path(root):
    return biotype_path(root) / "dump"
