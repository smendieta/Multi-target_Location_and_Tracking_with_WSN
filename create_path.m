function [ users_path ] = create_path( users, dimensions, total_positions )
%CREATE_PATH Creates a random path for each user in a surface
%   users       Number of users
%   dimensions  Dimensions of the surface in meters

    users_path = NaN(2,total_positions,users);
    
    for user = 1:users 

        % Initialization
        position = floor(unifrnd(1,total_positions/2))
                    
        mean_distance = 6;  % Mean distance in positions
        step_distance = 0.75;   % in meters
        center = mean(dimensions,2);
        gate = [floor(unifrnd(dimensions(1,1),dimensions(1,2))) floor(unifrnd(dimensions(2,1),dimensions(2,2)))]; % Deviation of the input position of each user in each side
        side = floor(4*rand);
        is_alive = true;
        
        if side == 0
            users_path(:,position,user) = [dimensions(1,1); gate(2)];
            direction_angle = 0;
        elseif side == 1
            users_path(:,position,user) = [gate(1);dimensions(2,1)];
            direction_angle = pi/2;
        elseif side == 2
            users_path(:,position,user) = [dimensions(1,2); gate(2)];
            direction_angle = -pi;
        else
            users_path(:,position,user) = [gate(1);dimensions(2,2)];
            direction_angle = -pi/2;
        end

        % Creating the path
        position = position +1;
        
        rest_steps = total_positions-position+1;    % Remaining steps until maximum steps

        while (is_alive) 
            steps = ceil(-mean_distance*log(rand)); % Number of steps in one direction
            if steps > rest_steps
                steps = rest_steps; % Checking the limit of steps
            end
            if rand < 0.5
                direction = zeros(2,1); % The user is not walking
            else    % The user is walking
                direction_angle = direction_angle+pi*unifrnd(-1/2,1/2);     % Direction angle
                direction = [cos(direction_angle); sin(direction_angle)];   % Direction vector
            end
            for i = position:position-1+steps
                users_path(:,i,user) = users_path(:,i-1,user) + step_distance.*direction;   % Creating coordinates in each position
                if sum((users_path(:,i,user)>dimensions(:,2)) + (users_path(:,i,user)<dimensions(:,1)))~=0  % Limit check (user goes out)
                    is_alive =  false; 
                    break;
                end   
            end
            position = position + steps;   % Counting total positions of one user
            rest_steps = total_positions-position+1;
            is_alive = is_alive && (position < total_positions);
        end
    end
end

