function [ link_weights ] = locate_link_ellipses(dimensions,sensor_position,precision,nlinks);
%LOCATE_ELLIPSES Generates a matrix of the voxels' weights according to the
%ellipse model of each link
%   dimensions          Dimensions of the map in meters
%   sensor_position     Position of the rf sensors in the map
%   precision           Size of each voxel in meters, from side to side

    % Initialization
    nsensors = length(sensor_position(1,:));
    lengths = dimensions(:,2)-dimensions(:,1);
    voxels = ceil(lengths./precision);
    lambda = 0.02;  % Ellipse excess path length in meters [m]
    lambda_invoxels = lambda/precision;  % Conversion to "voxel units" to make calculations easier later
    k1 = 2;     % NLOS coefficient - (Non-line-of-sight)
    k1_invoxels = k1/precision;
    k2 = 2.5;   % LOS coefficient
    k2_invoxels = k2/precision;

    % Associating sensor coordinates to voxels
    sensor_position_invoxels = floor(1/precision.*(sensor_position - dimensions(:,1)))+1;

    %links_positions = cell(nsensors);     
    link_weights = zeros(nlinks,voxels(2)*voxels(1));
    link = 1;
    for i = 1:nsensors-1
        for j = i+1:nsensors
            %links_positions{i,j} =  [sensor_position(:,i) sensor_position(:,j)]; (POSITION OF LINKS IN A CELL)
            link_distance = norm(sensor_position_invoxels(:,i)-sensor_position_invoxels(:,j)); % Distance of each link
            
            for voxel_y = 1:voxels(2)
                for voxel_x = 1:voxels(1)
                    d_sensor1 = norm([voxel_x; voxel_y] - sensor_position_invoxels(:,i)); % Distance of the voxel to sensor 1
                    d_sensor2 = norm([voxel_x; voxel_y] - sensor_position_invoxels(:,j)); % Distance of the voxel to sensor 2
                    
                    if (d_sensor1 + d_sensor2) == link_distance
                        link_weights(link,voxels(1)*(voxel_y-1)+voxel_x) = 1/link_distance*(k2_invoxels+max(d_sensor1,d_sensor2));
                    elseif d_sensor1 + d_sensor2 < link_distance + lambda_invoxels   
                        link_weights(link,voxels(1)*(voxel_y-1)+voxel_x) = 1/link_distance*(k1_invoxels+max(d_sensor1,d_sensor2));
                    end
                end
            end
            link = link+1;
        end     
    end 
end

