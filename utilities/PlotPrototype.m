function [msg] = PlotPrototype(file, directory, colors, limit, epochDate, varargin)
% INPUTS:
% file: Name of the file (obsSolutions or navSolutions).
% directory: path of the file.
% colors: Structures with PRNS and colors (used to plot the same signal
%         with the same color across all functions of the tool)
% limit: Indexes of start and end.
% epochDate: Array of string of datetime of each epoch (used in the labels
%            and substitles).
% varargin: If the function is called by an expariment, it containes info
%           necessary to save results and generate reports correctly.
%
% OUTPUTS:
% msg: Returns a message to print on the tool to notify success or failure
%
% -------------------------------------------------------------------------
if ~isempty(varargin)
    figureNum = varargin{1};
    for i=1:length(colors)
        colors(i).plot = 1;
    end
else
    % This number will be changed to be compatible with other plots in the
    % tool, use any value you want
    figureNum = 999;
end

% Load the files
path = fullfile(directory,file);
m = load(path);                     % The structure m contains the data you need

%% Do youy tasks here


%% Generate the plot
time = floor(limit(1)):floor(limit(2));
h = figure(figureNum);
set(h,'Name','C/N0');               % Change the name of your plot
clf;

% Example of C/N0 plot
plot(time,m.obsSolutions(i).cn0(time),'Color',colors(i).Color,'DisplayName',append(m.obsSolutions(i).SV," ",m.obsSolutions(i).channel),'LineWidth',1.1);

% Specs of the plot (Change labels)
ylabel('[dBHz]');
xlabel('Time');
xlim([floor(limit(1)) floor(limit(2))]);
grid on;
ticksVector = getTicks(limit);
xticks(ticksVector);
xticklabels({epochDate{ticksVector(1),2},epochDate{ticksVector(2),2},epochDate{ticksVector(3),2},epochDate{ticksVector(4),2},epochDate{ticksVector(5),2},epochDate{ticksVector(6),2}});
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}))
hLeg = legend('Location','eastoutside');
hLeg.ItemHitFcn = @action1;

% Handle the position of the plot on the screen (don't change)
Pix_SS = get(0,'screensize');
if figureNum == 999 
    titleName = "Telemetry RAW";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3]; 
else
    titleName = "";
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/4 Pix_SS(4)/3];
end

%% Output strings (change to the name of your plot)
title(strcat(titleName,' C/N0'));
msg = strcat(titleName," C/N0 plot generated");