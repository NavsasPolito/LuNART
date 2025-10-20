function msg = PlotRawPseudoranges(directory, file, colors, limit, epochDate, varargin)
% This function generates the raw pseudoranges plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureName = varargin{1};
    for i = 1:length(colors)
        colors(i).plot = 1;
    end
else
    figureName = 2;
end

%--- Load the files
path = fullfile(directory,file);
m = load(path);

%--- Time Axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate the plot
h = figure(figureName);
set(h,'Name','RawPseudoranges');
clf;

for i = 1:length(m.obsSolutions)
    %--- Find the right color
    k = intersect(find([colors.PRN] == m.obsSolutions(i).PRN), find(ismember([colors.channel], m.obsSolutions(i).channel)));

    if colors(k).plot
        hold on;
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).channel); 
        if figureName == 121
            plot(time, m.obsSolutions(i).rawP(timeIdx),'-.','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.2);
        elseif figureName == 905
            plot(time, m.obsSolutions(i).rawP(timeIdx),'-','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
        else
            plot(time, m.obsSolutions(i).rawP(timeIdx),'Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.2);
        end
    end
end

hold off;
%--- Specs of the plot
ylabel('[m]');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}))

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

hLeg = legend('Location','eastoutside','NumColumns',3,'FontSize',7);
hLeg.ItemHitFcn = @action1;

Pix_SS = get(0,'screensize');
if figureName == 120
    titleName = "Telemetry RAW - Raw Pseudoranges";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
elseif figureName == 121
    titleName = "GEONS Reference - Ranges";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
elseif figureName == 905
    titleName = "GEONS Predicted - Ranges";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    h.WindowState = 'minimized';
else
    titleName = "";
    h.OuterPosition = [3*Pix_SS(3)/4 2*Pix_SS(4)/3 Pix_SS(3)/4 Pix_SS(4)/3];
end

title(titleName);
msg = strcat(titleName," - raw pseudoranges plot generated");