function [ clip ] = plottracking( radiation, users_path, users_track,dimensions, calibration_steps)
%PLOTTRACKING plots a matrix of 3 dimension as 2 spacial and 1 time dimensions

    f = figure('name','Tracking');
    figure(f);
    set(f,'Visible','on')
    commandwindow;
    radiation_dimensions = size(radiation);
    frames = radiation_dimensions(3);
    xprecision = (dimensions(1,2)-dimensions(1,1))/radiation_dimensions(1);
    xaxis = (dimensions(1,1)+xprecision/2):xprecision:(dimensions(1,2)-xprecision/2);
    yprecision = (dimensions(2,2)-dimensions(2,1))/radiation_dimensions(2);
    yaxis = (dimensions(2,1)+yprecision/2):yprecision:(dimensions(2,2)-yprecision/2);
    zmax = max(max(max(radiation)));
    zmin = min(min(min(radiation)));
    clip(frames) = struct('cdata',[],'colormap',[]);
    
    for frame = 1:frames
        hold on;
        surf(xaxis,yaxis,radiation(:,:,frame)','EdgeColor','none')
        view(2);
        colormap jet;
        grid on;
        caxis([0 20]);
        axis([dimensions(1,1) dimensions(1,2) dimensions(2,1) dimensions(2,2) zmin zmax])
        xlabel('[m]');
        ylabel('[m]');
        colorlegend = colorbar;
        colorlegend.Label.String = 'RSS change';
        zlabel(colorlegend.Label.String);
        if(frame > calibration_steps)
            scatter(users_path(1,frame-calibration_steps,:),users_path(2,frame-calibration_steps,:),'o')
            scatter(users_track(1,frame-calibration_steps,:),users_track(2,frame-calibration_steps,:),'x')
        end
        drawnow
        clip(frame) = getframe;
        cla
    end 
    set(f,'Visible','on')
end