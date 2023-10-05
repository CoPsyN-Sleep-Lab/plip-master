function copsyn_pl_tsdiffana(directory, filename)
prev_dir = pwd;
cd(directory);

useScans = [1:999];

% FIXME: Woah, oddly the following line does not work.  Gives a huge difference
% in image with no error raised - PCS
% P = spm_select('ExtFPList', directory, filename, useScans);
P = spm_select('ExtFPList', directory, [sprintf('^%s$', filename)], useScans);

tsdiffana(P);

% No scrubbing with frame displacements
run_despiker_wMovement_Power(P);

% Create expanded spike regressors for Frame displacements if missing originally
% Generates VAR1_FD1 file
run_despiker_VAR1_1FD2(P);

%Q = 'snr.nii';
%Q = spm_imcalc_ui(P(:, :),Q,'mean(X)./std(X)', {1;-1;'float64';0});
cd(prev_dir);
