function settings = setWorkingPath(settings)

%--- if folder does not exist, create it
if ~exist(settings.workingPath, 'dir')
    system(['mkdir ' settings.workingPath]);
end

W = what(settings.workingPath);

%--- set absolute path (regardless to the OS)
settings.workingPath = W.path;
