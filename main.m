%{
    Example motion estimation from spherical navigators
    Simplified for demonstration purposes (limited lookup table for
    rotation estimation, no phase unwrapping)
%}

addpath('snavUtils');

% Load SNAV trajectory (for a single hemisphere)
% Each SNAV is acquired as two hemispheres to cancel out phase ramps due to
% field inhommogeneity (doi.org/10.1002/mrm.20445).
load('navTraj.mat');

% Load SNAV data (obtained from raw scan data)
% navData.header - scan header
% navData.baseline - SNAV baseline scans for fast rotation estimation (https://doi.org/10.1002/mrm.22629)
%                    (170 prerotations x 2 hemispheres)
% navData.snavs - SNVAVs interleaved with imaging
%                 (1488 x 2 hemispheres)
load('navData_rotSim'); % phantom scan with simulated rotations (FOV update)
% load('navData_tranSim'); % phantom scan with simulated translations (1D motion stage)

% Append hemispheres
navData.baseline = appendHems(navData.baseline);
navData.snavs = appendHems(navData.snavs);
navTraj.kx = [navTraj.kx -navTraj.kx];
navTraj.ky = [navTraj.ky -navTraj.ky];
navTraj.kz = [navTraj.kz -navTraj.kz];

% Interpolate additional baselines
% Baseline data is acquired using a hybrid approach
% (doi.org/10.1016/j.mri.2016.06.006) where prerotations about kx and ky are
% acquired and those about kz obtained via interpolation, balancing scan
% time with processing time for motion estimation
[navData.baseline, navData.baselineRot] = genHybridBaselines(navData.baseline,navTraj,navData.header);

% Calculate motion
motion = motionCalc(navData,navTraj);

figure;
plot(motion(:,1),'Color','#0072BD');
hold on;
plot(motion(:,2),'Color','#D95319');
plot(motion(:,3),'Color','#EDB120');
plot(motion(:,4),'Color','#0072BD','LineStyle','--');
plot(motion(:,5),'Color','#D95319','LineStyle','--');
plot(motion(:,6),'Color','#EDB120','LineStyle','--');
hold off;
ylim([-6 6]);
legend({'rotX','rotY','rotZ','tranX','tranY','tranZ'});

