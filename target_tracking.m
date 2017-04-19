function [ targets, track_candidates, confirmed_tracks, deleted_tracks, target_id ] = target_tracking( targets, total_clusters, step,...
    dimensions, precision, Re_width, radius_t, n_memory, n_confirm, n_max_confirm, n_delete, target_id, track_candidates, ...
    confirmed_tracks, deleted_tracks)
%TARGET_TRACKING Summary of this function goes here
%   Detailed explanation goes here
    
    % Fixed parameters
    Re_width_invoxels = Re_width/precision;
    r_t_invoxels = radius_t/precision;    % Initial radius around a target in voxels
    max_voxels = [(dimensions(1,2)-dimensions(1,1))/precision (dimensions(2,2)-dimensions(2,1))/precision]; % Maximum dimensions in voxels
    
    % Initializing variables 
    current_deleted_tracks = [];    % Deleted tracks in one step
    f = 0;  % Flag for loop
    
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
                                    if sqrt(sum((h(clust,:)-targets{t,pos(i)}.position).^2))<r_t_invoxels
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
                            targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t_invoxels);
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
                            targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t_invoxels);
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
                        targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t_invoxels);
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
                    targets{clust,step} = struct('ID',target_id,'position',h(clust,:),'radius',r_t_invoxels);
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
                                if sqrt(sum((h(clust,:)-targets{t,pos(i)}.position).^2))<r_t_invoxels
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
                current_deleted_tracks = [current_deleted_tracks; track_candidates(cand)];
                fprintf('Deleted CANDIDATE track with ID:%d\n',track_candidates(cand)) 
            end
        end
        if ~isempty(current_deleted_tracks)
            for c = 1:length(current_deleted_tracks)
                track_candidates = track_candidates(track_candidates ~= current_deleted_tracks(c));
            end
            deleted_tracks = [deleted_tracks; current_deleted_tracks];
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
        % Searching confirmed tracks...
        for conf = 1:length(confirmed_tracks)
            if isempty(find(deleted_targ_ids == confirmed_tracks(conf),1))
                current_deleted_tracks = [current_deleted_tracks; confirmed_tracks(conf)];
                fprintf('Deleted CONFIRMED track with ID:%d\n',confirmed_tracks(conf))  
            end
        end
        if ~isempty(current_deleted_tracks)
            for c = 1:length(current_deleted_tracks)
                confirmed_tracks = confirmed_tracks(confirmed_tracks ~= current_deleted_tracks(c));
            end
            deleted_tracks = [deleted_tracks; current_deleted_tracks];
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

