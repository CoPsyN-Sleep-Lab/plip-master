%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.con.spmmat = '<UNDEFINED>';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'Look_Neutral';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = 1;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Look_Negative';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Decrease_Negative';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = [0 0 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'Negative - Neutral';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = [-2 1 1 ];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'Neg Look - Neg Decrease';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = [0 1 -1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Negative Images';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.convec = [0 1 1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'All Images';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.convec = [1 1 1];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Keypress';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = [0 0 0 1];


% Keypress = table2struct(readtable('KeyPress_Onsets.csv'));
% if ~isempty([Keypress.ons])
%     matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Keypress';
%     matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = [0 0 0 1];
% end

matlabbatch{1}.spm.stats.con.delete = 1;
