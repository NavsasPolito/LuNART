function [ACQ] = TxtParserAcq(filePath)
% Paste telemetry acquisition file from txt format
%
% Written by Simone Zocca

fID = fopen(filePath);

line = fgetl(fID);
Idx = 1;

while (line ~= -1)
    outPut = sscanf(line, "senderId: %d messageType: ACQ rxTime: %f signalId: %d svid: %d doppler: %f codePhase: %f");

    measures = regexp(line, '\[ ', 'split');

    values = split(measures(2), ' ');

    ACQ(Idx).rxTime = outPut(2);
    ACQ(Idx).signalId = outPut(3);
    ACQ(Idx).svId = outPut(4);
    ACQ(Idx).doppler = outPut(5);
    ACQ(Idx).codePhase = outPut(6);

    len = find(ismember(values, ']')) - 1;
    ACQ(Idx).acfCorrLength = len;
    ACQ(Idx).acfCorr = str2double(values(1:len));


    ACQ(Idx).noiseFloor = str2double(values(len + 3));
    ACQ(Idx).acqMode = str2double(values(len + 5));
    ACQ(Idx).CN0 = str2double(values(len + 7));

    Idx = Idx + 1;
    line = fgetl(fID);
end


