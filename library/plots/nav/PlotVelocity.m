function [msg01] = PlotVelocity(directory, file, limit, epochDate, varargin)
% This function generates the position plot
%
% Written by Simone Zocca

msg01 = "";

if ~isempty(varargin)
    figureName = varargin{1};
    refFrame = varargin{2};

    try
        file2 = varargin{3};
        path2 = fullfile(directory, file2);
        m2 = load(path2);
    catch
        warning("Failed to upload reference trajectory");
    end   
else
    figureName = 12;
end

%--- Load NAV solution
path = fullfile(directory, file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate plot
h = figure(figureName);
set(h,'Name','Velocity');
clf;

subplot(3, 1, 1)
if figureName == 211 
    if refFrame == 1
        plot(time, m.podSolutions.Vx_eci(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    else
        plot(time, m.podSolutions.Vx(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    end
elseif figureName == 201 || figureName == 301
    if refFrame == 1
        plot(time, m.navSolutions.Vx_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV'); 
    else
        plot(time, m.navSolutions.Vx(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
    end
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.Vx_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.Vx(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('Vx');
ylabel('[m/s]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(3, 1, 2)
if figureName == 211 
    if refFrame == 1
        plot(time, m.podSolutions.Vy_eci(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    else
        plot(time, m.podSolutions.Vy(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    end
elseif figureName == 201 || figureName == 301
    if refFrame == 1
        plot(time, m.navSolutions.Vy_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV'); 
    else
        plot(time, m.navSolutions.Vy(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
    end
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.Vy_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.Vy(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('Vy');
ylabel('[m/s]');
ylim('tight');
xlim([time(1) time(end)]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
xtickangle(0);


subplot(3, 1, 3)
if figureName == 211 
    if refFrame == 1
        plot(time, m.podSolutions.Vz_eci(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    else
        plot(time, m.podSolutions.Vz(timeIdx),'LineWidth',1.1,'DisplayName','POD');
    end
elseif figureName == 201 || figureName == 301
    if refFrame == 1
        plot(time, m.navSolutions.Vz_eci(timeIdx),'LineWidth',1.1,'DisplayName','NAV'); 
    else
        plot(time, m.navSolutions.Vz(timeIdx),'LineWidth',1.1,'DisplayName','NAV');
    end
end

if exist('m2','var') && ~isempty(m2)
    hold on;
    if refFrame == 1
        plot(time, m2.navSolutions.Vz_eci(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    else
        plot(time, m2.navSolutions.Vz(timeIdx),'k--','LineWidth',1.1,'DisplayName','REF');
    end
end

title('Vz');
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
hLeg = legend('Location','Best');
%hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
if figureName == 201 || figureName == 211 || figureName == 301
    h.OuterPosition = [3*Pix_SS(3)/4 Pix_SS(4)/2 Pix_SS(3)/4 Pix_SS(4)/2];
else
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];  
end

%--- Title and message
if ~isempty(epochDate)
    if figureName == 201
        if refFrame == 1
            sgt = sgtitle({['{\bf' 'Telemetry NAV - Velocity (ECI)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "Telemetry NAV - Velocity plot (ECI) generated";
        else
            sgt = sgtitle({['{\bf' 'Telemetry NAV - Velocity (ECEF)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "Telemetry NAV - Velocity plot (ECEF) generated";
        end
    elseif figureName == 211
        if refFrame == 1
            sgt = sgtitle({['{\bf' 'Telemetry POD - Velocity (ECI)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "Telemetry POD - Velocity plot (ECI) generated";
        else
            sgt = sgtitle({['{\bf' 'Telemetry POD - Velocity (ECEF)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "Telemetry POD - Velocity plot (ECEF) generated";
        end
    elseif figureName == 301
        if refFrame == 1
            sgt = sgtitle({['{\bf' 'LuNaRT-Q NAV - Velocity (ECI)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "LuNaRT-Q NAV - Velocity plot (ECI) generated";
        else
            sgt = sgtitle({['{\bf' 'LuNaRT-Q NAV - Velocity (ECEF)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg01 = "LuNaRT-Q NAV - Velocity plot (ECEF) generated";
        end
    else
        sgt = sgtitle({['{\bf' 'NAV solutions - Velocity (ECEF)' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
        msg01 = "NAV solutions - Velocity plot (ECEF) generated";
    end
    sgt.FontSize = 10;
end
