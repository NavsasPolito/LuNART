function [tableEpochDate] = GetEpochDate(directory, file)
% This function returns a table with the date of the Epoch. The first column
% is the full date, the second column is just the date and the third column
% is the time

% Load the file
path = fullfile(directory, file);
m = load(path);

% Get the size of Epoch
% 0-1023
lengthEpoch = length(m.obsSolutions(1).GPStime);

% Get the Starting date
weekNumber = m.obsSolutions(1).weekNumber;

% Get the week number from 1980
% We do not know how the weekNumber is written in the dataset (resets or
% not)
if weekNumber(1) < 1023
    weeksecs = 7 * 86400 * (weekNumber + 2048);
elseif weekNumber(1) < 2047
    weeksecs = 7 * 86400 * (weekNumber + 1024);
else
    weeksecs = 7 * 86400 * weekNumber;
end

GPS0 = datetime(1980,1,6,0,0,0,'TimeZone','UTCLeapSeconds');

% Fill the table
numSat = size(m.obsSolutions,2);
tableEpochDatestr = strings(lengthEpoch,3);

time = GPS0 + seconds(weeksecs(1:lengthEpoch) + m.obsSolutions(1).GPStime(1:lengthEpoch));

for i = 1:lengthEpoch
    try
        aux = datestr(time(i),'yyyy-mm-dd HH:MM:SS.FFF');

        tableEpochDatestr(i,1) = convertCharsToStrings(aux(1:11));
        tableEpochDatestr(i,2) = convertCharsToStrings(aux(12:19));
        tableEpochDatestr(i,3) = convertCharsToStrings(aux(20:end));
    catch
        tableEpochDatestr(i,1) = "unknownDate";
        tableEpochDatestr(i,2) = "unknownTime";
        tableEpochDatestr(i,3) = "unknownMs";
    end
end

tableEpochDate = cellstr(tableEpochDatestr);
