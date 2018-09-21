%
% load results of reconstruction
%
load data/calibration_data
grab_0 = load('data/reconstruction_grab_0');
X0 = grab_0.('X');
xL0 = grab_0.('xL');
xR0 = grab_0.('xR');

grab_2 = load('data/reconstruction_grab_2');
X2 = grab_2.('X');
xL2 = grab_2.('xL');
xR2 = grab_2.('xR');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cleaning step 1: remove points outside known bounding box
%

% create logical matrix of points that are inside of bouding box
inside0 = (X0(1,:) <= 190 & X0(1,:) >= 100) & (X0(2,:) <= 250 & X0(2 ,:) >= 60) & (X0(3,:) <= 90 & X0(3,:) >= 30);

% custom bounding box for top of object
inside0 = inside0 & ~(X0(2,:) < 120 & X0(3,:) < 45);
inside2 = (X2(1,:) <= 200 & X2(1,:) >= 50) & (X2(2,:) <= 250 & X2(2 ,:) >= 75) & (X2(3,:) <= 60 & X2(3,:) >= 0);

% keep only only points inside bounding box (2D and 3D points)
X0 = X0(:,inside0);
xL0 = xL0(:,inside0);
xR0 = xR0(:,inside0);
X2 = X2(:,inside2);
xL2 = xL2(:,inside2);
xR2 = xR2(:,inside2);

% triangulate remaining points
tri0 = delaunay(xL0(1,:),xL0(2,:));
tri2 = delaunay(xL2(1,:),xL2(2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cleaning step 2: remove triangles which have long edges
%

% USER-DEFINED: Threshold for maximum edge length in triangle allowed
TRITHRESH = 7; % 10mm

% Logical matrix of every triangle that has all edges lower than TRITHRESH
below_thresh0 = true(size(tri0,1),1);

% Logical matrix of every point that appears in a triangle
appear_in_tri0 = false(size(X0,2),1);
for i = 1:size(tri0,1)
    % indices of each point in triangle (corresponds to X)
    p1 = tri0(i,1);
    p2 = tri0(i,2);
    p3 = tri0(i,3);
    
    % check if any distance between points > TRITHRESH
    if norm(X0(:,p1)' - X0(:,p2)') > TRITHRESH...
            || norm(X0(:,p1)' - X0(:,p3)') > TRITHRESH...
            || norm(X0(:,p2)' - X0(:,p3)') > TRITHRESH
        
        % if so, triangle will be removed
        below_thresh0(i,:) = false;     
    else
        % if triangle is kept, all three points are kept
        appear_in_tri0(p1,:) = true;
        appear_in_tri0(p2,:) = true;
        appear_in_tri0(p3,:) = true;
    end
end

% repeat same process for second mesh
below_thresh2 = true(size(tri2,1),1);

% Logical matrix of every point that appears in a triangle
appear_in_tri2 = false(size(X2,2),1);
for i = 1:size(tri2,1)
    % indices of each point in triangle (corresponds to X)
    p1 = tri2(i,1);
    p2 = tri2(i,2);
    p3 = tri2(i,3);
    
    % check if any distance between points > TRITHRESH
    if norm(X2(:,p1)' - X2(:,p2)') > TRITHRESH...
            || norm(X2(:,p1)' - X2(:,p3)') > TRITHRESH...
            || norm(X2(:,p2)' - X2(:,p3)') > TRITHRESH
        
        % if so, triangle will be removed
        below_thresh2(i,:) = false;     
    else
        % if triangle is kept, all three points are kept
        appear_in_tri2(p1,:) = true;
        appear_in_tri2(p2,:) = true;
        appear_in_tri2(p3,:) = true;
    end
end

% remove triangles with any edge above TRITHRESH
tri2 = tri2(below_thresh2,:);

% adjustment matrix to fix indices in tri when unused X0 points are removed
adjust0 = zeros(size(tri0));
adjust2 = zeros(size(tri2));

for i = 1:size(X0,2)
    % if point is going to be removed, every subsequent index must be
    % shifted left by one (decrement by one)
    if appear_in_tri0(i,:) == false
        adjust0 = adjust0 - (1 * (tri0 > i));
    end
end

for i = 1:size(X2,2)
    % if point is going to be removed, every subsequent index must be
    % shifted left by one (decrement by one)
    if appear_in_tri2(i,:) == false
        adjust2 = adjust2 - (1 * (tri2 > i));
    end
end


% adjust indices in tri to account for removed points
tri0 = tri0 + adjust0;
tri2 = tri2 + adjust2;

% remove unused points in X, xL, and xR that do not appear in
% any triangle
X0 = X0(:,appear_in_tri0);
xL0 = xL0(:,appear_in_tri0);
xR0 = xR0(:,appear_in_tri0);
X2 = X2(:,appear_in_tri2);
xL2 = xL2(:,appear_in_tri2);
xR2 = xR2(:,appear_in_tri2);
X2 = (build_rotation_matrix(0, pi, 0) * X2) + repmat([275; -5; 100], 1, length(X2));

% [R,T] = icp(X2,X0,10);
% X0 = R*X0 + repmat(T,1,length(X0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% display results
%
figure(1); clf;
h = trisurf(tri0,X0(1,:),X0(2,:),X0(3,:));
set(h,'edgecolor','none')
set(gca,'projection','perspective')
axis image; axis vis3d;
hold on;
h = trisurf(tri2,X2(1,:),X2(2,:),X2(3,:));
set(h,'edgecolor','none')
set(gca,'projection','perspective')
axis image; axis vis3d;

% rotate the view around so we see from
% the front  (can also do this with the mouse in the gui)
camorbit(45,0);
camorbit(0,-120);
camroll(-8);
X = [X0 X2];
hold on;
% plot 3D view
figure(2); clf; plot3(X(1,:),X(2,:),X(3,:),'.');
axis image; axis vis3d; grid on;
hold on;
plot3(camL.t(1),camL.t(2),camL.t(3),'ro')
plot3(camR.t(1),camR.t(2),camR.t(3),'ro')
axis([-200 400 -200 300 -200 200])
set(gca,'projection','perspective')
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');

save('aligned_mesh_data.mat','X0','X2','tri0','tri2');
