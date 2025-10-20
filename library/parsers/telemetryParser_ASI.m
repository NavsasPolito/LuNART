function [acqSolutions, obsSolutions, navSolutions] = telemetryParser_ASI(ACQ, RAW, NAV)
% TELEMETRYPARSER_ASI is an adaptation layer to the ASI analysis and
% processing TOOL. It parses telemetry data of the Qascom's NEIL receiver.
%  
% Authored by Dr. Alex Minetto, Dr. Simone Zocca, Dr. Oliviero Vouch
% Supervised by Prof. Fabio Dovis (LuGRE co-PI)
% Navigation Signal Analysis and Simulation Research Group (NavSAS)
% Department of Electronics and Telecommunications (DET)
% Politecnico di Torino (Turin, Italy) for Italian Space Agency (ASI)
%
% Input:        - Parsed telemetry data (ACQ, RAW, NAV, STA, POD)
%
% Output:       - ObsSolutions Structure
%               - navSolutions Structure
%
% Copyright:    Copyright (C) 2022 Politecnico di Torino
%               The information contained in this document is property of
%               Politecnico di Torinio Except as specifically authorised in writing by
%               Politecnico di Torino, the holder of this document shall keep all
%               information contained here in confidential and shall protect
%               same in whole or in part from disclosure and dissemination
%               to all third parties to the same degree it protects its own
%               confidential information.

%% Command Window 
fprintf("Parsing Telemetry Messages into ASI Analysis Tool interface data structures...");

%% Sort NAV and RAW (thanks FF)
if ~isempty(NAV)
    [~,idx] = sort([NAV.rxTime]);
    NAV = NAV(idx);
end
if ~isempty(RAW)
    [~,idx] = sort([RAW.rxTime]);
    RAW = RAW(idx);

    %--- Generate a common and continuous time reference
    time = min([RAW.rxTime]):1:max([RAW.rxTime]);
end

%% Generation of a common reference time
% --- Extra fields
navSolutions.rxTime  = time;
navSolutions.weekNum = floor(time / (7 * 86400));
navSolutions.tow     = rem(time, 7 * 86400);

% --- navSolutions initialization
navSolutions.X             = NaN(1,length(time));
navSolutions.Y             = NaN(1,length(time));
navSolutions.Z             = NaN(1,length(time));
navSolutions.X_eci         = NaN(1,length(time));
navSolutions.Y_eci         = NaN(1,length(time));
navSolutions.Z_eci         = NaN(1,length(time));
navSolutions.Vx            = NaN(1,length(time));
navSolutions.Vy            = NaN(1,length(time));
navSolutions.Vz            = NaN(1,length(time));
navSolutions.Vx_eci        = NaN(1,length(time));
navSolutions.Vy_eci        = NaN(1,length(time));
navSolutions.Vz_eci        = NaN(1,length(time));
navSolutions.Clock_GPS     = NaN(1,length(time));
navSolutions.Drift_Clk_GPS = NaN(1,length(time));
navSolutions.DOP           = NaN(5,length(time));
navSolutions.posStd        = NaN(1,length(time));
navSolutions.velStd        = NaN(1,length(time));
navSolutions.timeStd       = NaN(1,length(time));
navSolutions.ggto          = NaN(1,length(time));
navSolutions.nSat          = NaN(1,length(time));
utcTime                    = NaN(6,length(time));

