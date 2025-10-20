function [ACQfilePath, RAWfilePath, NAVfilePath] = FindTelemetryTxtFiles(inputFilePath, opsWindow)
% 
%
% Written by Simone Zocca

tlmPath = strcat(inputFilePath, filesep, "L0", filesep, "TLM");
files = dir(tlmPath);

%--- Find all text files matching the OP
Idxs = find(contains({files.name}, strcat(opsWindow, ".txt")));

if numel(Idxs) == 3
    for i = 1:3
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
else
    warning('Multiple telemtry files found, check for overlapping names');

    ACQfilePath = [];
    NAVfilePath = [];
    RAWfilePath = [];
end

