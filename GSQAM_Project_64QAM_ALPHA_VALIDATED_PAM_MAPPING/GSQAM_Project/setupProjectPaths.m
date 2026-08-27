function setupProjectPaths()
%SETUPPROJECTPATHS Add all project subfolders to MATLAB path.
root = fileparts(mfilename('fullpath'));
addpath(root);
addpath(fullfile(root,'modulation'));
addpath(fullfile(root,'receiver'));
addpath(fullfile(root,'channels'));
addpath(fullfile(root,'metrics'));
addpath(fullfile(root,'plotting'));
addpath(fullfile(root,'analysis'));
end
