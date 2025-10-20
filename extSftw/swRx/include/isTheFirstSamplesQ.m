function flagFirstQ = isTheFirstSamplesQ(settings)

flagFirstQ = 0;

if (strcmp(settings.frontend, 'SIGEv2_raw') || strcmp(settings.frontend, 'SIGEv3_raw'))
    
    %--- read data
    fd = fopen(settings.rawFileL1, 'rb');
    fseek(fd,0,'bof');
    [data,~] = fread(fd, 1, settings.dataType);
    
    %--- if it starts from a Q sample then skip it!
    if (data==2 || data==3)
        flagFirstQ = 1; % flag
    end
    
end
