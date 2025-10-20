function settings = parseConfigFile(filename)
    % Open the file
    fid = fopen(filename, 'r');
    
    % Initialize an empty structure
    settings = struct();
    
    % Read the file line by line
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || line(1) == '#'
            continue; % Skip empty lines or comments
        end
        
        % Split the line at the '='
        tokens = strsplit(line, '=');
        
        % Extract the key and value
        key = strtrim(tokens{1});
        value = strtrim(tokens{2});
        
        % Process the value
        if contains(value, ',')
            value = strsplit(value,','); % Convert comma-separated strings into a cell array
        %elseif all(isstrprop(value, 'digit') | isstrprop(value, 'punct'))
        %    value = str2num(value); % Convert to numeric if possible
        end
        
        % Assign the value to the structure
        settings.(key) = value;
    end
    
    % Close the file
    fclose(fid);
end
