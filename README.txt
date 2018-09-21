decode.m – Decodes points from a set of images that are projected with gray code and returns an array where each element contains the decoded pixel value and a binary mask indicating which pixels could be reliably decoded.

reconstruct.m – Calls decode.m four times and intersects the results to obtain pixel coordinates for the right and left camera. This information is used to triangulate the points into 3D points using the camera calibration information.

mesh.m – Deletes noisy points using bounded box pruning and triangle pruning to obtain cleaner 3D points for both scans. The scans are then aligned using icp.m

icp.m – Computes the rotation matrix and translation matrix needed to align two sets of 3D points as accurately as possible.

demo.m – Runs all the above functions/scripts as a pipeline to show an example of their functionality.

build_rotation_matrix.m – Creates rotation matrix based on given angles in radians.

export_meshes.m – Creates .ply exports of the meshes including the delaunay triangulation and color extracted from reference images.

triangulate.m – Creates 3D world coordinates from 3D image coordinates using information about the camera used to capture the 2D points.