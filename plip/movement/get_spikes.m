function [spikes] = get_spikes(dirn);
% lists all scans with high deviation from mean, based on timediff.mat file
% created in tsdiffana.m, and on rp*.txt file, created by spm_realign.

% change upper limits here
tmlimit = 10;            % mean scaled image variance
sslicedifflimit = 20;    % mean scaled mean slice variance per image
xyzlimit = .3;          % movement limit from image to image in mm
rotlimit = pi/90;      % rotation limit " in rad

if isempty(dirn)
  error('Need directory name');
end
tdfn = fullfile(dirn,'timediff.mat');

try
load (tdfn, 'td', 'globals', 'slicediff');
catch
    error(sprintf('%s not found: Please run tsdiffana first',tdfn));
end

tm = td/mean(globals);
mslicediff = mean(slicediff,2);
sslicediff = mslicediff/mean(mslicediff);
spikes = [];

for i=1:length(tm),
    % high change if squared diff > limits
    if (tm(i) > tmlimit || sslicediff(i) > sslicedifflimit), 
        spikes = [spikes; i tm(i) sslicediff(i)];
    end
end;


%rpfn = spm_select('List',dirn,'^rp.*txt');
%moves = [];
%if (numel(rpfn) == 0),
%    error(sprintf('^rp.*txt not found: No movement analysis done'));
%else
 %   rp=spm_load(fullfile(dirn,rpfn));
    % shift to sync with scan number
  %  rpdiff = [zeros(1,6); diff(rp)];
   % absrpdiff = abs(rpdiff);

    %for i=1:length(rpdiff),
        %high change if movement is >.2 in x,y,z or >.pi/180 in rotations
     %   if (mean(absrpdiff(i,1:3) > xyzlimit) > 0 ||...
      %          mean(absrpdiff(i,4:6) > rotlimit) > 0),
       %     moves = [moves; i rpdiff(i,:)];
        %end
    %end;
%end;


spfn = fullfile(dirn,'spikesandmoves.mat');
save(spfn, 'spikes');

