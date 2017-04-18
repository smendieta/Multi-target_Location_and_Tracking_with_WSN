function [ clusters_rti, total_clusters, voxels_forcluster ] = clustering2( filtered_rti, precision )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global istarget;
    % Ini
    Tc_inmeters = 2;  % Threshold for clustering (aprox. for a human width) in meters [m]
    Tc  = Tc_inmeters/precision;    % Equivalent threshold in voxels
    clusters_rti = [];
    voxels_forcluster = [];
    % Clusters cell array
    total_clusters = {[]};
    
    % Rows and columns with non-zero values
    [x, y] = find(filtered_rti>0);    
   
    if length(x)> 1 
        istarget = true;
        voxels_forcluster = [x y];   % Non-zero voxels that enter the clustering process
        decision_tree = linkage(voxels_forcluster,'average','euclidean','savememory','off');
        clusters_rti = cluster(decision_tree,'Cutoff',Tc,'Criterion','distance');
        
        % Clusters structure
        different_clusters = unique(clusters_rti);
        nclusters = length(different_clusters);
                
        for clust = 1:nclusters
            % Cluster points
            points_indexes = find(clusters_rti == clust);        
            cluster_coordinates = [x(points_indexes) y(points_indexes)];
            % Cluster heads selection
            cluster_head = [cluster_coordinates(1,1) cluster_coordinates(1,2)];
            for pos = 1:length(cluster_coordinates(:,1))
                if filtered_rti(cluster_coordinates(pos,1),cluster_coordinates(pos,2))>filtered_rti(cluster_head(1),cluster_head(2))
                    cluster_head = [cluster_coordinates(pos,1) cluster_coordinates(pos,2)];
                end
            end
            cluster_i = struct('ID',clust,'points',cluster_coordinates,'head',cluster_head);
            total_clusters(clust,1) = {cluster_i};
        end
    else 
        istarget = false;
    end
end

