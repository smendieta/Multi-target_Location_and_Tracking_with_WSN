% Executable
clc, clear all, close all
tic
profile on

[parameters, dimensions]= input_GUI;
% Initialization
users = 6;
dimensions = [-12 12; -12 12]; % [x_min x_max; y_min y_max]
total_steps = 100;
calibration_steps = 5;
precision = 0.5;
mean_distance = 6;  % Mean distance in positions
step_distance = 0.75;   % in meters

%% Input
    % Paths that the targets follow inside the considered map
users_path = create_path(users, dimensions, total_steps, step_distance, mean_distance);

%% Generalized radiation
    % Footprint on the map caused by the presence of a target

% Gaussian radiation characteristics
radiation_amplitude = 20;     % Maximum change in signal, when a target is present
target_width = [1 0.5];   % Target width (meters) in dimensions [x y]
rotation = 0;   % Target rotation in radians
noiselevel = 0.25;  % Noise deviation for the gaussian function (i.e. noiselevel*randn)

% RF radiation
radiation = create_radiation(dimensions, users_path, precision,calibration_steps, radiation_amplitude, target_width, rotation, noiselevel );
%% RF section
    % Measurements based on the change in RSS (received signal strength) in
    % each link (i.e. conexion between two sensors) caused by each voxel
    
% RF model - Change in RSS by each voxel - Simulation
rss_change = radiation;

% RF links - Change in RSS by each link - Simulation
sensor_position = [-12 -6 0 6 12 -12 -6 0 6 12 -12 -6 0 6 12 -12 -6 0 6 12 -12 -6 0 6 12; -12 -12 -12 -12 -12 -6 -6 -6 -6 -6 0 0 0 0 0 6 6 6 6 6 12 12 12 12 12];
%sensor_position = [dimensions(1,1) dimensions(1,2)/2 0 0 ; dimensions(2,1) 0 dimensions(2,1)/2 dimensions(2,2)/2];
nsensors = length(sensor_position(1,:));
nlinks = (nsensors^2-nsensors)/2;   % Number of links: L = (K^2-K)/2 (K: number of sensors)
link_weights = locate_link_ellipses(dimensions,sensor_position,precision,nlinks);
rss_change_link = rss_links(rss_change,link_weights,nlinks);

%% RTI Image Estimation
% This section is part of the estimation algorithm, after the simulation
% (or real environment test)
% Using Regularized Least-Squares (RLS) approach, the RSS change in each
% voxel is estimated (in simulation this is called "rss_change")

rss_change_estimate = rss_estimation(dimensions, rss_change_link, link_weights, precision);
 
% Gaussian filter (not implemented yet, excessive execution time)

%% Multiple Target Tracking with RTI images (RF sensors)

% Test tracking
users_track = users_path + randn(2,total_steps,users);
% Thresholding
filtered_rti = detection_thresholding(rss_change_estimate, calibration_steps);
% Clustering
clusters_rti = clustering(filtered_rti, calibration_steps);
% Cluster heads selection

% Target tracking
%% Tracking algorithm
% Tracking
%users_track = users_path + randn(2,total_steps,users);

% Plots
figure('name','Users paths')
for i = 1:users
    plot(users_path(1,:,i),users_path(2,:,i))
    hold on
end
hold on
grid on
title('Path of each user in the map')
legend('User 1', 'User 2')
xlabel('X')
ylabel('Y')
axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])

% Plot radiation for all users
loops = 1;
fps = 12;
nview = 2;
clip = plottracking(radiation,users_path, users_track, dimensions, calibration_steps, nview);
clip2 = plottracking(rss_change_estimate,users_path, users_track, dimensions, calibration_steps,nview);
clip3 = plottracking(filtered_rti,users_path, users_track, dimensions, calibration_steps,nview);
movie(clip,loops,fps);
profile viewer
toc