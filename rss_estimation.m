function [ rss_change_estimate ] = rss_estimation( dimensions, rss_change_link, link_weights, precision )
%RSS_ESTIMATION Performs the estimation of the RSS changes caused by each
%voxels for the RTI image reconstruction
%   dimensions      Dimensions of the map in meters
%   rss_change_link Change in RSS simulated for each link 
%   link_weights    Matrix W of the voxels' weights of each link 
%                   (ellipse model)
%   precision       Size of each voxel in meters (width)

%   rss_change_estimation   Estimation of the change in RSS caused by each
%   voxel using regularized least-squares estimation (RLS)
    
    % Number of voxels
    lengths = dimensions(:,2)-dimensions(:,1);
    voxels = ceil(lengths./precision);  % Voxels(1)--> X_axis(columns), Voxels(2) --> Y_axis(rows)
    % Noise deviation - Regularization parameter
    sigma_n = 1;
    % Voxel measurements' deviation
    sigma_x = 1.0528;%0.2236;
    % Voxels' correlation distance
    delta_c = 3;
    % Covariance matrix of rss_change - Using exponential spatial decay
    Cov_x = zeros(voxels(1)*voxels(2), voxels(1)*voxels(2));
    voxel = 1;  % Rows counting of the covariance matrix
    voxel_all = 1; % Columns counting of the covariance matrix
    for voxel_y = 1:voxels(2)
        for voxel_x = 1:voxels(1)
            voxel_coordinates = [(voxel_x-1)*precision+dimensions(1,1) ; (voxel_y-1)*precision+dimensions(2,1)]; 
            for voxel_y_all = 1:voxels(2) 
                for voxel_x_all = 1:voxels(1)
                    voxel_coordinates_all = [(voxel_x_all-1)*precision+dimensions(1,1) ; (voxel_y_all-1)*precision+dimensions(2,1)]; 
                    Cov_x(voxel,voxel_all)=(sigma_x^2)*exp(-norm(voxel_coordinates-voxel_coordinates_all)/delta_c);
                    voxel_all = voxel_all+1;
               end
            end
            voxel_all = 1;
            voxel = voxel+1;                      
        end
    end
       
    % RLS matrix 
    rls_matrix = ((link_weights'*link_weights+inv(Cov_x).*sigma_n^2)^-1)*link_weights';
    % Output
    
    rss_change_estimate_inrows = rls_matrix*rss_change_link;
    nsteps = length(rss_change_estimate_inrows(1,:));
    rss_change_estimate = zeros(voxels(1),voxels(2),nsteps);
    for step = 1:nsteps
        for voxel_y = 1:voxels(2)
            rss_change_estimate(:,voxel_y,step) = rss_change_estimate_inrows(((voxel_y-1)*voxels(1)+1):(voxel_y*voxels(1)),step);
        end
    end
    rss_change_estimate(find(rss_change_estimate<0)) = 0;
end

