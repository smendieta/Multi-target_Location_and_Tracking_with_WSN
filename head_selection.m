function [total_clusters] = head_selection(total_clusters_points, normalized_rti, calibration_steps)
%HEAD_SELECTION Summary of this function goes here
%   Detailed explanation goes here

    size_clusters = size(total_clusters_points);
    nsteps = size_clusters(2);

    for step = 1:nsteps
        if ~(isempty(total_clusters_points{1,step}))
            nclusters = length(total_clusters_points(:,step));
            for clust = 1:nclusters
                analized_cluster = total_clusters_points{clust,step};
                if ~(isempty(analized_cluster))
                   cluster_points = analized_cluster.points;
                   cluster_head_z = max(max(normalized_rti(cluster_points,step)));
                   [cluster_head_x, cluster_head_y] = find(normalized_rti(:,:,step) == cluster_head_z);
                   analized_cluster.head = [cluster_head_x cluster_head_y cluster_head_z];
                   total_clusters_points{clust,step} = analized_cluster;
                end
            end
        end
    end
    total_clusters = total_clusters_points;
    
    
end

