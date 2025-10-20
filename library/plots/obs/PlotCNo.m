function msg = PlotCNo(directory, file, colors, limit, epochDate, varargin)
% This function generates the C/N0 plot
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};
    for i = 1:length(colors)
        colors(i).plot = 1;
    end

    if figureNum == 900
        settings = varargin{2};
    else
        settings = [];
    end
else
    figureNum = 1;
end

%--- Load files
path = fullfile(directory,file);
m = load(path);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Find start and end indexes
idx = findTimeLines(epochDate, settings);

%--- Generate the plot
h = figure(figureNum);
set(h,'Name','C/N0');
clf;

for i = 1:length(m.obsSolutions)
    %--- Find the right color
    k = intersect(find([colors.PRN] == m.obsSolutions(i).PRN), find(ismember([colors.channel], m.obsSolutions(i).channel)));

    if colors(k).plot 
        hold on;
        svID = append(m.obsSolutions(i).SV," ",m.obsSolutions(i).channel);
        if figureNum == 101
            plot(time, m.obsSolutions(i).cn0(timeIdx),'-.','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
        elseif figureNum == 900
            plot(time, m.obsSolutions(i).cn0(timeIdx),'-','Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
        else
            plot(time, m.obsSolutions(i).cn0(timeIdx),'Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
        end
    end
end

%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

hold off;
%--- Specs of the plot
ylabel('C/N0 [dB-Hz]');
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
if figureNum == 100  
    titleName = "Telemetry RAW";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3]; 
elseif figureNum == 101
    titleName = "GEONS Reference";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    h.Renderer = 'painters';
elseif figureNum == 900
    titleName = "GEONS Predicted";
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];
else
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/4 Pix_SS(4)/3];
end

%--- Message
title(strcat(titleName,' - C/N0'));
msg = strcat(titleName," - C/N0 plot generated");