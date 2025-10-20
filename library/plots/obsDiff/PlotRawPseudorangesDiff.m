function [msg01] = PlotRawPseudorangesDiff(directory, file1, file2, colors, limit, epochDate, varargin)
% This function plots the difference between raw pseudoranges and
% references ranges
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureNum = varargin{1};
else
    figureNum = 1;
end

msg01 = "";
%--- Load the files
path1 = fullfile(directory,file1);
m1 = load(path1);

path2 = fullfile(directory,file2);
m2 = load(path2);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

if figureNum == 133
    %--- Load the files
    path3 = fullfile(varargin{3},varargin{2});
    m3 = load(path3);

    figureName = 'RangeError';

    %--- Subtract clock bias from observed raw pseudoranges (exp. 1.d)
    rawP = vertcat(m1.obsSolutions.rawP);
    clockB = m3.navSolutions.Clock_GPS;

    obsMeasurements = rawP - repmat(clockB,size(rawP,1),1);
else
    figureName = 'RawPseudorangesDifference';

    obsMeasurements = vertcat(m1.obsSolutions.rawP);
end

%--- Generate plot
h = figure(figureNum);
set(h,'Name',figureName);
clf;

if figureNum == 133 && sum(~isnan(clockB)) == 0
    plot(time, nan(numel(timeIdx),1),'DisplayName','noPVT');
    text(time(floor(end/5)),0.5,'No PVT available');
else
    for i = 1:length(m1.obsSolutions)
        %--- Search color index
        k = intersect(find([colors.PRN] == m1.obsSolutions(i).PRN), find(ismember([colors.channel], m1.obsSolutions(i).channel)));
        %--- Search in reference
        j = intersect(find([m2.obsSolutions.PRN] == m1.obsSolutions(i).PRN), find(ismember([m2.obsSolutions.channel], m1.obsSolutions(i).channel)));

        %--- If both present, plot difference
        if ~isempty(j)
            %--- Cut reference to match telemetry
            obsDiff = obsMeasurements(i,(timeIdx)) - m2.obsSolutions(j).rawP(timeIdx);

            svID = append(m1.obsSolutions(i).SV," ",m1.obsSolutions(i).channel);

            plot(time, obsDiff ,'Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);
            hold on;
        else
            msg01 = append(msg01,sprintf("PRN %d of channel %s not found in reference\n",m1.obsSolutions(i).PRN, m1.obsSolutions(i).channel));
        end
    end
end

hold off;
%--- Specs of the plot
ylabel('[m]');
xlabel('Time');
xlim([time(1) time(end)]);
ylim('tight');
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
if  figureNum == 133
    title('Telemetry RAW - Range Differences (RAW corrected minus REF)');
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/2 Pix_SS(4)/2];
    msg01 = append(msg01,"Estimated range error plot generated");
elseif figureNum == 122
    title('Telemetry RAW - Pseudorange Differences (RAW minus REF)');
    h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/2 Pix_SS(4)/3];
    msg01 = append(msg01,"Raw pseudoranges difference plot generated");
end