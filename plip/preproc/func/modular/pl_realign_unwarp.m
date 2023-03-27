function pl_realign_unwarp(directory, filename)

useScans = [1:999];
curr_directory = pwd;
cd(directory)

realignUnwarp{1}.spm.spatial.realignunwarp.data.scans = spm_select('ExtFPListRec', directory, filename, useScans);
realignUnwarp{1}.spm.spatial.realignunwarp.data.pmscan = '';
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.sep = 4;
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.rtm = 0;
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.einterp = 2;
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
realignUnwarp{1}.spm.spatial.realignunwarp.eoptions.weight = '';
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.jm = 0;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.sot = [];
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.rem = 1;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.noi = 5;
realignUnwarp{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
realignUnwarp{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
realignUnwarp{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
realignUnwarp{1}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
realignUnwarp{1}.spm.spatial.realignunwarp.uwroptions.mask = 1;
realignUnwarp{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';

spm('defaults', 'FMRI');
spm_jobman('run', realignUnwarp);

cd(curr_directory)
