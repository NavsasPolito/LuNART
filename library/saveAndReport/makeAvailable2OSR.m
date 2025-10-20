function [newMessage] = makeAvailable2OSR(currentOp,exp,resultsFolderName,reportName,docMetaFields,app)
%makeAvailable2OSR include the selected report (flagged as relevant for
%OPS) into the list of candidate reports for Operation Summary Report
%   Detailed explanation goes here

addpath("library");

try
    % ---- Pick report filename and filepath
    expReportFilepath = strcat(resultsFolderName,'\',reportName);

    % ---- add this to a dedicated list for the current
    % experiment
    date_obj_r = datetime(docMetaFields{1}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
    date_r = datestr(date_obj_r, 'dd-mm-yy HH:MM');

    app.OSR.(currentOp).(exp) = [app.OSR.(currentOp).(exp);{docMetaFields, expReportFilepath, reportName, strjoin([{char(reportName)},{date_r}])}];

    % ---- Convert date to be visualized in the list

    % Loop through each row to extract the dates
    for i = 1:size(app.OSR.(currentOp).(exp), 1)
        % Extract the date string from the first element of the first column in each row
        dates{i,1} = app.OSR.(currentOp).(exp){i, 1}(1); % This accesses the date part of each row
    end

    % Convert dates to the desired format (optional)
    for i = 1:length(dates)
        % Convert to datetime object
        date_obj = datetime(dates{i}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');

        % Convert back to string in the desired format
        dates{i,1} = datestr(date_obj, 'dd-mm-yy HH:MM');
    end

    % Create labels to be visualized for reports
    compositeArray = [app.OSR.(currentOp).(exp)(:,3) dates];

    % Initialize a cell array to store the concatenated strings
    outputStrings = cell(size(compositeArray, 1), 1);

    % Loop through each row to concatenate the name and date with "_"
    for i = 1:size(compositeArray, 1)
        % Convert the first part to a string (name)
        part1 = char(compositeArray{i, 1});
        % Convert the second part to a string (date)
        part2 = char(compositeArray{i, 2});
        % Concatenate with an underscore in between
        outputStrings{i} = [part1,' ', part2];
    end

    % ---- Populate the lists on the OSR tab
    app.(['ListBox_', exp]).Items = flipud(string(outputStrings));
    app.(['ListBox_', exp]).Value = string(outputStrings(end));

    newMessage = sprintf("Report can be selected for OSR");
catch
    newMessage = sprintf("Error! Report cannot be selected for OSR");
end