% Executable
clc, clear all, close all
tic
profile on

% Initialization
users = 4;
dimensions = [-12 12; -12 12]; % [x_min x_max; y_min y_max]
total_steps = 75;
calibration_steps = 10;
precision = 0.5;
mean_distance = 6;  % Mean distance in positions
step_distance = 0.75;   % in meters

%% Input
    % Paths that the targets follow inside the considered map
users_path = create_path(users, dimensions, total_steps, step_distance, mean_distance);

% Plot user path
figure('name','Users paths')
for i = 1:users
    plot(users_path(1,:,i),users_path(2,:,i))
    hold on
end
hold on
grid on
title('Path of each user in the map')
xlabel('X')
ylabel('Y')
axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
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
%plottracking(1,radiation,users_path,dimensions, calibration_steps, 2);
% Gaussian filter (not implemented yet, excessive execution time)

%% Multiple Target Tracking with RTI images (RF sensors)
global istarget;
istarget = false;   % Empty area or monitoring targets
% Initialization of variables
filtered_rti = zeros(size(rss_change_estimate(:,:,calibration_steps+1:end)));
alfa_f = 0.9;
beta = 0.8;
xaxis = (dimensions(1,1)+precision/2):precision:(dimensions(1,2)-precision/2);
yaxis = (dimensions(2,1)+precision/2):precision:(dimensions(2,2)-precision/2);
total_clusters = cell(1,total_steps);

% Threshold when the monitored area is empty
Ie = mean(max(max(rss_change_estimate(:,:,1:calibration_steps)))); % Average maximum intensity in the training period
Tt = [2*Ie 0];  % Initial Detection Threshold
% Initizalization of Threshold when targets are being tracked
I_lpf = ones(1,total_steps);

% Tracking algorithm initialization
% Parameters
Re_width = 2; % Entrance/Exit region width in meters
radius_t = 2;   % Initial radius around a target in meters [m]
n_memory = 3;   % Number of previous decisions (clusters) taken into account for instant k
n_confirm = 5;  % To confirm a track, it has to be assigned to the same ID at least 'n_confirm' times in the last 'n_max_confirm' observations
n_max_confirm = 10;
n_delete = 5;   % To delete a track, it has to be not assigned in the last 'n_delete' observations

% Initializing tracking variables:
targets = cell(1,total_steps);
target_id = 1;
confirmed_tracks = [];  % Confirmed tracks after N of M observations
track_candidates = [];  % Track candidates to be confirmed or deleted
deleted_tracks = [];    % Deleted track candidates if not confirmed

figure(2)
hold on
subplot(2,3,1)  % Subplot 1 -- Users Paths
for i = 1:users
    plot(users_path(1,:,i),users_path(2,:,i))
    hold on
end
grid on
title('Users path')
xlabel('X')
ylabel('Y')
axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])

