%{
    Generate a rotation matrix given three angles and the order of
    application
%}

function rotMat = getRotMat(thetaX,thetaY,thetaZ,ordering)
if nargin < 4
    ordering = 'ZYX';
end

rot_mat_x = [1 0 0; 0 cosd(thetaX) -sind(thetaX); 0 sind(thetaX) cosd(thetaX)];
rot_mat_y = [cosd(thetaY) 0 sind(thetaY); 0 1 0; -sind(thetaY) 0 cosd(thetaY)];
rot_mat_z = [cosd(thetaZ) -sind(thetaZ) 0; sind(thetaZ) cosd(thetaZ) 0; 0 0 1];

switch ordering
    case 'ZYX'
        rotMat = rot_mat_x*rot_mat_y*rot_mat_z;
    case 'XYZ'
        rotMat = rot_mat_z*rot_mat_y*rot_mat_x;
    case 'YXZ'
        rotMat = rot_mat_z*rot_mat_x*rot_mat_y;
end