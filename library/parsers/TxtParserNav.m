function [NAV] = TxtParserNav(filePath)
% Paste telemetry nav file from txt format
%
% Written by Simone Zocca

fID = fopen(filePath);

line = fgetl(fID);
Idx = 1;

while (line ~= -1)
    outPut = sscanf(line, "senderId: %d messageType: NAV " + ...
        "rxTime: %f appName: NAV wn: %d tow: %d decimals: %f nSat: %d " + ...
        "posX: %f posY: %f posZ: %f " + ...
        "velX: %f velY: %f velZ: %f " + ...
        "posStd: %f velStd: %f timStd: %f " + ...
        "clockBias: %f clockDrift: %f ggto: %f " + ...
        "GDOP: %f PDOP: %f HDOP: %f VDOP: %f TDOP: %f");

    NAV(Idx).rxTime = outPut(2);
    NAV(Idx).wn = outPut(3);
    NAV(Idx).tow = outPut(4) + outPut(5);
    NAV(Idx).nSat = outPut(6);

    NAV(Idx).posX = outPut(7);
    NAV(Idx).posY = outPut(8);
    NAV(Idx).posZ = outPut(9);

    NAV(Idx).velX = outPut(10);
    NAV(Idx).velY = outPut(11);
    NAV(Idx).velZ = outPut(12);

    NAV(Idx).posStd = outPut(13);
    NAV(Idx).velStd = outPut(14);
    NAV(Idx).timStd = outPut(15);

    NAV(Idx).clockBias = outPut(16);
    NAV(Idx).clockDrift = outPut(17);
    NAV(Idx).ggto = outPut(18);

    NAV(Idx).GDOP = outPut(19);
    NAV(Idx).PDOP = outPut(20);
    NAV(Idx).HDOP = outPut(21);
    NAV(Idx).VDOP = outPut(22);
    NAV(Idx).TDOP = outPut(23);

    line = fgetl(fID);
    Idx = Idx + 1;
end


