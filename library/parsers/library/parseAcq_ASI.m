function [acq] = parseAcq_ASI(ACQ, channel)

PRN = unique([ACQ.svId]);
acq = struct([]);

for svidIdx = 1:length(PRN)
        data = [ACQ.svId];
        out = ACQ(1, data == PRN(svidIdx));

        acq(svidIdx).channel    = channel;
        acq(svidIdx).rxTime     = [out.rxTime];
        acq(svidIdx).signalId   = unique([out.signalId]);
        acq(svidIdx).cno        = [out.CN0];
        acq(svidIdx).doppler    = [out.doppler];
        acq(svidIdx).PRN        = unique([out.svId]);
        acq(svidIdx).codePhase  = [out.codePhase];
        %acq(svidIdx).acfCorrLength = [out.acfCorrLength];
        %acq(svidIdx).acfCorr = [out.acfCorr];
        acq(svidIdx).noiseFloor = [out.noiseFloor];
        %acq(svidIdx).acqMode = unique([out.acqMode]);
end