#!/usr/bin/python3
def betadump(filepath, mask_path):
    import sys
    from path import Path
    sys.path.append(Path(__file__).absolute().parent)
    from fsl_commands import fsl_command
    return fsl_command("fslstats", filepath, "-k", mask_path, "-m")


if __name__ == "__main__":
    raise Exception("This is meant to be imported")
