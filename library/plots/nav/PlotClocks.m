function [msg01] = PlotClocks(directory, file, limit, epochDate, varargin)
% This function generates the clock parameters plot
%
% Written by Simone Zocca

msg01 = "";

if ~isempty(varargin)
    figureName = varargin{1}; 
else
    figureName = 999;
end

%--- Load NAV data
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate plot
h = figure(figureName);
set(h,'Name','Clocks');
clf;

subplot(2, 1, 1)
if figureName == 212
    plot(time, m.podSolutions.Clock_GPS(timeIdx),'LineWidth',1.1,'DisplayName','POD');
else % figureName == 202
    plot(time, m.navSolutions.Clock_GPS(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
end

title('Clock Bias');
ylabel('[m]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(2, 1, 2)
if figureName == 212
    plot(time, m.podSolutions.Drift_Clk_GPS(timeIdx),'LineWidth',1.1,'DisplayName','POD');
else % figureName == 202
    plot(time, m.navSolutions.Drift_Clk_GPS(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
end

title('Clock Drift');
ylabel('[m/s]');
xlabel('Time');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
%hLeg = legend('Location','Best');
%hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
if figureName == 202 || figureName == 212 || figureName == 302
    h.OuterPosition = [Pix_SS(3)/2 1 Pix_SS(3)/4 Pix_SS(4)/2];
else
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];  
end

%--- Title and message
if ~isempty(epochDate)
    if figureName == 202
        sgt = sgtitle({['{\bf' 'Telemetry NAV - Clock Bias and Drift' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "Telemetry NAV - Clock plot generated";
    elseif figureName == 212
        sgt = sgtitle({['{\bf' 'Telemetry POD - Clock Bias and Drift' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "Telemetry POD - Clock plot generated";
    elseif figureName == 302
        sgt = sgtitle({['{\bf' 'LuNaRT-Q NAV - Clock Bias and Drift' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "LuNaRT-Q NAV - Clock plot generated";
    end
    sgt.FontSize = 10;
end