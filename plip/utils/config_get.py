#!/usr/bin/python3
# FIXME: extend this so that a config can point to another config
# reducing verbosity and allowing for a default config
import sys
from pathlib import Path
import plip.utils.os as plipos
from os.path import isdir, isfile


def config_get(config_path, keys):
    config_path = Path(config_path)
    assert config_path.is_file(), (f"The config path \"{config_path}\" "
                                   "does not exist")
    info = plipos.load_json(config_path)

    if type(keys) == str:
        assert keys in info, "Cannot find in config value for %s" % keys
        info = info[keys]
    else:
        for k in keys:
            assert k in info, ("Cannot find in config value for "
                               "%s" % " --> ".join(keys))
            info = info[k]
    if type(info) == str and (isfile(info) or isdir(info)):
        info = Path(info)
    return info


if __name__ == "__main__":
    args = sys.argv[1:]
    config_path = args[0]
    keys = args[1:]
    value = config_get(config_path, keys)
    if type(value) == dict:
        value = " ".join(value.keys())
    elif type(value) == list:
        value = " ".join(value)
    print(value, end="")
