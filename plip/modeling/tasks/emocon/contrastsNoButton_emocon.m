%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.con.spmmat = '<UNDEFINED>';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'CC';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = 1;
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'CI';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [0 1];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'IC';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = [0 0 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'II';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.convec = [0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'CC-CI';
matlabbatch{1}.spm.stats.con.consess{5}.tcon.convec = [1 -1];
matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'CI-CC';
matlabbatch{1}.spm.stats.con.consess{6}.tcon.convec = [-1 1];
matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'CI-II';
matlabbatch{1}.spm.stats.con.consess{7}.tcon.convec = [0 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'II-CI';
matlabbatch{1}.spm.stats.con.consess{8}.tcon.convec = [0 -1 0 1];
matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'Faces vs Fixation';
matlabbatch{1}.spm.stats.con.consess{9}.tcon.convec = [1 1 1 1 -4];
matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

% matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'Left';
% matlabbatch{1}.spm.stats.con.consess{10}.tcon.convec = [0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'Right';
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.convec = [0 0 0 0 0 0 1];
% matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'Left-Right';
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 0 0 1 -1];
% matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Right-Left';
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.convec = [0 0 0 0 0 -1 1];
% matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';


% left = table2struct(readtable('Left_Onsets.csv'));
% right = table2struct(readtable('Right_Onsets.csv'));
% if ~isempty([left.ons]) && ~isempty([right.ons])
%     matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'Left';
%     matlabbatch{1}.spm.stats.con.consess{10}.tcon.convec = [0 0 0 0 0 1];
%     matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'Right';
%     matlabbatch{1}.spm.stats.con.consess{11}.tcon.convec = [0 0 0 0 0 0 1];
%     matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'Left-Right';
%     matlabbatch{1}.spm.stats.con.consess{12}.tcon.convec = [0 0 0 0 0 1 -1];
%     matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
%     matlabbatch{1}.spm.stats.con.consess{13}.tcon.name = 'Right-Left';
%     matlabbatch{1}.spm.stats.con.consess{13}.tcon.convec = [0 0 0 0 0 -1 1];
%     matlabbatch{1}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
% end


matlabbatch{1}.spm.stats.con.delete = 1;
