function [ radiation ] = gaussianradiation( amplitude,center,radius,rotation,noiselevel,voxels )
%GAUSSIANRADIATION simulates a Gaussian radiation.
%   amplitude   amplitude of gaussian fdunction
%   center      vector [x y] of the gaussian function center in voxels
%   radius      vector [rx ry] of the radius of the function in voxels
%   rotation    rotation angle of the function in radians
%   noiselevel  level of the noise of gaussian function
%   voxels      vector [x y] of dimensions of output radiation
    
    radiation = zeros(voxels(1),voxels(2));
    rotation_matrix = [cos(rotation),-sin(rotation);sin(rotation),cos(rotation)];
    noise = randn(voxels(1),voxels(2));
    for x = 1:voxels(1)
        for y = 1:voxels(2)
            %% Transformations
            % Translation
            r = [x-center(1);y-center(2)];
            % Rotation
            if(rotation~=0)
                r = rotation_matrix * r;
            end
            %% Function
            radiation(x,y) = amplitude * exp(noiselevel*noise(x,y)) * exp(-1/2 * (r(1)^2/radius(1) + r(2)^2/radius(2)));
        end
    end
    
end