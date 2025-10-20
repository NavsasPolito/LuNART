function msg = PlotCNoDiff(directory, file1, file2, colors, limit, epochDate, varargin)
% This function generates a plot of the difference in C/N0 between
% telemetry and reference data. Only common SVs are considered
%
% Written by Simone Zocca

if ~isempty(varargin)
    figureName = varargin{1};
else
    figureName = 1;
end

msg = "";
%--- Load files
path1 = fullfile(directory,file1);
m1 = load(path1);

path2 = fullfile(directory,file2);
m2 = load(path2);

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Generate the plot
h = figure(figureName);
set(h,'Name','C/N0Difference');
clf;
title('C/N0 Difference (RAW minus REF)');

%--- Initialize difference
cn0diff = nan(length(m1.obsSolutions),1);

for i = 1:length(m1.obsSolutions)
    %--- Search color index
    k = intersect(find([colors.PRN] == m1.obsSolutions(i).PRN), find(ismember([colors.channel], m1.obsSolutions(i).channel)));
    %--- Search in reference
    j = intersect(find([m2.obsSolutions.PRN] == m1.obsSolutions(i).PRN), find(ismember([m2.obsSolutions.channel], m1.obsSolutions(i).channel)));

    %--- If both present, plot difference
    if ~isempty(j)
        hold on;
        svID = append(m1.obsSolutions(i).SV," ",m1.obsSolutions(i).channel);
        %--- Cut reference to match telemetry
        plot(time, m1.obsSolutions(i).cn0(timeIdx) - m2.obsSolutions(j).cn0(timeIdx),'Color',colors(k).Color,'DisplayName',svID,'LineWidth',1.1);

        cn0diff(i) = mean(m1.obsSolutions(i).cn0(timeIdx) - m2.obsSolutions(j).cn0(timeIdx));
    else
        msg = append(msg,sprintf("PRN %d of channel %s not found in reference\n",m1.obsSolutions(i).PRN, m1.obsSolutions(i).channel));
    end
end

hold off;
%--- Specs of the plot
ylabel('[dB-Hz]');
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

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/2 Pix_SS(4)/3];

%--- Message
msg = append(msg,"C/N0 difference plot generated");