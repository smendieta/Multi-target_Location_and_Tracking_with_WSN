% Executable
clc, clear all, close all
tic
profile on
 
% Initialization
users = 5;
dimensions = [-12 12; -12 12]; % [x_min x_max; y_min y_max]
total_steps = 100;
precision = 0.1;

%% Input
    % Paths that the targets follow inside the considered map
users_path = create_path(users, dimensions, total_steps);

%% Generalized radiation
    % Footprint on the map caused by the presence of a target
radiation = create_radiation(dimensions, users_path, precision);
%% RF section
    % Measurements based on the change in RSS (received signal strength) in
    % each link (i.e. conexion between two sensors) caused by each voxel
    
% RF model - Change in RSS by each voxel - Simulation
rss_change = radiation;

% RF links - Change in RSS by each link - Simulation

sensor_position = [dimensions(1,1) dimensions(1,2)/2 0 0 ; dimensions(2,1) 0 dimensions(2,1)/2 dimensions(2,2)/2];
nsensors = length(sensor_position(1,:));
nlinks = (nsensors^2-nsensors)/2;   % Number of links: L = (K^2-K)/2 (K: number of sensors)
link_weights = locate_ellipses(dimensions,sensor_position,precision,nlinks);
rss_change_link = rss_links(rss_change,link_weights,nlinks);

% Sensors
% sensor_position = [dimensions(1,1) dimensions(1,2)/2 0 0 ; dimensions(2,1) 0 dimensions(2,1)/2 dimensions(2,2)/2];
% range = 2; %in meters
% nsensors = length(sensor_position(1,:));
% sensor_radiation = zeros([size(radiation) nsensors]);
% for step = 1:total_positions
%      for sensor = 1:nsensors
%          sensor_radiation(:,:,step,sensor) = sensor_measurement(sensor_position(:,sensor), dimensions, radiation, range, precision);
%      end
% end

%% Tracking algorithm
% Tracking
users_track = users_path + randn(2,total_steps,users);

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
clip = plottracking(radiation,users_path, users_track, dimensions);
movie(clip,loops,fps);
profile viewer
toc