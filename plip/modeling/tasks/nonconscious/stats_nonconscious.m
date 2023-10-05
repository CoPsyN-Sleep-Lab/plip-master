%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = '<UNDEFINED>';

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Neutral';
Neutral = table2struct(readtable('Neutral_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [Neutral.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Happy';
Happy = table2struct(readtable('Happy_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [Happy.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Fear';
Fear = table2struct(readtable('Fear_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [Fear.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Anger';
Anger = table2struct(readtable('Anger_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = [Anger.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Sad';
Sad = table2struct(readtable('Sad_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = [Sad.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Disgust';
Disgust = table2struct(readtable('Disgust_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = [Disgust.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = [10];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});

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
