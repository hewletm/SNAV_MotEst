%{
    Generates additional prerotated SNAV baselines from an acquired subset.
    Rotations about kx and ky are acquired while those about kz are
    interpolated.
%}

function [dataFull,rotArray] = genHybridBaselines(dataAcq,trajCart,header)

% Interpolation is performed in the latitude/longitude plane
[trajGrid.long,trajGrid.lat] = meshgrid(-180:180, -90:90); % gridded coordinates
traj = cart2geo(trajCart); % convert trajectory

% Define rotations within the lookup table
% Larger (doi.org/10.1016/j.mri.2016.06.006) and/or finer (doi.org/10.1002/mrm.29961)
% rotations can be interpolated for improved rotation estimation but for
% demonstration purposes we limit the baseline lookup table here to cover
% rotations in the range [-6,6] in 1 degree increments
maxAngle = header.MeasYaps.sWipMemBlock.alFree{5}; % match rotation limit to that acquired [deg]
rotRange = -maxAngle:maxAngle;
rotArray = NaN((2*maxAngle + 1)^3 + 1,3);
baseCounter = 1;
for theta_y = rotRange % looping order must match that of sequence
    for theta_x = rotRange
        for theta_z = rotRange
            rotArray(baseCounter,1) = theta_x;
            rotArray(baseCounter,2) = theta_y;
            rotArray(baseCounter,3) = theta_z;
            
            baseCounter = baseCounter + 1;
        end
    end
end
rotArray(baseCounter,1) = 0; % last baseline is an additional SNAV with
rotArray(baseCounter,2) = 0; % no rotation
rotArray(baseCounter,3) = 0;

% For each acquired baseline, simulate rotations aboug kz
numAcq = size(dataAcq,1); % number of acquired baselines

% Get geographical coordinates for the rotated baselines
trajNew.lat = zeros(size(dataAcq,2),2*maxAngle + 1);
trajNew.long = zeros(size(dataAcq,2),2*maxAngle + 1);
for i=1:(2*maxAngle + 1)
    trajTmp = getRotMat(0,0,rotRange(i))*[trajCart.kx;trajCart.ky;trajCart.kz]; % rotated k-space coordinates
    trajNewCart.kx = trajTmp(1,:);
    trajNewCart.ky = trajTmp(2,:);
    trajNewCart.kz = trajTmp(3,:);
    trajTmp = cart2geo(trajNewCart); % convert to geographical coordinates
    trajNew.lat(:,i) = trajTmp.lat;
    trajNew.long(:,i) = trajTmp.long;
end
clear trajTmp trajCart trajNewCart;

% Interpolate
disp('Interpolating HYBRID baselines...');
warning('off','MATLAB:interp2:NaNstrip');
dataFull = NaN((2*maxAngle + 1)*(numAcq - 1) + 1,size(dataAcq,2));
for k = 1:(numAcq - 1)
    [trajExpand.long, trajExpand.lat, dataExpand] = expandLatLongPlane(traj.long, traj.lat, dataAcq(k,:)); % fill corners
    dataGrid = griddata(trajExpand.long, trajExpand.lat, dataExpand, trajGrid.long, trajGrid.lat, 'cubic'); % grid for faster interpolation
    
    for i=1:(2*maxAngle + 1)
        dataFull((2*maxAngle + 1)*(k-1) + i,:) = interp2(trajGrid.long,trajGrid.lat,dataGrid,trajNew.long(:,i),trajNew.lat(:,i), 'spline');
    end
end
warning('on','MATLAB:interp2:NaNstrip');
disp('Done.');

dataFull(end,:) = dataAcq(end,:); % last baseline not interpolated as is is a repeat
dataFull(isnan(dataFull)) = 0;

% Normalize
for i = 1:size(dataFull,1)
    tmp = sum(abs(dataFull(i,:)))/length(dataFull(i,:));
    dataFull(i,:) = (dataFull(i,:))/tmp;
end

end