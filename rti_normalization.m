function [ normalized_rti ] = rti_normalization( filtered_rti )
%RTI_NORMALIZATION Normalization of the intensity values for each voxel of 
%the RTI image in the range [0 1].

%   filtered_rti    RTI image after thresholding proccess
%   normalized_rti  Normalized RTI image after thresholding


size_filtered_rti = size(filtered_rti);
nsteps = size_filtered_rti(3);
max_rti = max(max(filtered_rti));
normalized_rti = zeros(size_filtered_rti);
for step = 1:nsteps
    normalized_rti(:,:,step) = filtered_rti(:,:,step)./max_rti(:,:,step);
end

end

