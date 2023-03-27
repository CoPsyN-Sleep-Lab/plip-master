function [spikes moves] = get_spikes(dirn);
% lists all scans with high deviation from mean, based on timediff.mat file
% created in tsdiffana.m, and on rp*.txt file, created by spm_realign.
% Frame displacement (FD) and 


% change upper limits here
tmlimit = 10;            % mean scaled image variance
sslicedifflimit = 20;    % mean scaled mean slice variance per image
xyzlimit = .3;          % movement limit from image to image in mm taken from Power paper
%rotlimit = pi/90;      % rotation limit " in rad

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

%%% THIS ASPECT WAS TAKEN FROM POWER 2012 TO CREATE THE RMS OF MOVEMENT
%%% PARAMTERS
rpfn = spm_select('List',dirn,'^rp.*txt');
moves = [];
if (numel(rpfn) == 0),
   error(sprintf('^rp.*txt not found: No movement analysis done'));
else
   rp=spm_load(fullfile(dirn,rpfn));
   %shift to sync with scan number
   radians = rp(:, 4:6)* pi/180;
   s = radians(:, 1:3)* 50; %assuming 50mm radius sphere
   rp(:, 4:6) = s;
   rpdiff = [zeros(1,6); diff(rp)];
   absrpdiff = sum(abs(rpdiff), 2);

    for i=1:length(rpdiff),
       %high change if movement is >.2 in x,y,z or >.pi/180 in rotations
       if (absrpdiff(i) > xyzlimit),
           moves = [moves; i rpdiff(i,:)];
        end
    end;
end;

spfn = fullfile(dirn,'spikesOnly.mat');
save(spfn, 'spikes'); 

spfn = fullfile(dirn,'movesOnly.mat');
save(spfn, 'moves'); 

if(~isempty(moves) & ~isempty(spikes))
    
    spikesandmoves = vertcat(spikes, moves(:,1:3)); %added when including movements
elseif(~isempty(moves) & isempty(spikes))
    spikesandmoves = moves(:, 1:3);
elseif(isempty(moves) & ~isempty(spikes))
    spikesandmoves = spikes;
else
    spikesandmoves = [];
end
spfn = fullfile(dirn,'spikesandmoves_wFD.mat');
save(spfn, 'spikesandmoves'); 