for step = 1:total_steps

    % Thresholding
    filtered_rti(:,:,step) = detection_thresholding(rss_change_estimate(:,:,calibration_steps+step),Tt);    
    % Clustering  
    [clusters_rti, total_clusters{1,step}, voxels_forcluster] = clustering(filtered_rti(:,:,step), precision);
    % Tracking
    [targets, track_candidates, confirmed_tracks, deleted_tracks, target_id ] = target_tracking( targets, total_clusters, step,...
    dimensions, precision, Re_width, radius_t, n_memory, n_confirm, n_max_confirm, n_delete, target_id, track_candidates, ...
    confirmed_tracks, deleted_tracks );
 
    if istarget     
        % Iterative thresholding
        Imin_previous = zeros(1,length(voxels_forcluster(:,1)));
        for pos = 1:length(voxels_forcluster(:,1))
            Imin_previous(pos) = filtered_rti(voxels_forcluster(pos,1),voxels_forcluster(pos,2),step); 
        end   
        Imin = min(Imin_previous);
        I_lpf(step+1) = alfa_f*I_lpf(step)+(1-alfa_f)*Imin; % Low-pass filter of Imin
        Tt(2) = beta*I_lpf(step+1); 
        
        %% Plotting  
        rows_inmeters = (voxels_forcluster(:,1).*precision+dimensions(1,1))-precision/2;
        columns_inmeters = (voxels_forcluster(:,2).*precision+dimensions(2,1))-precision/2;
        
        subplot(2,3,2)  % Subplot 2 -- Input radiation
        surf(xaxis,yaxis,rss_change(:,:,calibration_steps+step)','EdgeColor','none')
        view(2);
        colormap jet;
        grid on;
        caxis([0 max(max(rss_change(:,:,calibration_steps+step)))]);
        grid on
        title('Input Radiation')
        xlabel('X')
        ylabel('Y')
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])

        subplot(2,3,3)  % Subplot 3 -- Estimated radiation from sensors
        surf(xaxis,yaxis,rss_change_estimate(:,:,calibration_steps+step)','EdgeColor','none')
        view(2);
        colormap jet;
        grid on;
        caxis([0 max(max(rss_change_estimate(:,:,calibration_steps+step)))]);
        grid on
        title('Estimated Radiation')
        xlabel('X')
        ylabel('Y')
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        
        subplot(2,3,4) % Subplot 4 -- Filtered estimated radiation 
        surf(xaxis,yaxis,filtered_rti(:,:,step)','EdgeColor','none')
        view(2)
        caxis([0 max(max(filtered_rti(:,:,step)))]);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Filtered estimated RTI')
        
        subplot(2,3,5) % Subplot 5 -- Clusters
        scatter(rows_inmeters,columns_inmeters,10,clusters_rti)
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Clusters in estimated RTI')
        pause(0.1)
        
        subplot(2,3,6)  % Subplot 6 -- Multi target Tracking
        hold on
        for b = 1:length(targets(:,step))
            if isstruct(targets{b,step})
                target_x_position_inmeters = ((targets{b,step}.position(1)).*precision+dimensions(1,1))-precision/2;
                target_y_position_inmeters = ((targets{b,step}.position(2)).*precision+dimensions(1,1))-precision/2;
                plot(target_x_position_inmeters,target_y_position_inmeters,'w*')
                hold on
                ln = findobj('type','line');
                set(ln, 'marker', '.', 'markers', 10, 'markerfa', 'w')
                text(target_x_position_inmeters,target_y_position_inmeters,num2str(targets{b,step}.ID))
                grid on;
                axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
                xlabel('[m]');
                ylabel('[m]');
                title('Multi Target Tracking')
                pause(0.1)
            end
        end
        
        subplot(2,3,2)
        cla
        subplot(2,3,3)
        cla
        subplot(2,3,4)
        cla
        subplot(2,3,5)
        cla
           
    else
        
        subplot(2,3,2)  % Subplot 2 -- Input radiation
        surf(xaxis,yaxis,rss_change(:,:,calibration_steps+step)','EdgeColor','none')
        view(2);
        colormap jet;
        grid on;
        caxis([0 max(max(rss_change(:,:,calibration_steps+step)))]);
        grid on
        title('Input Radiation')
        xlabel('X')
        ylabel('Y')
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])

        subplot(2,3,3)  % Subplot 3 -- Estimated radiation from sensors
        surf(xaxis,yaxis,rss_change_estimate(:,:,calibration_steps+step)','EdgeColor','none')
        view(2);
        colormap jet;
        grid on;
        caxis([0 max(max(rss_change_estimate(:,:,calibration_steps+step)))]);
        grid on
        title('Estimated Radiation')
        xlabel('X')
        ylabel('Y')
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        
        subplot(2,3,4) % Subplot 4 -- Filtered radiation
        surf(xaxis,yaxis,filtered_rti(:,:,step)','EdgeColor','none')
        view(2)
        caxis([0 max(max(filtered_rti(:,:,step)))]);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Filtered estimated RTI')
        
        subplot(2,3,5) % Subplot 5 -- Clusters
        plot(0,0);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Clusters in estimated RTI')
        pause(0.1)
                
        subplot(2,3,6) % Subplot 6 -- Multi target tracking
        plot(0,0);
        hold on
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Multi target tracking')
        pause(0.1)
        
        subplot(2,3,2)
        cla
        subplot(2,3,3)
        cla
        subplot(2,3,4)
        cla
        subplot(2,3,5)
        cla
    end    
end
       
% Image intensity normalization
normalized_rti = rti_normalization(filtered_rti);

%% Target tracking algorithm

% Tracking
%users_track = users_path + randn(2,total_steps,users);

% Plot radiation for all users
% loops = 1;
% fps = 12;
% nview = 2;
%plottracking(radiation,users_path, users_track, dimensions, calibration_steps, nview);
% clip2 = plottracking(rss_change_estimate,users_path, users_track, dimensions, calibration_steps,nview);
% clip3 = plottracking(filtered_rti,users_path, users_track, dimensions, calibration_steps,nview);
% movie(clip,loops,fps);
profile viewer
toc