function [settings] = readQascomLugreData(fid,settings)
% read binary data according to Qascom NEIL Payload Command and Telemetry
% Issue 5.0
% Issue 9.0

% Written by Andrea Nardin
% politecnico di Torino 2022

% skip 10 bytes header
headerLen = 10;
footerLen = 3;
fseek(fid,headerLen,'bof');

machineByteOrder = 'l';
offsetBytes = 52; % after preamble, from ICD

% Receiver time
rxtime = fread(fid,1,'double',machineByteOrder);

if strcmpi(settings.frontend,'qascom-lugre_old')
    % Data format according to NEIL Payload Command and Telemetry Issue 5.0
    % Total number of samples
    nSamples = fread(fid,1,'uint64',machineByteOrder);
else 
    %(from Neil ICD v9.0)
    % Total number of samples
    nSamples = fread(fid,1,'uint32',machineByteOrder);
    % blockData 
    blockData = fread(fid,1,'uint32',machineByteOrder);
end

% Samples format type
samplesType = fread(fid,1,'uint8',machineByteOrder);

switch samplesType
    case 0
        samplingMode = 'real';
        nChannels = 1;
    case 1
        samplingMode = 'IQ';
        nChannels = 1;
    case 2
        samplingMode = 'real';
        nChannels = 2;
    case 3
        samplingMode = 'IQ';
        nChannels = 2;
    otherwise
        error 'something went wrong while reading the binary'
end

% Spectrum inversion flag
spectrumInv = fread(fid, 1, 'uint16',machineByteOrder);

% Number of quantization bits
quantBits = fread(fid, 1, 'uint8',machineByteOrder);

% Sampling frequency
samplingFreq = fread(fid, 1, 'double',machineByteOrder);

% Carrier central frequency
centralFreq = fread(fid, 1, 'double',machineByteOrder);

% Signal intermediate frequency
intermediateFreq = fread(fid, 1, 'double',machineByteOrder);

% Signal bandwidth
bandwidth = fread(fid, 1, 'double',machineByteOrder);


% update settings
settings.samplingMode = samplingMode;
settings.nChannels = nChannels;
settings.samplingFreq = samplingFreq;
settings.IF = intermediateFreq;


% switch samplingMode
%     case 'IQ'
%         settings.dataType = 'int8';
%     case 'real'
%         settings.dataType = 'int16';
%         warning 'check datatype with real signals'
%     otherwise
%         error 'unknown sampling mode'
% end

switch quantBits
    case 4
        settings.dataType = 'bit4';
    case 8
        settings.dataType = 'int8';
    case 16
        settings.dataType = 'int16';
    otherwise
        error 'unknown sampling mode'
end

if nChannels==2
    error 'not sure how to read 2 channels, see the Qascom ICD'
end

% recompute skipNoOfBytes
bytesPerSample = computeSkipFactor(settings);
settings.skipNumberOfSamples = (headerLen + offsetBytes)/bytesPerSample + settings.skipSeconds*settings.samplingFreq;

% Check data read correctness
% count no. of available samples
stat = dir(settings.rawFileL1);
nBytes = stat.bytes-(headerLen+offsetBytes+footerLen); % header + metadata offset + footer
availableSamples = nBytes / bytesPerSample;
% check with no. of samples in header
if availableSamples ~= nSamples
    warning 'No. of samples declared in the header different from no. of samples in the file. Might be due to bad data reading. Please check your input file and settings.'
end
