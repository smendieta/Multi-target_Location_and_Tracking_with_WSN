function [ filtered_rti ] = detection_thresholding( rss_change_estimate,Tt )
%DETECTION_THRESHOLDING Filters the RSS change estimation with a vector
%mask [0 1] depending if the signal levels reach a threshold
%   rss_change_estimate     Estimated changes in RSS by each voxel
%   calibration_steps       Number of frames when the area is empty
%   filtered_rti            Filtered RTI image according to a threshold

    global istarget;
    
    % Initial parameters
    size_rss_change = size(rss_change_estimate);
    
    % Output initialization
    filtered_rti = zeros(size_rss_change);
    
    for voxel_y = 1:size_rss_change(2)
        for voxel_x = 1:size_rss_change(1)
            if (istarget) && (Tt(2) > Tt(1))                
                if rss_change_estimate(voxel_x,voxel_y)>Tt(2)
                    filtered_rti(voxel_x,voxel_y) = rss_change_estimate(voxel_x,voxel_y);
                else
                    filtered_rti(voxel_x,voxel_y) = 0;
                end
            else
                if rss_change_estimate(voxel_x,voxel_y)>Tt(1)
                    % Target can be present at least if Imin > Tt(1) = 2*Ie
                    filtered_rti(voxel_x,voxel_y) = rss_change_estimate(voxel_x,voxel_y);
                else
                    filtered_rti(voxel_x,voxel_y) = 0;
                end
            end
        end
    end                
               
                    
                    

end

