%{
    Expand data in the 2D latitude-longitude plane (filling corners)
%}

function [traj_long, traj_lat, data] = expandLatLongPlane(traj_long, traj_lat, data)

i = 10;
while i ~= (length(data)-10)
    if (traj_long(i)-traj_long(i+1)) > 300
        % moving across the meridian
        % where longitude is simultaneously equal to
        % 180 and -180 degrees
        traj_long = [traj_long(1:i), 360+traj_long(i+1:i+5), traj_long(i-4:i)-360, traj_long(i+1:(length(traj_long)))];
        traj_lat = [traj_lat(1:i), traj_lat(i+1:i+5), traj_lat(i-4:i), traj_lat(i+1:(length(traj_lat)))];
        data = [data(1:i), data(i+1:i+5), data(i-4:i), data(i+1:(length(data)))];     
        i = i+5;
    elseif (traj_long(i)-traj_long(i+1)) < -300
        % TODO
        error('Unexpected trajectory');
    end
    i = i+1;
end

