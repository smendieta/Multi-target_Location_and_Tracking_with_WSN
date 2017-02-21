% Executable
clc, clear all, close all
tic

% Initialization
users = 5;
dimensions = [-12 12; -12 12]; % [x_min x_max; y_min y_max]
total_positions = 150;

% Input
users_path = create_path(users, dimensions, total_positions);
radiation = create_radiation(dimensions, users_path);

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
%set(u,'Visible','Off')

% Tracking
users_track = users_path + randn(2,total_positions,users);

% Plot radiation for all users
loops = 1;
fps = 8;
clip = plottracking(radiation,users_path, users_track, dimensions);
movie(clip,loops,fps);
toc