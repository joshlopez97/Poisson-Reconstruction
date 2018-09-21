%
% load results of reconstruction
%
grab_0 = load('data/reconstruction_grab_0');
X0 = grab_0.('X');
xL0 = grab_0.('xL');
xR0 = grab_0.('xR');

grab_2 = load('data/reconstruction_grab_2');
X2 = grab_2.('X');
xL2 = grab_2.('xL');
xR2 = grab_2.('xR');


% create logical matrix of points that are inside of bouding box
inside0 = (X0(1,:) <= 200 & X0(1,:) >= 100) & (X0(2,:) <= 250 & X0(2 ,:) >= 60) & (X0(3,:) <= 90 & X0(3,:) >= 30);
inside2 = (X2(1,:) <= 200 & X2(1,:) >= 50) & (X2(2,:) <= 250 & X2(2 ,:) >= 75) & (X2(3,:) <= 60 & X2(3,:) >= 0);

% keep only only points inside bounding box (2D and 3D points)
X0 = X0(:,inside0);
xL0 = xL0(:,inside0);
xR0 = xR0(:,inside0);
X2 = X2(:,inside2);
xL2 = xL2(:,inside2);
xR2 = xR2(:,inside2);

[R,T] = icp(X0,X2,10);
X0 = R*X0 + repmat(T,1,length(X0));

% combine points from both scans
X = [X0 X2];
xL = [xL0 xL2];
xR = [xR0 xR2];


% triangulate remaining points
% tri = delaunay(X(1,:),X(2,:),X(3,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% display results
%
% figure(1); clf;
% h = trisurf(tri,X(1,:),X(2,:),X(3,:));
% set(h,'edgecolor','none')
% set(gca,'projection','perspective')
% axis image; axis vis3d;
figure(1); clf; plot3(X(1,:),X(2,:),X(3,:),'.');
axis image; axis vis3d; grid on;
hold on;
axis([-200 400 -200 300 -200 200])
set(gca,'projection','perspective')
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');

% rotate the view around so we see from
% the front  (can also do this with the mouse in the gui)
camorbit(45,0);
camorbit(0,-120);
camroll(-8);
