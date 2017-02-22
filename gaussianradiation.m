function [ radiation ] = gaussianradiation( amplitude,mean,variance,noiselevel,voxels )
%GAUSSIANRADIATION simulates a Gaussian radiation.
%   amplitude   amplitude of gaussian fdunction
%   mean        vector [x y] of the gaussian function center in voxels
%   variance    variance matrix 2x2 [varx varxy; varxy vary] in voxels
%   noiselevel  level of the noise of gaussian function
%   voxels      vector [x y] of dimensions of output radiation
    
    radiation = zeros(voxels(1),voxels(2));
    for x = 1:voxels(1)
        for y = 1:voxels(2)
              radiation(x,y) = amplitude * exp(noiselevel*randn) * exp(-1/2/(1-variance(1,2)*variance(2,1)/variance(1,1)/variance(2,2)) * ( ...
                  (x-mean(1))^2/variance(1,1) + ...
                  (y-mean(2))^2/variance(2,2) - ...
                  2*sqrt(variance(1,2)*variance(2,1))/variance(1,1)/variance(2,2)*(x-mean(1))*(y-mean(2)) ));
        end
    end
    
end