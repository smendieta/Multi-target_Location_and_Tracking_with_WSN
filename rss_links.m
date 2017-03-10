function [ rss_change_link ] = rss_links( rss_change, link_weights, nlinks )
%RSS_LINKS Simulates the changes of RSS per link
%   rss_change          Change of the RSS in each voxel of the map
%   link_weights        Matrix of the voxels weigthed by the ellipse model 
%                       of each link 
%   nlinks              Number of links
%   rss_change_link     Change of the RSS by each link according to the
%                       ellipse model (nLinksxsteps)

    % Initialization
    size_rss_change = size(rss_change);
    steps = size_rss_change(3);
    rss_change_vector = zeros(size_rss_change(1)*size_rss_change(2),steps);
    rss_change_link = zeros(nlinks,steps);
    
    % Converting RSS change matrix into a vector Mx1 (M: number of voxels)
    for step = 1:steps
        c = rss_change(:,:,step);
        rss_change_vector(:,step) = c(:);
        % Additive noise
        n = randn(nlinks,1);
        % Vector of the contribution of RSS change of each link
        rss_change_link(:,step) = link_weights*rss_change_vector(:,step)+n;
    end
end

