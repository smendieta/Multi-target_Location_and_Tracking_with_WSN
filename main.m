% Executable
clc, clear all, close all
tic
profile on

% Initialization
users = 2;
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
figure(2)
hold on
for step = 1:total_steps

    % Thresholding
    filtered_rti(:,:,step) = detection_thresholding(rss_change_estimate(:,:,calibration_steps+step),Tt);    
    % Clustering  
    [clusters_rti, total_clusters{1,step}, voxels_forcluster] = clustering2(filtered_rti(:,:,step), precision);
    
    if istarget     
        % Iterative thresholding
        Imin_previous = zeros(1,length(voxels_forcluster(:,1)));
        for pos = 1:length(voxels_forcluster(:,1))
            Imin_previous(pos) = filtered_rti(voxels_forcluster(pos,1),voxels_forcluster(pos,2),step); 
        end   
        Imin = min(Imin_previous);
        I_lpf(step+1) = alfa_f*I_lpf(step)+(1-alfa_f)*Imin; % Low-pass filter of Imin
        Tt(2) = beta*I_lpf(step+1); 
        
        % Plotting  
        rows_inmeters = (voxels_forcluster(:,1).*precision+dimensions(1,1))-precision/2;
        columns_inmeters = (voxels_forcluster(:,2).*precision+dimensions(2,1))-precision/2;
        
        subplot(2,2,1) % Subplot 1   
        surf(xaxis,yaxis,filtered_rti(:,:,step)','EdgeColor','none')
        view(2)
        caxis([0 max(max(filtered_rti(:,:,step)))]);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Filtered estimated RTI')
        
        subplot(2,2,2) % Subplot 2
        scatter(rows_inmeters,columns_inmeters,10,clusters_rti)
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Clusters in estimated RTI')
        pause(0.1)
        cla
        
        subplot(2,2,1)
        cla
           
    else
        subplot(2,2,1) % Subplot 1   
        surf(xaxis,yaxis,filtered_rti(:,:,step)','EdgeColor','none')
        view(2)
        caxis([0 max(max(filtered_rti(:,:,step)))]);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Filtered estimated RTI')
        
        subplot(2,2,2) % Subplot 2
        plot(0,0);
        grid on;
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2)])
        xlabel('[m]');
        ylabel('[m]');
        title('Clusters in estimated RTI')
        pause(0.1)
        cla
        
        subplot(2,2,1)
        cla
    end    
end
       
% Image intensity normalization
normalized_rti = rti_normalization(filtered_rti);

%% Target tracking algorithm

