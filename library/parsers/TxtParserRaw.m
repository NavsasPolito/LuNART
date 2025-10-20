function [RAW] = TxtParserRaw(filePath)
% Paste telemetry raw file from txt format
%
% Written by Simone Zocca

fID = fopen(filePath);

line = fgetl(fID);
Idx = 1;

while (line ~= -1)
    outPut = sscanf(line, "senderId: %d messageType: RAW rxTime: %f");

    measures = regexp(line, '\[ ', 'split');
    values = split(measures(2), ' ');
    values = values(2:2:end);

    numMeas = floor(numel(values) / 7);

    for i = 1:numMeas
        RAW(Idx).rxTime = outPut(2);
        RAW(Idx).numMeas = numMeas;

        RAW(Idx).signalId = str2double(values((i - 1) * 7 + 4));
        RAW(Idx).svId = str2double(values((i - 1) * 7 + 1));
        RAW(Idx).fdRaw = str2double(values((i - 1) * 7 + 5));
        RAW(Idx).fdRateRaw = str2double(values((i - 1) * 7 + 7));
        RAW(Idx).carrierPhase = str2double(values((i - 1) * 7 + 6));
        RAW(Idx).prRaw = str2double(values((i - 1) * 7 + 2));
        RAW(Idx).cn0 = str2double(values((i - 1) * 7 + 3));

        Idx = Idx + 1;
    end

    line = fgetl(fID);
end
