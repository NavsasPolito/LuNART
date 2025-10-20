function [msg01] = PlotStd(directory, file, limit, epochDate, varargin)
% This function plots the standard deviations on NAV solutions
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

%--- Time Axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate plot 
h = figure(figureName);
set(h,'Name','Std');
clf;

subplot(3, 1, 1)
plot(time, m.navSolutions.posStd(timeIdx),'Color',[0.8500 0.3250 0.0980],'LineWidth',1.1,'DisplayName','NAV');

title('Position Std');
ylabel('[m]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(3, 1, 2)
plot(time, m.navSolutions.velStd(timeIdx),'Color',[0.8500 0.3250 0.0980],'LineWidth',1.1,'DisplayName','NAV');

title('Velocity Std');
ylabel('[m/s]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(3, 1, 3)
plot(time, m.navSolutions.timeStd(timeIdx),'Color',[0.8500 0.3250 0.0980],'LineWidth',1.1,'DisplayName','NAV');

title('Time Std');
ylabel('[m]');
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
if figureName == 203 || figureName == 303
    h.OuterPosition = [3*Pix_SS(3)/4 1 Pix_SS(3)/4 Pix_SS(4)/2];
else
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];  
end

%--- Title and message
if ~isempty(epochDate)
    if figureName == 203
        sgt = sgtitle({['{\bf' 'Telemetry NAV - Standard Deviations' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "Telemetry NAV - States standard deviations generated";
    elseif figureName == 303
        sgt = sgtitle({['{\bf' 'LuNaRT-Q NAV - Standard Deviations' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "LuNaRT-Q NAV - States standard deviations generated";
    end
    sgt.FontSize = 10;
end
