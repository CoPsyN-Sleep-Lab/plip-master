function ppi_estimate(jobfile, model_dir)

%%% GLM model estimation
nrun = 1;
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
  inputs{1, crun} = { fullfile(model_dir, 'SPM.mat') };
end

spm_jobman('serial', jobs, '', inputs{:});

