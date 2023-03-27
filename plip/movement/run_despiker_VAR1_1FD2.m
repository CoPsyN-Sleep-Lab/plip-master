function [vols, spike_regressors] = run_despiker(P)

dirn = pwd;

[spikes, moves] = get_spikes_wMovement_Power_092215(dirn); % returns spikes from variance as well as frame displacements.

if isempty(P)
  error(['Found no matching images in ', dirn]);
end
if (isempty(spikes) & isempty(moves))
  spike_regressors=[];
  vols = [];
  return
end

if(~isempty(spikes))
    spikes = spikes(:,1);
    spikes = [spikes spikes+1];
    spikes = sort(unique(spikes(:)));
end
if(~isempty(moves))
    moves = moves(:, 1);
    moves = [moves-1 moves moves+1 moves+2];
    moves = sort(unique(moves(:)));
end

spikes = sort(unique([moves; spikes]));
%vols = replace_vols_series_4d(P, spikes,'discarded_volumes'); %for 4d files need the _4d replace volumes image.
n_spikes = numel(spikes);
n_vols = size(P, 1); 
spike_regressors = zeros(n_vols, n_spikes);
for sno = 1:n_spikes
    if(spikes(sno) <= n_vols)
        spike_regressors(spikes(sno),sno) = 1;
    else
        spike_regressors = spike_regressors(:, 1:sno-1);
        break
    end
end
spfn = fullfile(dirn,'spike_regressors_VAR1_1FD2.mat');
save(spfn, 'spike_regressors');

