#!/usr/bin/python3

def run_matlab(config, matlab_command, *args, env={}):
    """
    Helper function to run MATLAB commands with python.

      `plip_root`: Required to include `matlab command` to path
      `spm_path`:  Required to include SPM library to path
      `matlab_command`: The MATLAB command to be run
      `*args`: Any arguments that will be given in `matlab_command`
    """
    import plip.utils.os as plipos
    from plip.definitions import PLIP_ROOT
    from plip.utils.config_get import config_get
    script = PLIP_ROOT / "utils" / "run_matlab"
    spm_path = config_get(config, "spm_path")
    MATLAB_DIR = config_get(config, ["environment", "MATLAB_DIR"])
    FSLDIR = config_get(config, ["environment", "FSLDIR"])
    args = [str(e) for e in args]
    command = [script,  PLIP_ROOT, spm_path,
               matlab_command] + args
    plipos.run_shell(command, env=env)


if __name__ == "__main__":
    print("This is meant to be imported")
