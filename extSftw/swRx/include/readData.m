function data = readData(fid, settings, samplesToRead)

switch settings.samplingMode
    case 'real'
        %--- read data
        [data, cntData] = fread(fid, samplesToRead, settings.dataType);
    case 'IQ'
        switch settings.frontend
            case '4tuNe_raw'
                %--- read data
                [data, cntData] = fread(fid, samplesToRead, settings.dataType);
                %--- convert to L1 only
                dataI = -2*mod(bitget(data(:), 16, 'uint16'),2) + 1;
                dataQ = -(-2*mod(bitget(data(:), 15, 'uint16'),2) + 1);
                %--- save to complex format
                data = dataI + 1i*dataQ;
            case {'SIGEv2_raw', 'SIGEv3_raw'}
                %--- read data
                samplesToRead = 2*samplesToRead;
                [data, cntData] = fread(fid, samplesToRead, settings.dataType);
                %--- from [0 1 2 3] to [+1 -1 +1 -1]
                data = -2*mod(data,2) + 1;
                %--- save to complex format
                data = data(1:2:end) + 1i*data(2:2:end);
            otherwise
                %--- read data
                samplesToRead = 2*samplesToRead;
                [data, cntData] = fread(fid, samplesToRead, settings.dataType);
                %--- save to complex format
                if settings.dataType=="bit4" && settings.frontend=="Qascom-LuGRE"
                    % 4 bit dataset causes Doppler estimation with opposite
                    % sign (badly written data?)
                    data = 1i*data(1:2:end) + data(2:2:end);
                else
                    data = data(1:2:end) + 1i*data(2:2:end);
                end

        end
    otherwise
        error('Attention: sampling mode %s not valid (readData.m).\n', settings.samplingMode)       
end

%--- Data offset removal
if settings.offsetRemoval
    if isfield(settings,'estOffset')
        data = data - settings.estOffset;
    end
end

%--- if did not read in enough samples, then could be out of data - better exit
if cntData ~= samplesToRead
    fclose(fid);
    error('Not able to read the specified number of samples, exiting...')
end

