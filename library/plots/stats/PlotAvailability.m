function [msg01, msg02, msg03] = PlotAvailability(directory, file1, file2, limit, epochDate, settings, varargin)
% This function calculates and plot visibility metrics
%
% Written by Simone Zocca

%--- Load obs
path1 = fullfile(directory,file1);
m1 = load(path1);

%--- Load nav
if ~isempty(file2) && ~isempty(directory)
    path2 = fullfile(directory,file2);
    m2 = load(path2);

    figureName = 110;
    %--- Need to distinguish for legend names
    aux = "TLM";
    legendName = "Telemetry RAW";
else
    figureName = 902;
    aux = strings();
    legendName = "GEONS Predicted";
end

%% Calcuate signal availability for mission data
G1mission = zeros(1,length(m1.obsSolutions(1).cn0));
G5mission = zeros(1,length(m1.obsSolutions(1).cn0));
E1mission = zeros(1,length(m1.obsSolutions(1).cn0));
E5mission = zeros(1,length(m1.obsSolutions(1).cn0));

for j = 1:length(m1.obsSolutions)
    channel = char(m1.obsSolutions(j).channel);
    switch channel(1:2)
        case 'G1'
            G1mission = G1mission + double(m1.obsSolutions(j).cn0 > settings.mission.G1th);
        case 'G5'
            G5mission = G5mission + double(m1.obsSolutions(j).cn0 > settings.mission.G5th);
        case 'E1'
            E1mission = E1mission + double(m1.obsSolutions(j).cn0 > settings.mission.E1th);
        case 'E5'
            E5mission = E5mission + double(m1.obsSolutions(j).cn0 > settings.mission.E5th);
    end
end

[GPSmission, GALmission] = countUniqueSvs(m1.obsSolutions, settings.mission);

GNSSmission = GPSmission + GALmission;

%% Calculate signl availability for expected data
if ~isempty(varargin)

    file3 = varargin{1};
    directory3 = varargin{2};

    path3 = fullfile(directory3,file3);
    m3 = load(path3);

    G1reference = zeros(1,length(m3.obsSolutions(1).cn0));
    G5reference = zeros(1,length(m3.obsSolutions(1).cn0));
    E1reference = zeros(1,length(m3.obsSolutions(1).cn0));
    E5reference = zeros(1,length(m3.obsSolutions(1).cn0));

    for j = 1:length(m3.obsSolutions)
        channel = char(m3.obsSolutions(j).channel);
        switch channel(1:2)
            case 'G1'
                G1reference = G1reference + double(m3.obsSolutions(j).cn0 > settings.reference.G1th);
            case 'G5'
                G5reference = G5reference + double(m3.obsSolutions(j).cn0 > settings.reference.G5th);
            case 'E1'
                E1reference = E1reference + double(m3.obsSolutions(j).cn0 > settings.reference.E1th);
            case 'E5'
                E5reference = E5reference + double(m3.obsSolutions(j).cn0 > settings.reference.E5th);
        end
    end
    
    [GPSreference, GALreference] = countUniqueSvs(m3.obsSolutions, settings.reference);
  
    GNSSreference = GPSreference + GALreference;
else
    m3 = [];
end

%--- Time axis
timeIdx = floor(limit(1)):floor(limit(2));
time = datetime(cell2mat([epochDate(timeIdx,1) epochDate(timeIdx,2)]));

%--- Find start and end indexes
idx = findTimeLines(epochDate, settings);

%% Generate signal plot
h = figure(figureName);
set(h,'Name','SignalVisibility');
clf;

opacity = 0.3;

plot(time, G1mission(timeIdx),'Color',[0 0.4470 0.7410 1],'DisplayName',strcat(aux," G1C"),'LineWidth',1.2);
hold on;
plot(time, G5mission(timeIdx),'Color',[0.4660 0.6740 0.1880 1],'DisplayName',strcat(aux," G5I"),'LineWidth',1.2);
plot(time, E1mission(timeIdx),'Color',[0.8500 0.3250 0.0980 1],'DisplayName',strcat(aux," E1B"),'LineWidth',1.2);
plot(time, E5mission(timeIdx),'Color',[0.4940 0.1840 0.5560 1],'DisplayName',strcat(aux," E5I"),'LineWidth',1.2);

if ~isempty(m3)
    plot(time, G1reference(timeIdx),'-.','Color',[0 0.4470 0.7410 opacity],'DisplayName',"REF G1C",'LineWidth',1.2);
    plot(time, G5reference(timeIdx),'-.','Color',[0.8500 0.3250 0.0980 opacity],'DisplayName',"REF G5I",'LineWidth',1.2);
    plot(time, E1reference(timeIdx),'-.','Color',[0.4660 0.6740 0.1880 opacity],'DisplayName',"REF E1B",'LineWidth',1.2);
    plot(time, E5reference(timeIdx),'-.','Color',[0.4940 0.1840 0.5560 opacity],'DisplayName',"REF E5I",'LineWidth',1.2);
end

%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

hold off;
%--- Specs of the plot
title(strcat(legendName," - Channel Visibility"));
ylabel('Radiometric Visibility');
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
hLeg = legend('Location','Best');
hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(4)/2 Pix_SS(3)/4 Pix_SS(4)/2];

%--- Message
msg01 = strcat(legendName, " - Radiometric signal visibility plot generated");

%% Generate constellation plot
h = figure(figureName+1);
set(h,'Name','ConstellationVisibility');
clf;

