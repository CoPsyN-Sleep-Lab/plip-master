%-----------------------------------------------------------------------
% Job saved on 09-Aug-2015 22:31:16 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
function [matlabbatch] = P50_tapas_physio_spm_job(physio_in,physio_out,TR,Nslices, mb_factor, Nscans, onset_slice,rp_dir)
matlabbatch{1}.spm.tools.physio.save_dir = {physio_out};
matlabbatch{1}.spm.tools.physio.log_files.vendor = 'GE';
[cardiac_data,dirs]=spm_select('FPList',physio_in,'PPGData'); % PPG data
[resp_data,dirs]=spm_select('FPList',physio_in,'RESPData'); % Resp data
matlabbatch{1}.spm.tools.physio.log_files.cardiac = {cardiac_data};
matlabbatch{1}.spm.tools.physio.log_files.respiration = {resp_data};
matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [0.01 0.04];%[cardiac_sample, resp_sample]
matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = Nslices/mb_factor; % total slices / multiband factor
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = TR;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = Nscans;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = onset_slice; % 8, near nucleus accumbens
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'physio_retroicor_rvhr.txt';
matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
matlabbatch{1}.spm.tools.physio.model.rvt.yes.delays = 0;
matlabbatch{1}.spm.tools.physio.model.hrv.yes.delays = 0;
%% motion
% matlabbatch{1}.spm.tools.physio.model.movement.no = struct([]);
[rp_reg,dirs] = spm_select('FPList',rp_dir,'rp_');
matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {rp_reg};
matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 24;
matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'none';
matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;

matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
matlabbatch{1}.spm.tools.physio.verbose.level = 1; % 3 > 2 > 1 in details
matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;

