#!/usr/bin/python3
import sys
import logging
import pandas as pd
from pathlib import Path
import plip.preproc.func as func
from plip.utils.config_get import config_get
import plip.preproc.anat as anat
from plip.utils.os import subject_logger
import plip.modeling as modeling


def preproc(config_dir, session, subject):
    config = Path(config_dir) / "config.json"
    root = config_get(config, "root")
    tasks = config_get(config, "tasks")

    subject_logger(root, session, subject, "preproc")
    try:
        anat_preproc(config_dir, session, subject)
    except Exception:
        log = logging.getLogger(f"preproc_{session}_{subject}")
        log.exception("Issue while processing anatomical.")
        return

    for task in tasks:
        try:
            func_preproc(config_dir, session, subject, task)
        except Exception:
            log = logging.getLogger(f"preproc_{session}_{subject}")
            log.exception(f"Issue while processing {task}.")


def anat_preproc(config_dir, session, subject):
    if not anat.prep.skip_anat(config_dir, session, subject):
        anat.prep.setup_anat(config_dir, session, subject)
        anat.general.run(config_dir, session, subject)
    anat.grey_masks.run(config_dir, session, subject)


def func_preproc(config_dir, session, subject, task):
    func_general(config_dir, session, subject, task)
    func_activation(config_dir, session, subject, task)
    func_connectivity(config_dir, session, subject, task)
    func_model(config_dir, session, subject, task, "activation",
               "05a_smooth.nii")
    func_model(config_dir, session, subject, task, "connectivity",
               "05b_smooth.nii")


def func_general(config_dir, session, subject, task):
    if not func.prep.skip_general(config_dir, session, subject, task):
        func.prep.setup_func(config_dir, session, subject, task)
        func.general.run(config_dir, session, subject, task)


def func_connectivity(config_dir, session, subject, task):
    if not func.prep.skip_connectivity(config_dir, session, subject, task):
        func.connectivity.run(config_dir, session, subject, task)


def func_activation(config_dir, session, subject, task):
    if not func.prep.skip_activation(config_dir, session, subject, task):
        func.activation.run(config_dir, session, subject, task)


def func_model(config_dir, session, subject, task, folder, filename):
    if not modeling.prep.skip_model(config_dir, session, subject, task,
                                    folder):
        modeling.prep.setup_model(config_dir, session, subject, task, folder,
                                  filename)
        modeling.model.run(config_dir, session, subject, task, folder,
                           filename)


def batch_preproc(config_dir):
    config = Path(config_dir) / "config.json"
    subject_df = pd.read_csv(config_get(config, "subject_list"))
    subjects = subject_df["subject"].astype(str)
    sessions = config_get(config, "sessions")
    for session in sessions:
        for subject in subjects:
            preproc(config_dir, session, subject)


if __name__ == "__main__":
    args = sys.argv[1:]
    config_dir = args[0]
    batch_preproc(config_dir)
