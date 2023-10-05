import sys
import pandas as pd
import numpy as np
from scipy.io import savemat

if len(sys.argv) != 4:
    print(f"Usage: {sys.argv[0]} /path/to/filename.tsv subject nuisance_params", file=sys.stderr)
    sys.exit(1)

# Parse the input arguments
tsv_file = sys.argv[1]
subject = sys.argv[2]
nuisance_params = sys.argv[3]

# Load the data from the TSV file using pandas
print(f"Loading data from {tsv_file}")
df = pd.read_csv(tsv_file, sep='\t')

## load in the nuisance_params list to filter the confounds.tsv file
with open(nuisance_params, 'r') as f: 
    list_str = f.read()

nuisance_params = eval(list_str)


nuisance_cols = df.loc[:, nuisance_params]
motion_cols = df.filter(regex='^motion_outlier_*')

## edit motion_outlier columns to censor volumes 1 before/2 after detected-spike
for col in motion_cols.columns:
    # find the index of the first 1 in the column
    index = motion_cols[col].idxmax()
    # set the previous and next two values to 1, if they exist
    if index > 0:
        motion_cols[col].iloc[index-1:index+3] = 1
    elif index == 0:
        motion_cols[col].iloc[:3] = 1
    elif index == len(df)-1:
        motion_cols[col].iloc[-3:] = 1


## count and save the total number of spike volumes
badvols = set()
for row in motion_cols.itertuples(index=False):
    if 1 in row:
        badvols.add(row)
percent = round((len(badvols) / motion_cols.shape[0]) * 100 ,1)
filename = f"OutlierVolInfo_total-{len(badvols)}_perc-{percent}.txt"
with open(filename, "w") as f:
    f.write(("Total outlier volumes: " + str(len(badvols)) + "\nPercent outlier volumes: " + str(percent)))
print(f"Outlier Volume Info saved to {filename}")


denoise_regressors_df = pd.concat([nuisance_cols, motion_cols], axis=1)

## cut first three rows corresponding to dummy-scans
denoise_regressors_df = denoise_regressors_df[3:]
data=denoise_regressors_df.values

# Construct the output filename with the subject
output_filename = f"{tsv_file[:-4]}_filtered.mat"

# Save the data to a MAT file
print(f"Saving data to {output_filename}")
savemat(output_filename, {'data': data})

print(f"Created {output_filename}")



