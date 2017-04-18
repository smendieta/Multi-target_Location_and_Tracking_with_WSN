function [ clusters_rti, total_clusters ] = clustering( filtered_rti, calibration_steps, dimensions,precision)
%CLUSTERING Summary of this function goes here
%   Detailed explanation goes here

    % Ini
    size_filtered_rti = size(filtered_rti);
    nsteps = size_filtered_rti(3);
    Tc_inmeters = 1.25;  % Threshold for clustering (aprox. for a human width) in meters [m]
    Tc  = Tc_inmeters/precision;    % Equivalent threshold in voxels
    clusters_rti = cell(1,nsteps-calibration_steps);
    
    % Clusters cell array
    total_clusters = cell(1,nsteps);
   
    figure('name','Clustering');
    for step = calibration_steps+1:nsteps
        [x, y] = find(filtered_rti(:,:,step)>0);
        hold on
        if length(x)> 1      
            voxels_forcluster = [x y];   % Non-zero voxels that enter the clustering process
            decision_tree = linkage(voxels_forcluster,'average','euclidean','savememory','off');
            clusters_rti{step-calibration_steps} = cluster(decision_tree,'Cutoff',Tc,'Criterion','distance');
            
            rows_inmeters = (x*precision+dimensions(1,1))-precision/2;
            columns_inmeters = (y*precision+dimensions(2,1))-precision/2;
            
            % Clusters structure
            different_clusters = unique(clusters_rti{step-calibration_steps});
            nclusters = length(different_clusters);
            clusters_id = clusters_rti{step-calibration_steps};
           
            for clust = 1:nclusters
                %clust = different_clusters(c);
                points_indexes = find(clusters_id == clust);        
                points = [x(points_indexes) y(points_indexes)]; 
                cluster_i = struct('ID',clust,'points',points,'head',[]);
                total_clusters(clust,step) = {cluster_i};
            end
            
            % Clusters plotting
            scatter(rows_inmeters,columns_inmeters,10,clusters_rti{step-calibration_steps})
            axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
            pause(0.5)
            cla

           
        else
            plot(0,0);
            axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
            pause(0.1)
            cla
        end
    end
    

end

