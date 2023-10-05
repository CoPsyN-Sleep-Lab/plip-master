function ppi_stats(jobfile, smri_brain_mask, model_dir, filename, TR)

TR = str2double(TR);
prev_dir = pwd;
cd(model_dir)

%%% GLM model setup
nrun = 1;
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
[files,dirs] = spm_select('ExtFPList', model_dir, filename, Inf); % Used for SPM 12
for crun = 1:nrun
  inputs{1, crun} = { model_dir };
  inputs{2, crun} = TR;
  %// inputs{3, crun} = spm_select('ExtFPListRec', model_dir, filename, [1:999]);
  inputs{3, crun} = cellstr(files); % Used for SPM 12
  inputs{4, crun} = { smri_brain_mask };
end
spm_jobman('serial', jobs, '', inputs{:});

cd(prev_dir)
