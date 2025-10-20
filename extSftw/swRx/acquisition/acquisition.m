function acqResults = acquisition(fid, settings,app)
%ACQUISITION Launches the GNSS signal acquisition
%   Depending on the signal, launch the proper function

if settings.receiverMode==1 && settings.doAcquisition
    fprintf('\n  +--------------------  Acquisition stage  ----------------------+\n');
    
    %--- Launch acquisition stage
    acqResults = acquisitionL1E1(fid, settings,app);
    
    %--- Save the acquisition results to a file
    try
        disp('Saving Acquisition results to file.')
        save(settings.saveAcqNameL1, 'acqResults', 'settings');
    catch
        errStruct = lasterror;
        disp(['Error: Saving failed: ' errStruct.message]);
    end

    %--- Plot acquisition results
    plotAcquisition(acqResults, settings);

else
    acqResults = [];
end