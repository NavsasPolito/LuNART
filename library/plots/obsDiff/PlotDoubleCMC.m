function [L1outliers, L5outliers, msg] = PlotDoubleCMC(directory, file, colors, limit, epochDate, varargin)
% This function generates the single frequency CMC plot 
%
% Written by Yihan Guo
% Adapted to LuNART-Q by Simone Zocca, Alex Minetto

if ~isempty(varargin)
    figureNum = varargin{1};
    for i = 1:length(colors)
        colors(i).plot = 1;
    end
    settings = varargin{2};
else
    figureNum = 999;
end

%--- Load files
path = fullfile(directory, file);
m = load(path);

%--- Initialize
L1outliers = [];
L5outliers = [];

%--- Define parameters
freqL1 = 1.57542E9;
freqL5 = 1.17645E9;
coeff1 = 2 * freqL5^2 / (freqL1^2 - freqL5^2);
coeff5 = 2 * freqL1^2 / (freqL5^2 - freqL1^2);

%--- Extend Galileo PRNs
for i = 1:size(m.obsSolutions,2)
    prnExtend(i) = m.obsSolutions(i).PRN;
    if strfind(m.obsSolutions(i).SV,'E')
        prnExtend(i) = prnExtend(i) + 32;
    end
end

%--- Find SVs receiving both L1+L5 signals
[~, w] = unique(prnExtend , 'stable');
prnIndex = setdiff(1:numel(prnExtend), w);
cmcPrn = prnExtend(prnIndex);

%--- Initialize CMC
cmcL1   = NaN(size(prnIndex,2),size(m.obsSolutions(1).rawP,2));
cmcL5   = NaN(size(prnIndex,2),size(m.obsSolutions(1).rawP,2));
cmcL1_m = NaN(size(prnIndex,2),size(m.obsSolutions(1).rawP,2));
cmcL5_m = NaN(size(prnIndex,2),size(m.obsSolutions(1).rawP,2));

%--- Compute CMC
for i = 1:size(prnIndex,2)
    prnIndexL5 = prnIndex(i);

    for j = 1:size(prnExtend,2)
        if prnExtend(j) == cmcPrn(i)
            prnIndexL1 = j;

            for k = 1:size(m.obsSolutions(1).rawP,2)
                P1 = m.obsSolutions(prnIndexL1).rawP(k);
                P5 = m.obsSolutions(prnIndexL5).rawP(k);
                L1 = m.obsSolutions(prnIndexL1).CarrierPhase(k);
                L5 = m.obsSolutions(prnIndexL5).CarrierPhase(k);

                cmcL1(i,k) = P1 - L1 - coeff1 * (L1 - L5);
                cmcL5(i,k) = P5 - L5 - coeff5 * (L5 - L1);
            end
            break;
        end
    end
    if settings.mode == 1
        %--- Remove mean using first derivative
        cmcL1_m(i,1:end-3) = centralFiniteDiff(cmcL1(i,:), 1, 3);
        cmcL5_m(i,1:end-3) = centralFiniteDiff(cmcL5(i,:), 1, 3);
    end
end

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%% Generate plot
h = figure(figureNum);
set(h,'Name','DoubleCMC');

%--- L1/E1
subplot(2, 1, 1)
for i = 1:size(prnIndex,2)
    svID = m.obsSolutions(prnIndex(i)).SV;
    numColor = m.obsSolutions(prnIndex(i)).PRN;
    if contains(svID,"G")
        numColor = numColor * 2 - 1;
    else
        numColor = ((numColor + 32) * 2) - 1;
    end
    switch settings.mode
        case 1
            plot(time, cmcL1_m(i,timeIdx),'-','Color',colors(numColor).Color,'MarkerSize',2,'DisplayName',svID,'LineWidth',1.1);
            hold on;
            if figureNum == 161
                table = hlSigmaOutliers(time, cmcL1_m(i,timeIdx), m.obsSolutions(prnIndex(i)).SV, settings.window, settings.threshold, colors(numColor).Color);
                L1outliers = vertcat(L1outliers, table);
            end
            ylabel('Detrended 2F CMC [m]');
        case 2
            plot(time, cmcL1(i,timeIdx),'-','Color',colors(numColor).Color,'MarkerSize',2,'DisplayName',svID,'LineWidth',1.1);
            hold on;
            if figureNum == 161
                table = hlSigmaOutliers(time, cmcL1(i,timeIdx),  m.obsSolutions(prnIndex(i)).SV, settings.window, settings.threshold, colors(numColor).Color);
                L1outliers = vertcat(L1outliers, table);
            end
            ylabel('Raw 2F CMC [m]');
    end
