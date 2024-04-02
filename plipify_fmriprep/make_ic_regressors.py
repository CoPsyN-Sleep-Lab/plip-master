import sys
import pandas as pd
import numpy as np
from scipy.io import loadmat, savemat


if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} /path/to/filename.tsv /path/to/confounds_filtered.mat", file=sys.stderr)
    sys.exit(1)

# Parse the input arguments
tsv_file = sys.argv[1]
confounds_path = sys.argv[2]


## 1. rp_01_reorient.csv -- creates csv file of 6 movement params [trans_x, trans_y, trans_Z, rot_x, rot_y, rot_z], extracted from fmriprep confounds files. Placed in plip preproc directory. 

print('Making 6-param movement file ...')
movement_df = pd.read_csv(tsv_file, sep='\t')
movement_df = movement_df[['trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z']]
movement_df = movement_df.drop(movement_df.index[:3]) ## remove 3 dummy volumes
movement_df.to_csv('rp_01_reorient.csv', header=False, index=False)
print("Success")


## 2. spikes/outlier volumes -- creates .mat file (named spike_regressors_VAR1_1FD2.mat) containing array named 'spike_regressors)'
print("Making spike regressors ...")
data = loadmat(confounds_path)
data_array = data['data']
data_array = data_array[:, 14:] ## get just the outlier regressors
spike_regressors = data_array ## rename array
modified_data = {'spike_regressors': spike_regressors}
savemat('spike_regressors_VAR1_1FD2.mat', modified_data)
print("Success")