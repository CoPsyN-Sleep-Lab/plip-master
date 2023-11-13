#!/usr/bin/python3
import logging
import itertools
import pandas as pd
from pathlib import Path


def parallel(session_subjects, fns, NUM_WORKERS):
    import time
    from multiprocessing import Process
    procs = list()
    try:
        while session_subjects:
            procs = [proc for proc in procs if proc.is_alive()]
            if len(procs) >= NUM_WORKERS:
                time.sleep(5)
                continue
            try:
                session, subject = next(session_subjects)
            except StopIteration:
                break
            for fn in fns:
                proc = Process(target=fn, args=(config_dir, session, subject))
                proc.start()
                procs.append(proc)
        [proc.join() for proc in procs]
    except KeyboardInterrupt:
        [proc.terminate() for proc in procs]
        raise KeyboardInterrupt


def subject_level(config_dir, sessions, subjects, NUM_WORKERS=12):
    from plip.preproc.batch_preproc import preproc
    session_subjects = itertools.product(sessions, subjects)
    parallel(session_subjects, [preproc], NUM_WORKERS)

    ## comment out the below to skip ppi modeling:
    # print('skip')
    from plip.ppi.batch_ppi import roi_ppi
    # from plip.intrinsic_connectivity.batch_ic_prep import ic_prep
    session_subjects = itertools.product(sessions, subjects)
    # parallel(session_subjects, [ic_prep, roi_ppi], NUM_WORKERS)
    parallel(session_subjects, [roi_ppi], NUM_WORKERS)



def group_level(config_dir):
    log = logging.getLogger("group")
    log.info("Starting group level analysis")
    try:
        # from plip.movement.batch_movement import movement
        # movement(config_dir)
        # log.info("Generated movement files")

        from plip.betadumps.betas import batch_betadumps
        batch_betadumps(config_dir)  # Run this will multiple threads
        log.info("Betadumps complete")
        #
        # from plip.biotypes.prep_biotypes import prep_biotypes
        # files = prep_biotypes(config_dir)
        # log.info("Generated %s" % ", ".join([str(f) for f in files]))
        #
        # from plip.biotypes.compute_biotypes import create_biotype_file
        # files = create_biotype_file(config_dir, *files)
        # log.info("Biotypes are computed, generated "
        #          "%s" % ", ".join([str(f) for f in files]))
    except Exception:
        log.exception("Issue during group level processing")
    log.info("PLIP complete.  Exiting")


def run(config_dir):
    from plip.utils.config_get import config_get
    config_dir = Path(config_dir)
    config = config_dir / "config.json"
    root = config_get(config, "root")
    sessions = config_get(config, "sessions")
    subject_list = config_get(config, "subject_list")
    subjects = pd.read_csv(subject_list)["subject"].astype(str)
    # f = open("DEBUG_LOG.txt", "w+")
    # f.write("test 1")
    # f.close()
    subject_level(config_dir, sessions, subjects)

    from plip.utils.os import group_logger
    group_logger(root)
    group_level(config_dir)


if __name__ == "__main__":
    import sys
    args = sys.argv[1:]
    config_dir = args[0]
    run(config_dir)
