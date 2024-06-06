# PLIP

### Installation

```
git clone https://github.com/CoPsyN-Sleep-Lab/plip-copsyn/tree/main
cd plip-master
pip3 install .
```

### Updating code

To reflect modifications to master code run the following commands while in the repository root

```
git pull origin main
pip3 unstall plip
pip3 install .
```

It's possible the uninstall does not delete all old files.  This is particularly an issue with matlab files.  Double check with Patrick if things work properly

### Running code

To run the full pipeline do (NOTE: the only input variable is the full path to your config directory)

```
python3 plip/pipeline.py $config_dir
```

Sections of the code can also be run.  For instance, just preproc and 1st level modeling can be done with

```
python3 plip/preproc/batch_preproc.py $config_dir
```

### Config

To run any part of plip an configuration directory needs to be specified.  There is a sample one provided for you in `config`.  Generally most people will only modify the `config.json`, but if you have special cases you can update any of them

### Project structure

PLIP requires a very definite input folder structure such as the following.  NOTE: for MRI, the filename doesn't matter, but the folder does.  There can be no duplicate `*.nii*` files in that folder.  Also important to mention is that the logfiles are already parsed and onsets are created.  For CSVs, please refer to subjects as `subject`, tasks as `task`, and sessions as `session` as column names

```
$root/raw/s1/$subject/$task/*.nii*
$root/raw/s1/$subject/$t1_type/*.nii*
$root/button/$subject/$session/$task/onsets/*.csv
$root/slice_timing.csv
$root/average_onsets.csv # if applicable
$root/button/average_onsets/$task/*.csv # if applicable
```

### Processing steps

Please see the [readme](plip#toc) under the `plip` folder for details

### Masks available

If you do not have access to the Oak server, the relevant masks are provided in this repo under `plip/data/masks.zip`.  Unzip this file and set the `mask_dir` variable in the config to its paths

### Docker

PLIP should detect automatically if singularity (preferred) or Docker is available on your system.  If it doesn't it may not be in your path (try `which singularity` or `which docker` and see if anything comes up).

### Common issues

- Make sure all the variables are updated in the [`config.json`](config/config.json). Some of the values there are specific to the PANLab attention and reward servers

- It's possible a Docker issue will affect the pipeline.  Docker has trouble mounting the `/usr` folder on Mac. You need to explicitly allow Docker to use this.  Follow the answer [here](https://stackoverflow.com/questions/57819352/docker-desktop-for-macos-cant-add-usr-local-folder-in-preferences-file-sharing/60554414#60554414) and restart Docker on your computer.
    - You may need to increase the Memory from 2GB to 8GB or else Docker will give you a cryptic "killed" message
