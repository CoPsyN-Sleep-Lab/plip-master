function ppi_contrast(jobfile, model_dir)

jobs = repmat(jobfile, 1, 1);
inputs = cell(1, 1);
inputs{1, 1} = { fullfile(model_dir, 'SPM.mat') };
spm_jobman('serial', jobs, '', inputs{:});

