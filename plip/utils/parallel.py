#!/usr/bin/python3
# flake8: noqa
"""
Multiprocessing and Multithreading are different.
Make sure to benchmark works faster for your situation
Generally Multithreading is better for I/O bound tasks (reading/writing files)
while Multiprocessing is better for CPU bound tasks (large computation)

These are two tutorials I found helpful

Multithreading
https://www.youtube.com/watch?v=IEEhzQoKtQU

Multiprocessing
https://www.youtube.com/watch?v=fKl2JW_qrso
"""

def find_next(process_status, sessions, subjects, tasks):
    """
    ----------- anat -------------
    ------------- | --------------
    ---------- [TASKS] -----------
    ---------- preproc -----------
    --------- /       \ ----------
    -- activation  conectivity ---
    ---    |            |      ---
    ---  model        model    ---
    ---                 |      ---
    ---                ppi     ---
    ------------------------------
    Once modeling for connectivity is done
    for all tasks, ic starts
    """
    ### Focus on anatomical processing first
    for session in sessions:
        for subject in subjects:
            if process_status[session][subject]["anat"] == "not_started":
                return session, subject, "anat"

    ### Then look for functional preproc
    for session in sessions:
        for subject in subjects:
            subject_status = process_status[session][subject]
            if subject_status["anat"] != "finished": continue
            for task in tasks:
                if subject_status[task]["preproc"] == "not_started":
                    return session, subject, task, "preproc"

    ### More specialized preproc
    for session in sessions:
        for subject in subjects:
            subject_status = process_status[session][subject]
            if subject_status["anat"] != "finished": continue
            for task in tasks:
                if subject_status[task]["preproc"] != "finished": continue
                if subject_status[task]["connectivity"] == "not_started":
                    return session, subject, task, "connectivity"
                elif subject_status[task]["activation"] == "not_started":
                    return session, subject, task, "activation"

    ### Finally intrinsic connectivity and ppi
    for session in sessions:
        for subject in subjects:
            subject_status = process_status[session][subject]
            if subject_status["anat"] != "finished": continue

            ### IC
            ic_ready = all([
                subject_status[task]["connectivity"] == "finished"
                for task in tasks
            ])
            if ic_ready and subject_status["ic"] == "not_started":
                return session, subject, "ic"

            ### PPI
            for task in tasks:
                if subject_status[task]["connectivity"] != "finished": continue
                if subject_status[task]["ppi"] == "not_started":
                    return session, subject, task, "ppi" # maybe run seeds in parallel too?

def parallel_process(fn, inputs, num_workers):
    import os
    from multiprocessing import Process
    cpu_count = os.cpu_count()
    assert num_workers <= cpu_count, f"Cannot have {num_workers} workers when there are only {cpu_counts} CPUs"
    procs = list()
    while inputs:
        # Add processes
        if len(procs) < NUM_WORKERS:
            args = inputs.pop(0)
            proc = Process(target=fn, args=args)
            proc.start()
            procs.append(proc)

        ### Remove finished processes
        for proc in procs:
            if not proc.is_alive():
                # get results from thread
                proc.handled = True
        procs = [proc for proc in procs if not proc.handled]
    [proc.join() for proc in procs]


def parallel_thread(fn, inputs, num_workers):
    from threading import Thread
    threads = list()
    while inputs:
        if len(threads) < NUM_WORKERS:
            args = inputs.pop(0)
            thread = Thread(target=fn, args=args)
            thread.start()
            threads.append(thread)

        ### Remove finished threadesses
        ### Thank you https://stackoverflow.com/a/4067973/9104642
        for thread in threads:
            if not thread.is_alive():
                # get results from thread
                thread.handled = True
        threadss = [thread for thread in threads if not thread.handled]
    [thread.join() for thread in threads]

