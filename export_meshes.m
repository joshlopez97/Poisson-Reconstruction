load data/aligned_mesh_data.mat
load data/reconstruction_grab_0.mat

% Note: Could not get RGB data to work with point cloud
rgbImageL = imread('/Users/groot/Downloads/grab_0/color_C1_01.png');
rgbImageR = imread('/Users/groot/Downloads/grab_0/color_C0_01.png');
colorL = ones(3,size(xL,2));
for i=1:size(xL,2)
    x = xL(1,i);
    y = xL(2,i);
    colorL(:,i) = rgbImageL(y,x,:);
end

colorR = ones(3,size(xL,2));
for i=1:size(xR,2)
    x = xR(1,i);
    y = xR(2,i);
    colorR(:,i) = rgbImageR(y,x,:);
end

xColor = (colorR + colorL) / 2;


% create .ply files using mesh_2_ply function
mesh_2_ply(X0, xColor, tri0, 'X0_data.ply');
mesh_2_ply(X2, xColor, tri2, 'X2_data.ply');