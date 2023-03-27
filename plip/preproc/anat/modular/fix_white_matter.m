function fix_white_matter(src, dst)
% FIXME: This keeps referring to white matter, but it's used for grey matter and csf too

voxThreshold = 2000;

disp('eroding volume ... ');
wm_hdr = spm_vol(src);
wm_vol = spm_read_vols(wm_hdr);
wm_dims = size(wm_vol);
temp = reshape(wm_vol, 1, prod(wm_dims));
vox_left = length(find(temp));

%%% erode till there are under 1000 voxels left.
% ^ FIXME: This doesn't match the threshold above?
count = 1;
%while(vox_left >= voxThreshold)
for i=1:1:3
    wm_vol = spm_erode(wm_vol);
    temp = reshape(wm_vol, 1, prod(wm_dims));
    vox_left = length(find(temp));
    disp(sprintf('Finished erosion %d --> %d voxels remaining in volume.', count, vox_left))
    count = count + 1;
end

%%% binarize
disp('Binarizing remaining voxels   ...')
temp = reshape(wm_vol, 1, prod(wm_dims));
temp(find(temp)) = 1;
wm_vol = reshape(temp, wm_dims);

% apend info about number of voxels in this mask to the end of the descrip field.
wm_hdr.fname = dst;
wm_hdr.descrip = sprintf('%s #vox: %d', wm_hdr.descrip, vox_left);

spm_write_vol(wm_hdr, wm_vol); % write

disp('completed segmention.  All set to get resting connectivity');