end

hold off;
%--- Specs of the plot
title('L1/E1');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- L5/E5
subplot(2, 1, 2)
for i = 1:size(prnIndex,2)
    svID = m.obsSolutions(prnIndex(i)).SV;
    numColor = m.obsSolutions(prnIndex(i)).PRN;
    if contains(svID,"G")
        numColor = numColor * 2;
    else
        numColor = (numColor + 32) * 2;
    end
    switch settings.mode
        case 1
            plot(time, cmcL5_m(i,timeIdx),'-','Color',colors(numColor).Color,'MarkerSize',2,'DisplayName',svID,'LineWidth',1.1);
            hold on;
            if figureNum == 161
                table = hlSigmaOutliers(time, cmcL5_m(i,timeIdx), m.obsSolutions(prnIndex(i)).SV, settings.window, settings.threshold, colors(numColor).Color);
                L5outliers = vertcat(L5outliers, table);
            end
            ylabel('Detrended 2F CMC [m]');
        case 2
            plot(time, cmcL5(i,timeIdx),'-','Color',colors(numColor).Color,'MarkerSize',2,'DisplayName',svID,'LineWidth',1.1);
            hold on;
            if figureNum == 161
                table = hlSigmaOutliers(time, cmcL5(i,timeIdx), m.obsSolutions(prnIndex(i)).SV, settings.window, settings.threshold, colors(numColor).Color);
                L5outliers = vertcat(L5outliers, table);
            end
            ylabel('Raw 2F CMC [m]');
    end
end

hold off;
%--- Specs of the plot
title('L5/E5');
xlabel('Time');
axis tight;
grid on;
ticksVector = getTicks(limit);
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','eastoutside','NumColumns',2,'FontSize',8);
hLeg.ItemHitFcn = @action1;

%--- Title and plot location
Pix_SS = get(0,'screensize');
if figureNum == 160
    switch settings.mode
        case 1
            sgt = sgtitle({['{\bf' 'Telemetry RAW - Detrended 2F CMC' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg = "Detrended 2F CMC plot generated";
        case 2
            sgt = sgtitle({['{\bf' 'Telemetry RAW - Raw 2F CMC' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg = "Raw 2F CMC plot generated";
    end
    sgt.FontSize = 10;
    h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/2 Pix_SS(4)/2];
elseif figureNum == 161
    switch settings.mode
        case 1
            sgt = sgtitle({['{\bf' 'Telemetry RAW - Detrended 2F CMC with outliers detection' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg = "Detrended 2F CMC plot with outliers generated";
        case 2
            sgt = sgtitle({['{\bf' 'Telemetry RAW - Raw 2F CMC with outliers detection' '}'], strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1})});
            msg = "Raw 2F CMC plot with outliers generated";
    end
    sgt.FontSize = 10;
    h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/2 Pix_SS(4)/2];
end

%--- Handle tables (generate as figures)
if ~isempty(L1outliers)
    %--- Get the number of rows in the existing table
    numRows = height(L1outliers);
    %--- Create the new column with the same number of rows as the table
    newColumn = repmat({'L1/E1'}, numRows, 1);
    %--- Add the new column to the table
    L1outliers.channel = newColumn;
    %--- Rearrange the column order
    L1outliers = L1outliers(:, [width(L1outliers), 1:width(L1outliers)-1]);
end

if ~isempty(L5outliers)
    %--- Get the number of rows in the existing table
    numRows = height(L5outliers);
    %--- Create the new column with the same number of rows as the table
    newColumn = repmat({'L5/E5'}, numRows, 1);
    %--- Add the new column to the table
    L5outliers.channel = newColumn;
    %--- Rearrange the column order
    L5outliers = L5outliers(:, [width(L5outliers), 1:width(L5outliers)-1]);
end

%--- Generate table with outliers
if ~isempty(L5outliers) || ~isempty(L1outliers)
    outliersT = vertcat(L1outliers,L5outliers);

    h = figure(162);
    uitable('Data',outliersT{:,:},'ColumnName',outliersT.Properties.VariableNames,'RowName',outliersT.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    h.OuterPosition = [3*Pix_SS(3)/4 0 Pix_SS(3)/4 Pix_SS(4)/2];
    h.WindowState = 'minimized';
elseif figureNum == 161
    h = figure(162);
    f = uitable('Data',{'No outliers detected'});
    f.ColumnWidth = {100};
    h.OuterPosition = [3*Pix_SS(3)/4 0 Pix_SS(3)/4 Pix_SS(4)/2];
    h.WindowState = 'minimized';
end