function [ clusters_rti ] = clustering( filtered_rti, calibration_steps)
%CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

    % Ini
    size_filtered_rti = size(filtered_rti);
    nsteps = size_filtered_rti(3);
    Tc = 5.5;  % Threshold for clustering (aprox. for a human) in meters [m]
    clusters_rti = cell(1,nsteps-calibration_steps);
    figure('name','Clustering');
    for step = calibration_steps+1:nsteps
        [rows, columns] = find(filtered_rti(:,:,step)>0);
        hold on
        if isempty(rows) == 0
            
            voxels_forcluster = [rows columns];   % Non-zero voxels that enter the clustering process
            decision_tree = linkage(voxels_forcluster,'average','euclidean','savememory','off');
            clusters_rti{step-calibration_steps} = cluster(decision_tree,'Cutoff',Tc,'Criterion','distance');
            scatter(rows,columns,10,clusters_rti{step-calibration_steps})
            axis([1 size_filtered_rti(1) 1 size_filtered_rti(1)])
            cla
        end
    end

end

