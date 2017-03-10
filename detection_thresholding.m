function [ filtered_rti ] = detection_thresholding( rss_change_estimate, calibration_steps )
%DETECTION_THRESHOLDING Filters the RSS change estimation with a vector
%mask [0 1] depending if the signal levels reach a threshold
%   rss_change_estimate     Estimated changes in RSS by each voxel
%   calibration_steps       Number of frames when the area is empty
%   filtered_rti            Filtered RTI image according to a threshold
    
    % Initial parameters
    size_rss_change = size(rss_change_estimate);
    nsteps = size_rss_change(3);
    alfa_f = 0.9;
    beta = 0.8;
    
    % Output initialization
    filtered_rti = zeros(size_rss_change);

    % Threshold when the monitored area is empty
    Ie = mean(max(max(rss_change_estimate(:,:,1:calibration_steps)))); % Average maximum intensity in the training period
    Tt = [2*Ie 0];  % Detection Threshold
    
    % Threshold when targets are being tracked
    I_lpf = zeros(1,nsteps-calibration_steps+1);
    
    for voxel_y = 1:size_rss_change(2)
        for voxel_x = 1:size_rss_change(1)
            for step = 1:nsteps
                if step <= calibration_steps
                    if rss_change_estimate(voxel_x,voxel_y,step)>Tt(1)
                        filtered_rti(voxel_x,voxel_y,step) = rss_change_estimate(voxel_x,voxel_y,step);
                    else
                        filtered_rti(voxel_x,voxel_y,step) = 0;
                    end
                else
                    % The minimum intensity of a target is set a 1/2*Pmax_est
                    Imin = 1/2*max(max(rss_change_estimate(:,:,step))); % Minimum intensity
                    I_lpf(step-calibration_steps+1) = alfa_f*I_lpf(step-calibration_steps)+(1-alfa_f)*Imin;
                    Tt(2) = beta*I_lpf(step-calibration_steps+1); % Low-pass filter of Imin
                    if rss_change_estimate(voxel_x,voxel_y,step)>Tt(2)
                        filtered_rti(voxel_x,voxel_y,step) = rss_change_estimate(voxel_x,voxel_y,step);
                    else
                        filtered_rti(voxel_x,voxel_y,step) = 0;
                    end
                end
            end
        end
    end
end

