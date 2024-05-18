%{
    Calculate motion using SNAV baselines
    (https://doi.org/10.1002/mrm.22629)
%}

function motion = motionCalc(navData,navTraj)

% Remove unreliable data near the poles of the kspace sphere
ix_keep = [1:600, 801:1400];
navTraj.kx = navTraj.kx(ix_keep);
navTraj.ky = navTraj.ky(ix_keep);
navTraj.kz = navTraj.kz(ix_keep);
navData.snavs = navData.snavs(:,ix_keep);
navData.baseline = navData.baseline(:,ix_keep);

% Determine motion for each timepoint
disp('Calculating motion...');
motion = NaN(size(navData.snavs,1),6);
for navCounter = 1:size(navData.snavs,1) % loop through SNAVs

    % Calculate rotation by minimizing sum of squares between current SNAV
    % and baselines (magnitude signal only to remove effects of translation)
    cost = sum((repmat(abs(navData.snavs(navCounter,:)),size(navData.baseline,1),1) - abs(navData.baseline)).^2,2);
    [costSorted,ix] = sort(cost);

    % Perform weighted average of angles producing cost within 5% of that
    % of the best matched rotation
    threshold = find(costSorted < 1.05*(costSorted(1)));
    ixThreshold = ix(threshold);
    costThreshold = costSorted(threshold);
    rotations = NaN(1,size(navData.baselineRot,2));
    for dof = 1:size(navData.baselineRot,2)
        rotations(dof) = sum(navData.baselineRot(ixThreshold,dof)./costThreshold)/sum(1./costThreshold);
    end
    motion(navCounter,1:3) = -1*rotations; % baseline with trajectory rotated by theta
                                           % simulates rotation of -1*theta

    % Determine translations from phase difference between SNAV and best
    % matched baseline scan (doi.org/10.1002/mrm.10012)
    b = angle(navData.baseline(ix(1),:).*conj(navData.snavs(navCounter,:)))'; % phase differences
    A = [navTraj.kx' navTraj.ky' navTraj.kz']; % k-space positions [cm-1]
    REF = abs(navData.snavs(1,:)); % use SNAV magnitude weighting to account
    REF(isnan(REF)) = 0.001;       % for higher noise in phase at low magnitudes
    W = diag(REF);
    Q = A'*W*A;
    x = Q\(A'*W*b./(2*pi));
    motion(navCounter,4:6)=10*x'; % convert to mm

end
disp('Done.');

end