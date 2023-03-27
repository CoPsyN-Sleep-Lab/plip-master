%----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
% This was created by Patrick, you might want to modify it
fileTest = pwd;
matlabbatch{1}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = '<UNDEFINED>';

ant_win_5 = table2struct(readtable('win_5_anticipation.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Anticipation Win 5';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [ant_win_5.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = [ant_win_5.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
ant_win_0 = table2struct(readtable('win_0_anticipation.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Anticipation Win 0';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [ant_win_0.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = [ant_win_0.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
ant_lose_5 = table2struct(readtable('lose_5_anticipation.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Anticipation Lose 5';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [ant_lose_5.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = [ant_lose_5.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
ant_lose_0 = table2struct(readtable('lose_0_anticipation.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Anticipation Lose 0';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = [ant_lose_0.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = [ant_lose_0.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});

con_win_5 = table2struct(readtable('win_5_consumption.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Consumption Win 5';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = [con_win_5.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = [con_win_5.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
con_win_0 = table2struct(readtable('win_0_consumption.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Consumption Win 0';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = [con_win_0.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = [con_win_0.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
con_lose_5 = table2struct(readtable('lose_5_consumption.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Consumption Lose 5';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = [con_lose_5.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = [con_lose_5.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
con_lose_0 = table2struct(readtable('lose_0_consumption.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).name = 'Consumption Lose 0';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).onset = [con_lose_0.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).duration = [con_lose_0.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask = '<UNDEFINED>';
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
