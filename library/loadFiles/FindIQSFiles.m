function [IQSL1filePath, IQSL5filePath] = FindIQSFiles(inputFilePath, opsWindow)
% 
%
% Written by Simone Zocca

tlmPath = strcat(inputFilePath, filesep, "L0", filesep, "IQS");
files = dir(tlmPath);

%--- Find all text files matching the OP
Idxs = find(contains({files.name}, strcat(opsWindow, ".bin")));

IQSL1filePath = [];
IQSL5filePath = [];

if isscalar(Idxs) || numel(Idxs) == 2
    for i = 1:numel(Idxs)
        if contains(files(Idxs(i)).name, "L1") 
            IQSL1filePath = fullfile(tlmPath, files(Idxs(i)).name);
        end
        if contains(files(Idxs(i)).name, "L5")
            IQSL5filePath = fullfile(tlmPath, files(Idxs(i)).name);
        end
    end
elseif numel(Idxs) > 2
    warning('Incorrect number of IQS files found, check for overlapping names');
end