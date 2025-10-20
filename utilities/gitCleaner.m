%% Removes parsed data
dataContent = dir("data");

for dataContentId = 1:numel(dataContent)
    if contains(dataContent(dataContentId).name,"OP")
        rmdir(strcat("data\",dataContent(dataContentId).name),'s');
    elseif contains(dataContent(dataContentId).name,"pred")
        delete(strcat("data\",dataContent(dataContentId).name));
    end
end

try
    rmdir("data");
catch
    warning("No data folder");
end

%% Delete log file and counters (LuNART will recreate it on startup)

fclose all;
delete("utilities\log.txt");
delete("settings\expCounters.mat");
delete("settings\expCompleted.mat");
delete("settings\OSR.mat");

%% Remove auto-save files

% Refresh file system path caches
rehash path

% Get all .asv files in the current folder and its subfolders
asvFiles = dir(fullfile(pwd, '**', '*.asv'));

% Display the number of files found
fprintf('Found %d .asv file(s) to delete.\n', numel(asvFiles));

% Delete the .asv files
for iFile = 1:numel(asvFiles)
    asvFilePath = fullfile(asvFiles(iFile).folder, asvFiles(iFile).name);
    delete(asvFilePath);
    fprintf('Deleted: %s\n', asvFilePath);
end

fprintf('All .asv files have been deleted.\n');