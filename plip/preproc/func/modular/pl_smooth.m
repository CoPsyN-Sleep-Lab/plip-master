function pl_smooth(directory, filename, s)
s = str2num(s);

useScans = [1:999];
curr_directory = pwd;
cd(directory)

smooth8mm{1}.spm.spatial.smooth.data = spm_select('ExtFPListRec', directory, filename, useScans);
smooth8mm{1}.spm.spatial.smooth.fwhm = [s s s];
smooth8mm{1}.spm.spatial.smooth.dtype = 0;
smooth8mm{1}.spm.spatial.smooth.im = 0;
smooth8mm{1}.spm.spatial.smooth.prefix = 's';

spm('defaults', 'FMRI');
spm_jobman('run', smooth8mm);

cd(curr_directory)
