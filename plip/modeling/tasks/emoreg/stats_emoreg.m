%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
fileTest = pwd;

matlabbatch{1}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = '<UNDEFINED>';

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Look_Neutral';
Look_Neutral = table2struct(readtable('Look_Neutral_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [Look_Neutral.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = [4];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Look_Negative';
Look_Negative = table2struct(readtable('Look_Negative_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [Look_Negative.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = [4];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Decrease_Negative';
Decrease_Negative = table2struct(readtable('Decrease_Negative_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [Decrease_Negative.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = [4];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});

Keypress = table2struct(readtable('KeyPress_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Keypress';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = [Keypress.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = [0];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});

%load('spike_regressors_wFD.mat') %% ajk edit -- replacing confound file to
%use the fmriprep-derived confounds_filtered.mat
load('confounds_filtered.mat')

dlmwrite('confounds_filtered.txt', [data])
if ~isempty(data)
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(pwd, 'confounds_filtered.txt')};
else
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});

end

matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