% Parameters
Re_width = 2; % Entrance/Exit region width in meters
Re_width_invoxels = Re_width/precision;
max_voxels = [(dimensions(1,2)-dimensions(1,1))/precision (dimensions(2,2)-dimensions(2,1))/precision]; % Maximum dimensions in voxels
n_memory = 3;   % Number of previous decisions (clusters) taken into account for instant k
n_confirm = 5;  % To confirm a track, it has to be assigned to the same ID at least 'n_confirm' times in the last 'n_max_confirm' observations
n_max_confirm = 10;
n_delete = 5;   % To delete a track, it has to be not assigned in the last 'n_delete' observations
f = 0;  % Flag for loop
confirmed_tracks = [];  % Confirmed tracks after N of M observations
track_candidates = [];  % Track candidates to be confirmed or deleted
deleted_tracks = [];    % Deleted track candidates if not confirmed
current_deleted_tracks = [];    % Deleted tracks in one step
% Initializing variables:
targets = cell(1,total_steps);
r_t_inmeters = 2;
r_t = r_t_inmeters/precision;    % Initial radius around a target in voxels
target_id = 1;
for step = 1:total_steps
    if ~isempty(total_clusters{step}{1})
        nclusters = length(total_clusters{step});
        h = zeros(nclusters,2);
       
        % Cluster heads in the current step 
        for clust = 1:nclusters
            h(clust,:) = total_clusters{step}{clust}.head;
        end
        % -----------------------------------------------------------------
        % Searching memory...
        empty_steps = [];   % Searchs if a previous target exists
        for s = 1:step-1
            for p = 1:length(targets(:,step))
            empty_steps(p,s) = isstruct(targets{p,s});
            end
        end
        if length(empty_steps(:,1))>1
            empty_steps = sum(empty_steps);
        end
        % -----------------------------------------------------------------
        if step <= n_memory  % In case that first target appears in an instant less than N steps
            n = step-1;
        else
            n = n_memory;
        end
        % -----------------------------------------------------------------
        for clust = 1:nclusters
            if (h(clust,1)<=Re_width_invoxels || h(clust,1) >= max_voxels(1)-Re_width_invoxels) || (h(clust,2)<=Re_width_invoxels || h(clust,2) >= max_voxels(2)-Re_width_invoxels)
                %% Here h is included in the Entrance/Exit region (i.e. is considered as new candidate track or considered for updating an existing track)
                % NEW TARGETS OR UPDATING EXISTING TARGETS
                if sum(empty_steps)>0   
                    % Previous targets exist
                    % Searching memory in last N steps...
                    if sum(empty_steps((step-n):(step-1)))>0
                        % Target EXISTS in last N steps (frames)
                        pos = find((empty_steps(1:(step-1)))>0); % Previous steps with existing targets
                        pos = pos((pos<step)&(pos>(step-n)));
                        for i = length(pos):-1:1
                            ntargets = length(targets(:,pos(i)));
                            for t = 1:ntargets
                                if isstruct(targets{t,pos(i)})
                                    if sqrt(sum((h(clust,:)-targets{t,pos(i)}.position).^2))<r_t
                                        if clust == 1
                                            %UPDATING TARGET
                                            targets{clust,step} = targets{t,pos(i)};
                                            targets{clust,step}.position = h(clust,:);
                                            f = 1;
                                            break;
                                        else
                                            n_current_targets = length(targets(1:clust-1,step));
                                            targets_ids = zeros(1,n_current_targets);
                                            for targ = 1:n_current_targets
                                                if isstruct(targets{targ,step})
                                                    targets_ids(targ) = targets{targ,step}.ID;
                                                end
                                            end
                                            if isempty(find(targets{t,pos(i)}.ID == targets_ids,1))
                                                %UPDATING TARGET
                                                targets{clust,step} = targets{t,pos(i)};
                                                targets{clust,step}.position = h(clust,:);
                                                f = 1;
                                                break;                                          
                                            end
                                        end
                                    end
                                end
                                if f    % Stop searching
                                    break;  % New target is updated
                                end
                            end
                        end
                        f = 0;
                        if clust>length(targets(:,step))
                            % NEW TARGET CANDIDATE
                            targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t);
                            fprintf('New target CANDIDATE! Target ID: %d\n',target_id);
                            track_candidates = [track_candidates; target_id];
                            target_id = target_id+1;
                            fprintf('\n--------------------------------------\n')
                            fprintf('TRACK CANDIDATES:\n')
                            fprintf('%d\n',track_candidates)
                            fprintf('CONFIRMED TRACKS:\n')
                            fprintf('%d\n',confirmed_tracks)
                            fprintf('DELETED TRACKS:\n')
                            fprintf('%d\n',deleted_tracks)
                            fprintf('\n--------------------------------------\n')
                        elseif isempty(targets{clust,step})
                            % NEW TARGET CANDIDATE
                            targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t);
                            fprintf('New target CANDIDATE! Target ID: %d\n',target_id);
                            track_candidates = [track_candidates; target_id];
                            target_id = target_id+1;
                            fprintf('\n--------------------------------------\n')
                            fprintf('TRACK CANDIDATES:\n')
                            fprintf('%d\n',track_candidates)
                            fprintf('CONFIRMED TRACKS:\n')
                            fprintf('%d\n',confirmed_tracks)
                            fprintf('DELETED TRACKS:\n')
                            fprintf('%d\n',deleted_tracks)
                            fprintf('\n--------------------------------------\n')
                        end
                    else
                        % NEW TARGET CANDIDATE
                        targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t);
                        fprintf('New target CANDIDATE! Target ID: %d\n',target_id);
                        track_candidates = [track_candidates; target_id];
                        target_id = target_id+1; 
                        fprintf('\n--------------------------------------\n')
                        fprintf('TRACK CANDIDATES:\n')
                        fprintf('%d\n',track_candidates)
                        fprintf('CONFIRMED TRACKS:\n')
                        fprintf('%d\n',confirmed_tracks)
                        fprintf('DELETED TRACKS:\n')
                        fprintf('%d\n',deleted_tracks)
                        fprintf('\n--------------------------------------\n')
                    end
                else 
                    % FIRST TARGET CANDIDATE
                    targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t);
                    fprintf('New target CANDIDATE! Target ID: %d\n',target_id);
                    track_candidates = [track_candidates; target_id];
                    target_id = target_id+1;
                    fprintf('\n--------------------------------------\n')
                    fprintf('TRACK CANDIDATES:\n')
                    fprintf('%d\n',track_candidates)
                    fprintf('CONFIRMED TRACKS:\n')
                    fprintf('%d\n',confirmed_tracks)
                    fprintf('DELETED TRACKS:\n')
                    fprintf('%d\n',deleted_tracks)
                    fprintf('\n--------------------------------------\n')
                end 
                
            else
                % Here h is not included in the Entrance/Exit region
                % Searching memory in last N steps...
                if sum(empty_steps((step-n):(step-1)))>0
                    % Target EXISTS in last N steps (frames)
                    pos = find((empty_steps(1:(step-1)))>0); % Previous steps with existing targets
                    pos = pos((pos<step)&(pos>(step-n)));
                    for i = length(pos):-1:1
                        ntargets = length(targets(:,pos(i)));
                        for t = 1:ntargets
                            if isstruct(targets{t,pos(i)})
                                if sqrt(sum((h(clust,:)-targets{t,pos(i)}.position).^2))<r_t
                                    if clust == 1
                                        %UPDATING TARGET
                                        targets{clust,step} = targets{t,pos(i)};
                                        targets{clust,step}.position = h(clust,:);
                                        f = 1;
                                        break;
                                    else
                                        n_current_targets = length(targets(1:clust-1,step));
                                        targets_ids = zeros(1,n_current_targets);
                                        for targ = 1:n_current_targets
                                            if isstruct(targets{targ,step})
                                                targets_ids(targ) = targets{targ,step}.ID;
                                            end
                                        end
                                        if isempty(find(targets{t,pos(i)}.ID == targets_ids,1))
                                            %UPDATING TARGET
                                            targets{clust,step} = targets{t,pos(i)};
                                            targets{clust,step}.position = h(clust,:);
                                            f = 1;
                                            break;                                          
                                        end
                                    end
                                end
                            end
                        end
                        if f    % Stop searching
                            break;  % New target is updated
                        end
                    end
                    f = 0;
                    if clust>length(targets(:,step))
                        % OUTLIER
                        targets{clust,step} = [];
                    end
                end                    
            end
        end
        %% Confirming and deleting tracks
        if step<=n_confirm
            n = step;
            m = step;
        elseif (step>n_confirm) && (step<=n_max_confirm)
           n = n_confirm;
           m = step;
        else
            n = n_confirm;
            m = n_max_confirm;
        end
    
        % Confirming targets
        confirmed_targ_ids = zeros(length((targets(:,1))),(step-m));
        for tg = 1:length(targets(:,1))
            for st = step:-1:(step-m+1)
                if isstruct(targets{tg,st})
                    confirmed_targ_ids(tg,st) = targets{tg,st}.ID;
                end
            end
        end

        different_ids = unique(confirmed_targ_ids);

        for u = 1:length(different_ids)
            if different_ids(u)>0
                if sum(confirmed_targ_ids(:) == different_ids(u))>=n
                    if isempty(confirmed_tracks)
                        % New confirmed TRACK!
                        confirmed_tracks = [confirmed_tracks; different_ids(u)];
                        track_candidates = track_candidates(track_candidates~=different_ids(u));
                        fprintf('New track CONFIRMED! Target ID: %d\n',different_ids(u));
                        fprintf('\n--------------------------------------\n')
                        fprintf('TRACK CANDIDATES:\n')
                        fprintf('%d\n',track_candidates)
                        fprintf('CONFIRMED TRACKS:\n')
                        fprintf('%d\n',confirmed_tracks)
                        fprintf('DELETED TRACKS:\n')
                        fprintf('%d\n',deleted_tracks)
                        fprintf('\n--------------------------------------\n')

                    else
                        % Search if track is already confirmed
                        if isempty(find(confirmed_tracks == different_ids(u),1))
                            % New confirmed TRACK!
                            confirmed_tracks = [confirmed_tracks; different_ids(u)];
                            track_candidates = track_candidates(track_candidates~=different_ids(u));
                            fprintf('New track CONFIRMED! Target ID: %d\n',different_ids(u));
                            fprintf('\n--------------------------------------\n')
                            fprintf('TRACK CANDIDATES:\n')
                            fprintf('%d\n',track_candidates)
                            fprintf('CONFIRMED TRACKS:\n')
                            fprintf('%d\n',confirmed_tracks)
                            fprintf('DELETED TRACKS:\n')
                            fprintf('%d\n',deleted_tracks)
                            fprintf('\n--------------------------------------\n')
                        end
                    end
                end
            end
        end  
    end
    % Deleting targets
    if step>n_delete 
        deleted_targ_ids = zeros(length(targets(:,1)),(step-n_delete));
        for tg = 1:length(targets(:,1))
            for st = step:-1:(step-n_delete+1)
                if isstruct(targets{tg,st})
                    deleted_targ_ids(tg,st) = targets{tg,st}.ID;
                end
            end
        end
        
        % Searching track candidates...
        for cand = 1:length(track_candidates)
            if isempty(find(deleted_targ_ids == track_candidates(cand),1))
                deleted_tracks = [deleted_tracks; track_candidates(cand)];
                current_deleted_tracks = [current_deleted_tracks; track_candidates(cand)];
                fprintf('Deleted CANDIDATE track with ID:%d\n',track_candidates(cand)) 
            end
        end
        if ~isempty(current_deleted_tracks)
            track_candidates = track_candidates(track_candidates ~= current_deleted_tracks);
            fprintf('\n--------------------------------------\n')
            fprintf('TRACK CANDIDATES:\n')
            fprintf('%d\n',track_candidates)
            fprintf('CONFIRMED TRACKS:\n')
            fprintf('%d\n',confirmed_tracks)
            fprintf('DELETED TRACKS:\n')
            fprintf('%d\n',deleted_tracks)
            fprintf('\n--------------------------------------\n')
        end
        %current_deleted_tracks = [];
        % Searching confirmed tracks...
        for conf = 1:length(confirmed_tracks)
            if isempty(find(deleted_targ_ids == confirmed_tracks(conf),1))
                deleted_tracks = [deleted_tracks; confirmed_tracks(conf)];
                current_deleted_tracks = [current_deleted_tracks; confirmed_tracks(conf)];
                fprintf('Deleted CONFIRMED track with ID:%d\n',confirmed_tracks(conf))  
            end
        end
        if ~isempty(current_deleted_tracks)
            confirmed_tracks = confirmed_tracks(confirmed_tracks ~= current_deleted_tracks);
            fprintf('\n--------------------------------------\n')
            fprintf('TRACK CANDIDATES:\n')
            fprintf('%d\n',track_candidates)
            fprintf('CONFIRMED TRACKS:\n')
            fprintf('%d\n',confirmed_tracks)
            fprintf('DELETED TRACKS:\n')
            fprintf('%d\n',deleted_tracks)
            fprintf('\n--------------------------------------\n')
        end
        current_deleted_tracks = [];
    end
end

%% Tracking algorithm
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