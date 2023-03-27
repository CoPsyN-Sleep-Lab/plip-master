function pl_slice_timing(directory, filename, TR, order)
%%% FIXME: This should work for arbitrary slice order

%%%%%%
% A more persistant problem is the slice order. Different CRCS at different times have prescribed both and ascending or descending order.
% The default now is to check the slice order csv that must be checked into the config file, and then execute the proper slice time correction
%%%%%%

TR = str2num(TR);
useScans = [1:999];

% gets number os slices from the header, has been checked for accuracy
tempStruct = spm_read_hdr(fullfile(directory, filename));
curSlices = tempStruct.dime.dim(4);

%%% Run slice time correction
P = spm_select('ExtFPListRec', directory, filename, useScans);
sliceTime{1}.spm.temporal.st.scans = { P };
sliceTime{1}.spm.temporal.st.nslices = curSlices;
sliceTime{1}.spm.temporal.st.prefix = 'a';
if strcmp(order, 'ascending')
    sliceTime{1}.spm.temporal.st.so = [1:2:curSlices 2:2:curSlices];
    sliceTime{1}.spm.temporal.st.refslice = curSlices;
elseif strcmp(order, 'descending')
    sliceTime{1}.spm.temporal.st.so = [flip(1:2:curSlices) flip(2:2:curSlices)];
    sliceTime{1}.spm.temporal.st.refslice = 1;
elseif strcmp(order, 'ascending_seq')
    sliceTime{1}.spm.temporal.st.so = [1:curSlices];
    sliceTime{1}.spm.temporal.st.refslice = curSlices;
end
sliceTime{1}.spm.temporal.st.tr = TR;
sliceTime{1}.spm.temporal.st.ta = TR - (TR/curSlices);
spm_jobman('run', sliceTime);

