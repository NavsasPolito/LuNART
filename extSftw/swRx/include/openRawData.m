function [settings, fid] = openRawData(settings)
%OPENRAWDATA Opens the raw samples file
%   This function loads the raw samples file and checks if
%   everything is right

%--- Open the signal. If success, then process the data, else stop execution
[fid, message] = fopen(settings.rawFileL1, 'rb');

if fid < 1
    fprintf('Error: unable to read file %s\n%s.\nExiting...\n', settings.rawFileL1, message);
    settings.exit = 1;
else
    if strcmpi(settings.frontend,'qascom-lugre') || strcmpi(settings.frontend,'qascom-lugre_old')
        [settings] = readQascomLugreData(fid,settings);
    end
    %--- Check raw data file size for tracking
    if settings.doTracking
        stat = dir(settings.rawFileL1);
        
        bytesPerSample = computeSkipFactor(settings);
        nBytes = stat.bytes;
        if strcmpi(settings.frontend,'qascom-lugre') || strcmpi(settings.frontend,'qascom-lugre_old')
            nBytes = stat.bytes-(10+52+3); % header + metadata offset + footer
        end
        
        availableSamples = nBytes / bytesPerSample;
        availableMsFile = availableSamples/settings.samplingFreq*1000;

        if settings.skipFLL
            FLLtime = 0;
        else
            FLLtime = settings.FLLtime;
        end
        availableMsTracking = availableMsFile - settings.skipSeconds*1000 - FLLtime -1; % -1 ms to be safe
        availableMsTracking = floor(availableMsTracking);
        
        %--- Compute the floor mod 1 second, to proper initialize traking
        %availableMsTracking = availableMsTracking-mod(availableMsTracking, 1000);
        
        if settings.sToProcess*1000 > availableMsTracking
            disp('Warning: not enough samples are available in your file.');
            disp(['   The tracking stage will stop after ' num2str(availableMsTracking/1000) ' seconds (settings overwritten).']);
            settings.sToProcess = availableMsTracking/1000;
        end

        %--- Compute second to process if it's activated in initSetting.
        if settings.checkSecToProcess
            settings.sToProcess = floor(availableMsTracking/1000);
            disp(['There are ' num2str(floor(availableMsTracking/1000)) ' seconds available for Tracking loop.']);
        end 
    end
end