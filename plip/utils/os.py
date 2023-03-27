#!/usr/bin/python3
import time
from pathlib import Path


def load_json(fp):
    import json
    with open(fp, "r") as f:
        return json.load(f)


def run_shell(command, env=dict(), verbose=True):
    from subprocess import Popen, PIPE, STDOUT
    command = [str(e) for e in command]
    print(" ".join(command))
    p = Popen(" ".join(command), stdout=PIPE, stderr=STDOUT, shell=True,
              env=env)
    while True:  # Print all output from running MATLAB
        line = p.stdout.readline()
        if not line:
            break
        line = line.decode("utf-8")
        print(line.replace("\n", ""))
    while p.poll() is None:
        time.sleep(0.5)
    code = p.returncode
    assert code == 0, f"Exit code {code} from {command}"


def rmtree(directory):
    import shutil
    directory = Path(directory)
    if not directory.is_dir():
        return
    try:
        shutil.rmtree(directory)
    except Exception:
        print(f"WARNING.  WARNING.  WARNING.  Trouble deleting {directory}.  "
              "Possibly because files cannot be deleted.  Please check for "
              "hidden .nfs files and ensure this error does not affect "
              "processing.")


def makedirs(directory):
    if type(directory) == str:
        directory = Path(directory)
    directory.mkdir(parents=True, exist_ok=True)


def is_file(fp):
    fp = Path(fp)
    if str(fp).endswith(".nii"):
        return fp.is_file() or fp.append_suffix(".gz").is_file()
    elif str(fp).endswith(".nii.gz"):
        return fp.is_file() or fp.with_suffix("").is_file()
    return fp.is_file()


def gzip(src):
    import gzip
    src = Path(src)
    dst = src.with_suffix(".nii.gz")
    assert str(src).endswith(".nii"), "gzip method will not work on %s" % src
    assert not dst.is_file(), "%s already exists.  Cannot gzip file" % dst
    with open(src, 'rb') as unzipped_file:
        with gzip.open(dst, 'wb') as zipped_file:
            zipped_file.writelines(unzipped_file)


def gunzip(src, dst):
    import gzip
    dst = Path(dst)
    assert str(src).endswith(".nii.gz"), "gzip method will not work on {src}"
    assert dst.is_file(), "%s already exists.  Cannot gzip file" % dst
    with gzip.open(src, 'rb') as zipped_file:
        with open(dst, 'wb') as unzipped_file:
            unzipped_file.writelines(zipped_file)


def cleanup(directory):
    from tqdm import tqdm
    directory = Path(directory)
    assert directory.is_dir(), "%s does not exist" % directory
    niftis = list(directory.glob("*.nii"))
    for nifti_path in tqdm(niftis):
        gzip(nifti_path)
        nifti_path.unlink()


def mv(src, dst, overwrite=False):
    src = Path(src)
    dst = Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    src.rename(dst)


def copy(src, dst, overwrite=False):
    import shutil
    src = Path(src)
    dst = Path(dst)
    if dst.is_file() and not overwrite:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(src, dst)


def touch(fp):
    fp = Path(fp)
    fp.parent.mkdir(parents=True, exist_ok=True)
    fp.touch()


def modified_time(filepath):
    from os.path import getmtime
    return getmtime(filepath)


def modified_after(early_file, late_file):
    # FIXME: this will be so helpful for skipping pipeline sections
    early_time = modified_time(early_file)
    late_time = modified_time(late_file)
    return early_time < late_time


def setup_logger(logfile, logname):
    import logging
    logfile = Path(logfile)
    if not logfile.is_file():
        logfile.parent.mkdir(parents=True, exist_ok=True)
        with open(logfile, "w") as f:
            f.write("time,level,filename,function,line_number,message\n")
    formatter = logging.Formatter("%(asctime)s,%(levelname)s,%(filename)s,"
                                  "%(funcName)s,%(lineno)d,%(message)s")
    logger = logging.getLogger(logname)
    logger.setLevel(logging.DEBUG)

    # File handler
    file_handler = logging.FileHandler(logfile)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    # Stream handler
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)

    logger.info("Logger recording")


def subject_logger(root, session, subject, stage):
    root = Path(root)
    logfile = root / "logs" / stage / f"{session}_{subject}.log"
    logname = f"{stage}_{session}_{subject}"
    setup_logger(logfile, logname)


def group_logger(root):
    root = Path(root)
    logfile = root / "logs" / "group.log"
    setup_logger(logfile, "group")
