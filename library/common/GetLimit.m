function [navLimit, EpochLimit] = GetLimit(directory,file,varargin)
% This function returns the number of Epochs

% Load the obs file
path = fullfile(directory,file);
m = load(path);

% Return the obs limits
try
    EpochLimit = [1 length(m.obsSolutions(1).rawP)];
catch
    warning('Error in the extraction of observables limits')
end

if ~isempty(varargin)
    % Load the nav file
    path2 = fullfile(varargin{2},varargin{1});
    m2 = load(path2);

    % Return the nav limits
    try
        navLimit = [1 length(m2.navSolutions(1).weekNum)];
    catch
        navLimit = nan;
        warning('Error in the extraction of nav solutions limits');
    end
else
    navLimit = nan;
end