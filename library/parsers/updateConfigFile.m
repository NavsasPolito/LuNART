function updateConfigFile(filename, settings)
    % Open the file for writing (overwrite mode)
    fid = fopen(filename, 'w');
    
    % Iterate through each field in the settings structure
    fields = fieldnames(settings);
    for i = 1:length(fields)
        key = fields{i};
        value = settings.(key);
        
        % Convert value to string format if necessary
        if iscell(value)
            value = strjoin(value, ','); % Join cell array into comma-separated string
        elseif isnumeric(value)
            value = num2str(value); % Convert numeric values to string
        end
        
        % Write key-value pair to file
        fprintf(fid, '%s=%s\n', key, value);
    end
    
    % Close the file
    fclose(fid);
end