function [obs] = parseObs_ASI(RAW, channel, time)
% parseObs_ASI extract and format Qascom's NEIL RAW data to be visualized through
% the ASI GNSS Analysis Tool
%
% Version: v1.0
% Authored by Dr. Alex Minetto, Dr. Simone Zocca, Oliviero Vouch
% Supervised by Prof. Fabio Dovis
% Navigation Signal Analysis and Simulation Research Group (NavSAS)
% Department of Electronics and Telecommunications (DET)
% Politecnico di Torino (Turin, Italy) for Italian Space Agency (ASI)
%
% Input:        - Parsed telemetry data (RAW, NAV)
%               - Settings skipUnstamped, fullTimeVec
%
% Output:       - ObsSolutions Structure
%
% Copyright:    Copyright (C) 2022 Politecnico di Torino
%               The information contained in this document is property of
%               Politecnico di Torinio Except as specifically authorised in writing by
%               Politecnico di Torino, the holder of this document shall keep all
%               information contained here in confidential and shall protect
%               same in whole or in part from disclosure and dissemination
%               to all third parties to the same degree it protects its own
%               confidential information.

%--- Find which indexes we are considering
% useful for SURFACE to only take PRNs present in the selected interval
[~,~,rawIdxs] = intersect(time, [RAW.rxTime]);
%--- Find which PRNs are present in that window
PRN = unique([RAW(rawIdxs).svId]);

%--- Initialize
obs = struct([]);

%--- Obtain the common time array to the whole observation window
for svidIdx = 1:length(PRN)
    %--- Isolate data from one PRN
    data = [RAW.svId];
    out  = RAW(1, data == PRN(svidIdx));
    %--- Sort (just in case)
    [~,idx] = sort([out.rxTime]);
    out = out(idx);
    %--- Find indexes
    [~,timeIdxRaw, rawIdxs] = intersect(time, [out.rxTime]);

    %--- PRN, SV and channel
    if strcmp(channel{1}(1), "L")
        const = "G";
    elseif strcmp(channel{1}(1), "E")
        const = "E";
    else
        const = "X";
    end
    obs(svidIdx).SV      = strcat(const, string(PRN(svidIdx)));
    obs(svidIdx).channel = channel;
    obs(svidIdx).PRN     = PRN(svidIdx);
    %--- Time
    obs(svidIdx).rxTime     = time;
    obs(svidIdx).weekNumber = floor(time / (7 * 86400));
    obs(svidIdx).GPStime    = rem(time, 7 * 86400);
    %--- Initialize timestamps with NaN
    obs(svidIdx).Doppler      = NaN(1,numel(time));
    obs(svidIdx).DopplerRate  = NaN(1,numel(time));
    obs(svidIdx).CarrierPhase = NaN(1,numel(time));
    obs(svidIdx).rawP         = NaN(1,numel(time));
    obs(svidIdx).cn0          = NaN(1,numel(time));
    %--- Fill observables with data
    obs(svidIdx).Doppler(timeIdxRaw)      = [out(rawIdxs).fdRaw];
    obs(svidIdx).DopplerRate(timeIdxRaw)  = [out(rawIdxs).fdRateRaw];
    obs(svidIdx).CarrierPhase(timeIdxRaw) = [out(rawIdxs).carrierPhase];
    obs(svidIdx).rawP(timeIdxRaw)         = [out(rawIdxs).prRaw];
    obs(svidIdx).cn0(timeIdxRaw)          = [out(rawIdxs).cn0];
end