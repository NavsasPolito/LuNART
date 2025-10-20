function settings = checkSettings(settings)

%--- Plot acquisition results
if settings.plotAcquisition && numel(settings.acqSatelliteList)==32
    choice = questdlg('Do you want to plot the acquisition results for all the PRNs?', ...
        'Plot all acquisitions?', ...
        'Yep, go on!', 'Ops, stop the receiver please!', 'Ops, stop the receiver please!');
    % Handle response
    switch choice
        case 'Ops, stop the receiver please!'
            settings.exit = 1;
    end
end

%--- Check loop stability 
if getTc(settings) * settings.pllNoiseBandwidth >= 0.4
    choice = questdlg(['Attention! Tc = ' num2str(getTc(settings)*1000) ' ms and Bn = ' num2str(settings.pllNoiseBandwidth) ' Hz. This might result in a non stable PLL filter...'], ...
        'Attention!', ...
        'I am aware, go on!', 'Ops, stop the receiver please!', 'Ops, stop the receiver please!');
    % Handle response
    switch choice
        case 'Ops, stop the receiver please!'
            settings.exit = 1;
    end
end

%--- Check order of operations 
if settings.doTracking && ~settings.doAcquisition
    disp('Error: you cannot run the tracking stage if you do not run the acquisition stage.')
    settings.exit = 1;
end

if settings.doNavigation && ~settings.doTracking
    disp('Error: you cannot run the navigation stage if you do not run the tracking stage.')
    settings.exit = 1;
end


% Checks to be ADDED

% - Tc must be overrided if needed
% - If you process a .bin file and the file does not exist or the filepath
% is empty, notify it to the user

