function idx = findTimeLines(epochDate, settings)
% Find indexes of start and end of operation
%
% Written by Simone Zocca

try
    %--- Find OP start and end indexes
    idx.Start = find(ismember(string(vertcat(epochDate{:,2})),settings.startTime));
    idx.End   = find(ismember(string(vertcat(epochDate{:,2})),settings.endTime));
    %--- Obtain 30 minutes before and after OP
    idx.preTime = char(datetime(settings.startTime,'InputFormat','HH:mm:ss') - minutes(30));
    idx.postTime = char(datetime(settings.endTime,'InputFormat','HH:mm:ss') + minutes(30));
    %--- Find indexes
    idx.Pre  = find(ismember(string(vertcat(epochDate{:,2})),idx.preTime(13:20)));
    idx.Post = find(ismember(string(vertcat(epochDate{:,2})),idx.postTime(13:20)));
catch
    idx.Start = [];
    idx.End   = [];
    idx.Pre   = [];
    idx.Post  = [];
end