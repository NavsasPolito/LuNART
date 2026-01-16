function [ACQfilePath, RAWfilePath, NAVfilePath] = FindTelemetryTxtFiles(inputFilePath, opsWindow)
%
%
% Written by Simone Zocca
ACQfilePath = [];
NAVfilePath = [];
RAWfilePath = [];

tlmPath = strcat(inputFilePath, filesep, "L0", filesep, "TLM");
files = dir(tlmPath);

%--- Find all text files matching the OP
Idxs = find(contains({files.name}, strcat(opsWindow, ".txt")));

for i = 1:numel(Idxs)
    if contains(files(Idxs(i)).name, "ACQ")
        ACQfilePath = fullfile(tlmPath, files(Idxs(i)).name);
    end
    if contains(files(Idxs(i)).name, "NAV")
        NAVfilePath = fullfile(tlmPath, files(Idxs(i)).name);
    end
    if contains(files(Idxs(i)).name, "RAW")
        RAWfilePath = fullfile(tlmPath, files(Idxs(i)).name);
    end
end

if isempty(ACQfilePath) || isempty(NAVfilePath) || isempty(RAWfilePath)
    warning('Multiple telemtry files found, check for overlapping names');
end