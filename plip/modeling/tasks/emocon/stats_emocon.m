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

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'CC';
CC = table2struct(readtable('CC_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [CC.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'CI';
CI = table2struct(readtable('CI_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = [CI.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'IC';
IC = table2struct(readtable('IC_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = [IC.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'II';
II = table2struct(readtable('II_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = [II.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Fixation';
fixation = table2struct(readtable('fixation_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = [fixation.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = [fixation.dur];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Left';
left = table2struct(readtable('Left_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = [left.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Right';
right = table2struct(readtable('Right_Onsets.csv'));
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = [right.ons];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = [1];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});

%% old method to deal with missing button-presses
% left = table2struct(readtable('Left_Onsets.csv'));
% right = table2struct(readtable('Right_Onsets.csv'));
% if ~isempty([left.ons]) && ~isempty([right.ons])
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Left';
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = [left.ons];
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = [1];
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Right';
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = [right.ons];
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = [1];
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;
%   matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
% end
%%


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
