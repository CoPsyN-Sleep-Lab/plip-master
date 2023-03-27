%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = '<UNDEFINED>';


matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Targets';
Target = table2struct(readtable('Target_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [Target.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});


matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Non Targets';
NonTarget = table2struct(readtable('NonTarget_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [NonTarget.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});


matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Baseline';
Baseline = table2struct(readtable('Baseline_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [Baseline.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});


load('spike_regressors_wFD.mat')

dlmwrite('spikes_FD_only_regressors.txt', [spike_regressors])
if ~isempty(spike_regressors)
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(pwd, 'spikes_FD_only_regressors.txt')};
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