plot(time, GPSmission(timeIdx),'Color',[0 0.4470 0.7410],'DisplayName',strcat(aux," GPS"),'LineWidth',1.2);
hold on;
plot(time, GALmission(timeIdx),'Color',[0.8500 0.3250 0.0980],'DisplayName',strcat(aux," GAL"),'LineWidth',1.2);
plot(time, GNSSmission(timeIdx),'Color',[0 0 0],'DisplayName',strcat(aux," GNSS"),'LineWidth',1.1);

if ~isempty(m3)
    plot(time, GPSreference(timeIdx),':','Color',[0 0.4470 0.7410 opacity],'DisplayName',"REF GPS",'LineWidth',1.2);
    plot(time, GALreference(timeIdx),':','Color',[0.8500 0.3250 0.0980 opacity],'DisplayName',"REF GAL",'LineWidth',1.2);
    plot(time, GNSSreference(timeIdx),':','Color',[0.6 0.6 0.6],'DisplayName',"REF GNSS",'LineWidth',1.1);
end

%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

hold off;
%--- Specs of the plot
title(strcat(legendName, " - GNSS Visibility (Unique SVs)"));
ylabel('Radiometric Visibility');
xlabel('Time');
axis tight;
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
subtitle(strcat("Start Date: ",epochDate{1,1},"  |  End Date: ",epochDate{ticksVector(6),1}))

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Legend
hLeg = legend('Location','Best');
hLeg.ItemHitFcn = @action1;

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [Pix_SS(3)/2 Pix_SS(2) Pix_SS(3)/4 Pix_SS(4)/2];
hold off;

%--- Message
msg02 = strcat(legendName, " - Radiometric GNSS visibility plot generated");

%% Generate outage (availability percentage) plot
GPSavail = double(GPSmission(timeIdx) >= 4);
GPSperc = sum(GPSavail)*100/numel(timeIdx);
GPSavail(GPSavail == 0) = NaN;
GPSoutage = double(GPSmission(timeIdx) >= 4);
GPSoutage(GPSoutage == 1) = NaN;

GALavail = double(GALmission(timeIdx) >= 4);
GALperc = sum(GALavail)*100/numel(timeIdx);
GALavail(GALavail == 0) = NaN;
GALoutage = double(GALmission(timeIdx) >= 4);
GALoutage(GALavail == 1) = NaN;

GNSSavail1 = double(GNSSmission(timeIdx) >= 5);
GNSSperc1 = sum(GNSSavail1)*100/numel(timeIdx);
GNSSavail1(GNSSavail1 == 0) = NaN;
GNSSoutage1 = double(GNSSmission(timeIdx) >= 5);
GNSSoutage1(GNSSoutage1 == 1) = NaN;

GNSSavail2 = double(GNSSmission(timeIdx) >= 4);
GNSSperc2 = sum(GNSSavail2)*100/numel(timeIdx);
GNSSavail2(GNSSavail2 == 0) = NaN;
GNSSoutage2 = double(GNSSmission(timeIdx) >= 4);
GNSSoutage2(GNSSoutage2 == 1) = NaN;

if figureName == 110 && ~isempty(m2.navSolutions)
    NAVavail = double(~isnan(m2.navSolutions.X_eci));
    NAVperc = sum(NAVavail)*100/numel(timeIdx);
    NAVavail(NAVavail == 0) = NaN;
    NAVoutage = double(~isnan(m2.navSolutions.X_eci));
    NAVoutage(NAVoutage == 1) = NaN;
else
    NAVavail = nan(size(timeIdx));
    NAVperc = 0;
    NAVoutage = zeros(size(timeIdx));
end

h = figure(figureName+2);
set(h,'Name','TelemetryAvailability');
clf;

%--- GPS
subplot(5,1,1);
plot(time, GPSavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GPSoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

text(time(25), 0., sprintf('Availability: %.2f %%', GPSperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

%--- Specs
ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GPS availability');

%--- Galileo
subplot(5,1,2);
plot(time, GALavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GALoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unvailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GALperc), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GAL Availability');

%--- GNSS without GGTO
subplot(5,1,3);
plot(time, GNSSavail1,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GNSSoutage1,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GNSSperc1), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GNSS Availability (estimate GGTO)');

%--- GNSS with GGTO
subplot(5,1,4);
plot(time, GNSSavail2,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
hold on;
plot(time, GNSSoutage2,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

text(time(25), 0, sprintf('Availability: %.2f %%', GNSSperc2), 'Horiz','left', 'Vert','bottom');
%--- If we found start & end indexes, plot them
plotTimeLines(time, idx);

ylabel('Availability');
xlim('tight');
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('GNSS Availability (demodulate GGTO)');

%--- NAV solutions
subplot(5,1,5);
if figureName == 110
    plot(time, NAVavail,'marker','*','markersize',1,'color','blue','DisplayName',"Available");
    hold on;
    plot(time, NAVoutage,'marker','*','markersize',1,'color','red','DisplayName',"Unavailable");

    text(time(25), 0, sprintf('Availability: %.2f %%', NAVperc), 'Horiz','left', 'Vert','bottom');
else
    plot(time, nan(numel(timeIdx),1));
    text(time(floor(end/5)),0.5,'Prediction Mode: No PVT available');
end
ylabel('Availability');
xlabel('Time');
xlim([time(1) time(end)]);
ylim([0 1]);
grid on;
xticks(time(ticksVector));
xticklabels(string(timeofday(time(ticksVector))));
title('NAV solution Availability');

%--- Add listener for datatips
datacursormode on;
dcm = datacursormode(h);
set(dcm,'UpdateFcn',@customDataTip);

%--- Plot location
Pix_SS = get(0,'screensize');
h.OuterPosition = [3*Pix_SS(3)/4 Pix_SS(2) Pix_SS(3)/4 Pix_SS(4)];
hold off;

%--- Message
msg03 = strcat(legendName, " - Availability plot generated");