if ~isempty(NAV)
    %--- Find indexes of NAV in the common reference frame
    [~, timeIdxNav, navIdxs] = intersect(time, [NAV.rxTime]);
    % --- State estimate
    navSolutions.X(timeIdxNav)             = [NAV(navIdxs).posX];
    navSolutions.Y(timeIdxNav)             = [NAV(navIdxs).posY];
    navSolutions.Z(timeIdxNav)             = [NAV(navIdxs).posZ];
    navSolutions.Clock_GPS(timeIdxNav)     = [NAV(navIdxs).clockBias];
    navSolutions.Vx(timeIdxNav)            = [NAV(navIdxs).velX];
    navSolutions.Vy(timeIdxNav)            = [NAV(navIdxs).velY];
    navSolutions.Vz(timeIdxNav)            = [NAV(navIdxs).velZ];
    navSolutions.Drift_Clk_GPS(timeIdxNav) = [NAV(navIdxs).clockDrift];

    navSolutions.ggto(timeIdxNav) = [NAV(navIdxs).ggto];       % Galileo (?) to GPS (?) time-offset
    navSolutions.nSat(timeIdxNav) = [NAV(navIdxs).nSat];       % Number of signals used in PVT estimation

    % --- Dilution of precision (DOP) terms
    navSolutions.DOP(:,timeIdxNav) = [[NAV(navIdxs).GDOP];[NAV(navIdxs).PDOP];[NAV(navIdxs).HDOP];[NAV(navIdxs).VDOP];[NAV(navIdxs).TDOP]];

    % --- State estimation uncertainties
    navSolutions.posStd(timeIdxNav)  = [NAV(navIdxs).posStd];
    navSolutions.velStd(timeIdxNav)  = [NAV(navIdxs).velStd];
    navSolutions.timeStd(timeIdxNav) = [NAV(navIdxs).timStd];

    if ~isempty(navIdxs)
        % --- Other coordinates conversions
        utcTime(:,timeIdxNav) = Gps2Utc([[NAV(navIdxs).wn]',[NAV(navIdxs).tow]'])';

        %--- Initialize
        p_eci = nan(size(NAV(navIdxs),2),3);
        v_eci = nan(size(NAV(navIdxs),2),3);

        for t_idx = 1:length(timeIdxNav)
            [p_eci(t_idx,:), v_eci(t_idx,:)] = ecef2eci(utcTime(:,timeIdxNav(t_idx))',[[NAV(t_idx).posX]' [NAV(t_idx).posY]' [NAV(t_idx).posZ]'],[[NAV(t_idx).velX]' [NAV(t_idx).velY]' [NAV(t_idx).velZ]'] );
        end

        navSolutions.X_eci(timeIdxNav) = p_eci(:,1)';
        navSolutions.Y_eci(timeIdxNav) = p_eci(:,2)';
        navSolutions.Z_eci(timeIdxNav) = p_eci(:,3)';

        navSolutions.Vx_eci(timeIdxNav) = v_eci(:,1)';
        navSolutions.Vy_eci(timeIdxNav) = v_eci(:,2)';
        navSolutions.Vz_eci(timeIdxNav) = v_eci(:,3)';
    end
end

%% obsSolutions Parsing
% RINEX mapping [UPDATED Payload command and Telemetry Interface document
% 9.0
% 
% • GPS_L1CA = 0 -> G1C
% • GPS_L5I  = 1 -> G5I
% • GAL_E1B  = 2 -> E1B
% • GAL_E5A  = 3 -> E5I

sigId_LUT = [0 "L1CA"; ...
             1 "L5"; ...
             2 "E1BC"; ...
             3 "E5A"; ...
             4 "E5B"];

sigIds = unique([RAW.signalId]);

%--- Parse all channels
for sig_idx = 1:length(sigIds)
    %--- Isolate data from one channel
    data = [RAW.signalId];
    idx  = (data == sigIds(sig_idx));      
    out  = RAW(1,idx);                  

    switch sigIds(sig_idx)
        case 0
            [tmpObsSolutions.GPS.G1C] = parseObs_ASI(out,sigId_LUT(1,2),time);
            fprintf('Processing GPS L1 C/A observables\n')
        case 1
            [tmpObsSolutions.GPS.G5I] = parseObs_ASI(out,sigId_LUT(2,2),time);
            fprintf('Processing GPS L5 (In-Phase) observables\n')
        case 2
            [tmpObsSolutions.GAL.E1B] = parseObs_ASI(out,sigId_LUT(3,2),time);
            fprintf('Processing Galileo E1B OS data observables\n')
        case 3
            [tmpObsSolutions.GAL.E5I] = parseObs_ASI(out,sigId_LUT(4,2),time);
            fprintf('Processing Galileo E5a (In-phase) observables\n')
        case 4
            [tmpObsSolutions.GAL.E7I] = parseObs_ASI(out,sigId_LUT(5,2),time);
            fprintf('Processing Galileo E5b (In-phase) observables\n')
        otherwise
            
    end
end

%--- Initialize
obsSolutions = [];
%--- Perform append (required for the LuNART)
appendStructs = 'append';  
if strcmp(appendStructs,'append')
    if isfield(tmpObsSolutions, 'GPS')
        %--- GPS data
        fns = fieldnames(tmpObsSolutions.GPS);
        obsSolutions = tmpObsSolutions.GPS.(fns{1});
        for chSigIdx = 1:length(fieldnames(tmpObsSolutions.GPS)) - 1
            obsSolutions = [obsSolutions, tmpObsSolutions.GPS.(fns{chSigIdx+1})];
        end
    end
    if isfield(tmpObsSolutions, 'GAL')
        %--- GALILEO data
        fns = fieldnames(tmpObsSolutions.GAL);
        obsSolutions = [obsSolutions,tmpObsSolutions.GAL.(fns{1})];
        for chSigIdx = 1:length(fieldnames(tmpObsSolutions.GAL)) - 1
            obsSolutions = [obsSolutions, tmpObsSolutions.GAL.(fns{chSigIdx+1})];
        end
    end
else
    obsSolutions = tmpObsSolutions;
end

%% acqSolutions parsing 
%--- Extraction follows the same approach of raw observables
sigIds = unique([ACQ.signalId]);

for sig_idx = 1:length(sigIds)

    data = [ACQ.signalId];
    idx  = (data == sigIds(sig_idx));
    out_acq = ACQ(1,idx);

    switch sigIds(sig_idx)
        case 0
            [tmpAcqSolutions.GPS.G1C] = parseAcq_ASI(out_acq,sigId_LUT(1,2));
        case 1
            [tmpAcqSolutions.GPS.G5I] = parseAcq_ASI(out_acq,sigId_LUT(2,2));
        case 2
            [tmpAcqSolutions.GAL.E1B] = parseAcq_ASI(out_acq,sigId_LUT(3,2));
        case 3
            [tmpAcqSolutions.GAL.E5I] = parseAcq_ASI(out_acq,sigId_LUT(4,2));
        case 4
            [tmpAcqSolutions.GAL.E7I] = parseAcq_ASI(out_acq,sigId_LUT(5,2));
        %case 5
        %    [tmpAcqSolutions.GAL.E5I]=parseAcq_ASI(out_acq,NAV,sigId_LUT(6,2),time);
        %case 6
        %    [tmpAcqSolutions.GAL.E7I]=parseAcq_ASI(out_acq,NAV,sigId_LUT(7,2),time);
        otherwise
    end
end

if strcmp(appendStructs,'append')
    %--- GPS data
    if isfield(tmpAcqSolutions,'GPS')
        fns = fieldnames(tmpAcqSolutions.GPS);
        acqSolutions = tmpAcqSolutions.GPS.(fns{1});
        for chSigIdx = 1:length(fieldnames(tmpAcqSolutions.GPS))-1
            acqSolutions = [acqSolutions, tmpAcqSolutions.GPS.(fns{chSigIdx+1})];
        end
    end
    %--- GALILEO data
    if isfield(tmpAcqSolutions,'GAL')
        fns = fieldnames(tmpAcqSolutions.GAL);
        acqSolutions = [acqSolutions,tmpAcqSolutions.GAL.(fns{1})];
        for chSigIdx = 1:length(fieldnames(tmpAcqSolutions.GAL))-1
            acqSolutions = [acqSolutions, tmpAcqSolutions.GAL.(fns{chSigIdx+1})];
        end
    end
else
    acqSolutions = tmpAcqSolutions;
end

%% Command Window
fprintf("[DONE]\n");