function [ sensor_radiation ] = sensor_measurement( sensor_position, dimensions, radiation, range, precision )
%SENSOR_MEASUREMENT Radiation received by a sensor 
%   sensor_position    Position of the sensor in coordinates [x ; y]
%   dimensions  Dimensions of the map in meters
%   radiation   Map Radiation of all the users
%   range     Radius of coverage in meters 
    
    radiation_size = size(radiation);
    
    range_invoxels = floor(range/precision)+1;
    sensor_radiation = zeros(radiation_size(1), radiation_size(2));

    % Converting sensor_position to the corresponding sensor_voxel
    sensor_center = floor((1/precision).*(sensor_position-dimensions(:,1)))+1;   % in voxels
    
    %sensor_matrix
    
    ini_x = sensor_center(1)-range_invoxels;
    end_x = sensor_center(1)+range_invoxels;
    ini_y = sensor_center(2)-range_invoxels;
    end_y = sensor_center(2)+range_invoxels;
    
    if ini_x < 1
        ini_x = 1;
    end
    if ini_y < 1
        ini_y = 1;
    end
    if end_x > radiation_size(2)
        end_x = radiation_size(2);
    end
    if end_y > radiation_size(1)
        end_y = radiation_size(1);
    end
    
    sensor_radiation(ini_y:end_y,ini_x:end_x) = radiation(ini_y:end_y,ini_x:end_x);    

    % Sensor gaussian gain
    variance = [range_invoxels^2 0;0 range_invoxels^2];
    voxels = [radiation_size(2) radiation_size(1)];
    sensor_gain = gaussianradiation(1,sensor_center,variance,0,voxels);
    
    % Plot sensor gain
    figure(3)
    surf(sensor_gain)
    
    % Total sensor radiation
    
    sensor_radiation = sensor_radiation.*sensor_gain;
end

