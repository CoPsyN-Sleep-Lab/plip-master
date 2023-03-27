function [imdiff, g, slicediff] = timediff(imgs, flags)
% Analyses slice by slice variance across time series
% FORMAT [imdiff, g, slicediff] = timediff(imgs, flags)
%
% imgs   - string or cell or spm_vol list of images
% flags  - specify options; if contains:
%           m - create mean var image (vmean*), max slice var image
%               (vsmax*) and scan to scan variance image (vscmean*) 
%           v - create variance image for between each time point
%
% imdiff - mean variance between each image in time series
% g      - mean voxel signal intensity for each image
% slicediff - slice by slice variance between each image 
%
% Matthew Brett 17/7/00
  
[imdiff, g, slicediff] = deal([]);
if nargin < 1
  imgs = [];
end
if isempty(imgs)  
  imgs = cbu_get_imgs(Inf, 'Select time series images');
end
if isempty(imgs), return, end
if iscell(imgs)
  imgs = char(imgs);
end
if ischar(imgs)
  
  imgs = spm_vol(imgs);
  
end
if nargin < 2
  flags = 'm';
end

nimgs = size(imgs,1);
if isempty(nimgs) | nimgs < 2
  return
end
V1 = imgs(1);
Vr = imgs(2:end); 

ndimgs = nimgs-1;
Hold = 0;

if any(flags == 'v') % create variance images across whole brain does this one slice at a time
  for i = 1:ndimgs
    vVr(i) = makevol(Vr(i),'v',16); % float
  end
end
if any(flags == 'm') % mean /max variance 
  mVr = makevol(V1,'vmean',16); 
  sVr = makevol(V1,'vscmean',16);
  xVr = makevol(V1,'vsmax',16);
end

[xydim zno] = deal(V1.dim(1:2),V1.dim(3));

p1 = spm_read_vols(V1);
slicediff = zeros(ndimgs,zno); %size = number of TRs-1 x Number of slices slice by slice variance 
g = zeros(ndimgs,1);
for z = 1:zno %for each slize
  M = spm_matrix([0 0 z]);
  pr = p1(:,:,z);
  if any(flags == 'm')
    [mv sx2 sx mxvs]  = deal(zeros(size(pr)));
  end
  cmax = 0;
  for i = 1:ndimgs % for each TR
    c = spm_slice_vol(Vr(i),M,xydim,Hold); %current Z at current TR (e.g. 64 x 64 dimensional matrix)
    v = (c - pr).^2; %squared difference from one TR to the next at each voxel in the plane
    slicediff(i,z) = mean(v(:)); % mean squared difference for current slice; Seems to be calculating DVARS but per slice rather than whole brain
    g(i) = g(i) + mean(c(:)); % mean signal at current slice
    if slicediff(i,z)>cmax
      mxvs = v;
      cmax = slicediff(i,z);
    end
    pr = c;
    if any(flags == 'v')
      vVr(i) = spm_write_plane(vVr(i),v,z);
    end
    if any(flags == 'm')
      mv = mv + v;
      sx = sx + c; % sum of intensity
      sx2 = sx2 + c.^2; %sum of squared intensity
    end
  end
  if any(flags == 'm') % mean variance etc
    sVr = spm_write_plane(sVr,mv/(ndimgs-1),z); %average squared difference for current slice
    xVr = spm_write_plane(xVr,mxvs,z); %max variance for image and slice
    mVr = spm_write_plane(mVr,(sx2-((sx.^2)/ndimgs))./(ndimgs-1),z); %Sum of squared intensity - the squared intensity per image     
  end      
end
if any(findstr(spm('ver'), '99'))
   spm_close_vol([vVr sVr xVr mVr]);
end

g = [mean(p1(:)); g/zno]; % sum of signal divided by the number of slices; average signal per slice
imdiff = mean(slicediff')';

return

function Vo = makevol(Vi, prefix, datatype)
Vo = Vi;
fn = Vi.fname;
[p f e] = fileparts(fn);
Vo.fname = fullfile(p, [prefix f e]);
switch spm('ver')
  case 'SPM12'
    Vo.dt = [datatype 0];
    Vo = spm_create_vol(Vo);
  case 'SPM8'
  Vo.dt = [datatype 0];
  Vo = spm_create_vol(Vo, 'noopen');
    case 'SPM5'
  Vo.dt = [datatype 0];
  Vo = spm_create_vol(Vo, 'noopen');
 case 'SPM2'
  Vo.dim(4) = datatype;
  Vo = spm_create_vol(Vo, 'noopen');
 case 'SPM99'
  Vo.dim(4) = datatype;
  Vo = spm_create_image(Vo);
 otherwise
  error(sprintf('What ees thees version "%s"', spm('ver')));
end
return
    



