#!/usr/bin/python3
import os
from subprocess import check_output
import pathlib
from plip.utils.fsl_in_docker import fsl_in_docker


def fsl_command(command, *args):
    """
    Runs an FSL command and returns the response
    NOTE: The response may be bytes and you also
    need to remove the newlines
    """
    fsldir = os.environ["FSLDIR"]
    command = ["%s/bin/%s" % (fsldir, command)]
    command.extend(args)
    return check_output(command)


def fsl_warp(directory_info, **kwargs):
    """ A slightly easier interface to run FSL's `applywarp` in Docker """
    args = list()
    for key, value in kwargs.items():
        if type(value) == pathlib.PosixPath:
            value = str(value)
        # fixes the unknown paths in config
        value = value.format_map(directory_info)
        if key in ["premat", "interp", "interp", "postmat"]:
            args.extend([f"--{key}={value}"])
        else:
            args.extend([f"-{key}", str(value)])
    fsl_in_docker("applywarp", *args)


def fsl_convert(files, output_type="NIFTI"):
    """ Convert list of files to `output_type` """
    for f in files:
        fsl_command("fslchfiletype", output_type, f)


if __name__ == "__main__":
    import sys
    command = sys.argv[1]
    args = sys.argv[2:]
    fsl_command(command, args)
