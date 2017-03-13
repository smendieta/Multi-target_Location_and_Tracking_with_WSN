% Executable
clc, clear all, close all
tic
profile on

% parameters = [ ntargets, precision, total_steps, calibration_steps ]
[parameters, dimensions]= input_GUI; 

% Initialization
users = 6;
dimensions = [-12 12; -12 12]; % [x_min x_max; y_min y_max]
total_steps = 100;
calibration_steps = 5;
precision = 0.5;