function msg = PlotDopplerShift(directory, file, colors, limit, epochDate, varargin)
% This function generates the Doppler shift plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureName = varargin{1};
    for i = 1:length(colors)
        colors(i).plot = 1;
    end
else
    figureName = 5;
end

%--- Load the files
path = fullfile(directory, file);
m1 = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%---Generate the plot
h = figure(figureName);
set(h,'Name','DopplerShift');
clf;

for i = 1:length(m1.obsSolutions)
    %--- Find the right color
    k = intersect(find([colors.PRN] == m1.obsSolutions(i).PRN), find(ismember([colors.channel], m1.obsSolutions(i).channel)));

    if colors(k).plot
        hold on;
        svID = append(m1.obsSolutions(i).SV," ",m1.obsSolutions(i).channel);
        if figureName == 141
            plot(time, m1.obsSolutions(i).Doppler(timeIdx),'-.','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.2);
        elseif figureName == 906
            plot(time, m1.obsSolutions(i).Doppler(timeIdx),'-','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
        else
            plot(time, m1.obsSolutions(i).Doppler(timeIdx),'Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.2);
        end
    end
end

hold off;
%--- Specs of the plot
ylabel('[Hz]');
xlabel('Time');
axis tight;
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
hLeg = legend('Location','eastoutside','NumColumns',3,'FontSize',7);
hLeg.ItemHitFcn = @action1;

%--- Title and plot location
Pix_SS = get(0,'screensize');
if figureName == 140
    titleName = "Telemetry RAW";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
elseif figureName == 141
    titleName = "GEONS Reference";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
elseif figureName == 906
    titleName = "GEONS Predicted";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    h.WindowState = 'minimized';
else
    titleName = "";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/3 Pix_SS(3)/4 Pix_SS(4)/3];
end

%--- Title and message
title(strcat(titleName,' - Doppler Shifts'));
msg = strcat(titleName," - Doppler shifts plot generated");