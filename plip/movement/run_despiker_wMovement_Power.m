function [vols, spike_regressors] = run_despiker(P)
% Runs despiker on given directory [P is a list of directories from spm_select of the volumes of the .nii]
%E dited 2/25/16 to fix issue with last volume being included in regressor
% bot not actually regressed out.s
dirn = pwd;
if exist(fullfile(dirn, 'spike_regressors_wFD.mat'), 'file')
    delete(fullfile(dirn,'spike_regressors_wFD.mat'))
end
spikes = get_spikes_wMovement_Power(dirn); % returns spikes from variance as well as frame displacements.

if isempty(P)
  error(['Found no matching images in ', dirn]);
end

if (isempty(spikes))
  spike_regressors=[];
  vols = [];
  spfn = fullfile(dirn,'spike_regressors_wFD.mat');
  save(spfn, 'spike_regressors');
  return
end
spikes = spikes(:,1);
spikes = [spikes spikes+1];
spikes = sort(unique(spikes(:)));


%vols = replace_vols_series_4d(P, spikes,'discarded_volumes'); %for 4d files need the _4d replace volumes image.
n_vols = size(P, 1);

spikes = spikes(find(spikes<=n_vols));

n_spikes = numel(spikes);

spike_regressors = zeros(n_vols, n_spikes);

for sno = 1:n_spikes
    if(spikes(sno) <= n_vols)
        spike_regressors(spikes(sno),sno) = 1;
    end
end
spfn = fullfile(dirn,'spike_regressors_wFD.mat');
save(spfn, 'spike_regressors');
