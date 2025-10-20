function [msg01] = PlotDOP(directory, file, limit, epochDate, varargin)
% This function generates the DOP plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureName = varargin{1};  

    if figureName == 907
        settings = varargin{2};
    else
        try
            file2 = varargin{2};
            path2 = fullfile(directory, file2);
            m2 = load(path2);
        catch
            warning("Failed to upload reference trajectory");
        end
    end
else
    figureName = 14;
end

%--- Load files
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

% --- Generate plot
h = figure(figureName);
set(h,'Name','DOPs');
clf;

if figureName == 230
    % 1) GDOP 2) PDOP 3) HDOP 4) VDOP 5) TDOP
    subplot(2,1,1)
    plot(time, m.navSolutions.DOP(1,timeIdx),'k','LineWidth',1.5,'DisplayName','TLM GDOP');
    hold on;
    plot(time, m.navSolutions.DOP(2,timeIdx),'b','LineWidth',1.5,'DisplayName','TLM PDOP');
    plot(time, m.navSolutions.DOP(5,timeIdx),'r','LineWidth',1.5,'DisplayName','TLM TDOP');

    if exist('m2','var') && ~isempty(m2)
        plot(time, m2.navSolutions.DOP(1,timeIdx),'k:','LineWidth',1.5,'DisplayName','REF GDOP');
        plot(time, m2.navSolutions.DOP(2,timeIdx),'b:','LineWidth',1.5,'DisplayName','REF PDOP');
        plot(time, m2.navSolutions.DOP(5,timeIdx),'r:','LineWidth',1.5,'DisplayName','REF TDOP');
    end

    %--- Specs 
    title('Telemetry NAV - Dilution of Precision metrics');
    ylabel('DOPs');
    xlabel('Time');
    ylim('tight');
    xlim([time(1) time(end)]);
    grid on;
    ticksVector = getTicks(limit);
    xticks(time(ticksVector));
    xticklabels(string(timeofday(time(ticksVector))));
    subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

    %--- Legend
    hLeg = legend('Location','best');
    hLeg.ItemHitFcn = @action1;


    subplot(2,1,2)
    plot(time, m.navSolutions.nSat(timeIdx),'k','LineWidth',1.5,'DisplayName',"#Sat");

    %--- Specs
    title('Telemetry NAV - Number of tracked signals (channels)');
    ylabel('# of channels');
    xlabel('Time');
    ylim('tight');
    xlim([time(1) time(end)]);
    grid on;
    xticks(time(ticksVector));
    xticklabels(string(timeofday(time(ticksVector))));

    %--- Add listener for datatips
    datacursormode on;
    dcm = datacursormode(h);
    set(dcm,'UpdateFcn',@customDataTip);

    %--- Plot location
    Pix_SS = get(0,'screensize');
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/4 Pix_SS(3)/2 3*Pix_SS(4)/4];

    titleName = "Telemetry RAW";

elseif figureName == 907
    %--- Find start and end indexes
    idx = findTimeLines(epochDate, settings);

    % 1) GDOP 2) PDOP 3) HDOP 4) VDOP 5) TDOP
    plot(time, m.navSolutions.DOP(1,timeIdx),'k','LineWidth',1.5,'DisplayName','GDOP');
    hold on;
    plot(time, m.navSolutions.DOP(2,timeIdx),'b','LineWidth',1.5,'DisplayName','PDOP');
    plot(time, m.navSolutions.DOP(5,timeIdx),'r','LineWidth',1.5,'DisplayName','TDOP');

    %--- If we found start & end indexes, plot them
    plotTimeLines(time, idx);

    %--- Specs
    title('GEONS Predicted - Dilution of Precision metrics');
    ylabel('DOPs');
    xlabel('Time');
    ylim('tight');
    xlim([time(1) time(end)]);
    grid on;
    ticksVector = getTicks(limit);
    xticks(time(ticksVector));
    xticklabels(string(timeofday(time(ticksVector))));
    subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}));

    %--- Add listener for datatips
    datacursormode on;
    dcm = datacursormode(h);
    set(dcm,'UpdateFcn',@customDataTip);

    %--- Legend
    hLeg = legend('Location','best');
    hLeg.ItemHitFcn = @action1;

    %--- Plot location
    Pix_SS = get(0,'screensize');
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/2 Pix_SS(4)/3];
    h.WindowState = 'minimized';

    titleName = "GEONS Predicted";
end

msg01 = strcat(titleName," - DOPs plot generated");