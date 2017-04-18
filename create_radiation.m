function [ radiation ] = create_radiation(dimensions, users_path, precision, calibration_steps, radiation_amplitude, target_width, rotation, noiselevel)
%CREATE_RADIATION Creates the radiation (signal strength) for all the users
% in the surface depending on its path
%   dimensions  Dimensions of the map in meters 
%   users_path  Paths for all the users as a set of coordinates

    % Initialization
    lengths = dimensions(:,2)-dimensions(:,1);
    voxels = ceil(lengths./precision);  % Voxels(1)--> X_axis(rows), Voxels(2) --> Y_axis(columns)
    users_path_size = size(users_path);
    steps = users_path_size(2)+calibration_steps;
    if length(users_path_size) > 2
        users = users_path_size(3);
    else
        users = 1;
    end
    
    % First radiation, reference scenario (empty space without people)
    background_noise = -log(rand(voxels(1),voxels(2),steps));   % Exponential distribution
    radiation = zeros(voxels(1),voxels(2),steps);

    % Associating coordinates to voxels
    users_voxels = floor(1/precision.*(users_path - dimensions(:,1)))+1;    % Voxels in which the user is positioned
    
    % Limit condition (if value>max_limit and value<min_limit)
    users_voxels_x = users_voxels(1,:,:);
    users_voxels_x(users_voxels_x>voxels(1))=voxels(1); % X coordinate
    users_voxels_x(users_voxels_x < 1) = 1; 
    users_voxels(1,:,:) = users_voxels_x;
    users_voxels_y = users_voxels(2,:,:);
    users_voxels_y(users_voxels_y>voxels(2))=voxels(2); % Y coordinate
    users_voxels_y(users_voxels_y < 1) = 1;
    users_voxels(2,:,:) = users_voxels_y;
    
    % Gaussian radiation 
    target_width_invoxels = target_width./precision;
    %radius = [target_width_invoxels(1)^2 target_width_invoxels(2)^2]; 
    radius = [target_width_invoxels(1) target_width_invoxels(2)]; 
    % Creating total radiation
    
    for step = (calibration_steps+1):steps
        for user = 1:users
            if sum(isnan(users_voxels(:,step-calibration_steps,user))) == 0
                center = [users_voxels(1,step-calibration_steps, user) users_voxels(2,step-calibration_steps, user)];
                radiation(:,:,step) = radiation(:,:,step)...
                +gaussianradiation(radiation_amplitude,center,radius, rotation, noiselevel,voxels);       
            end
        end
    end
    radiation = radiation+background_noise;
    
end

