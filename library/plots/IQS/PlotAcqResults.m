function [msg] = PlotAcqResults(G1Csettings, acqG1CRes, varargin);

if ~isempty(varargin)
    figureName = varargin{1};
else
    figureName = 999;
end

%--- Only plot if we have more than one channel
if numel(G1Csettings.acqSatelliteList) >= 1

    h = figure(figureName);

    hAxes = newplot();
    bar(hAxes, acqG1CRes.peakMetric,'FaceColor', [0.65,0.65,0.65]);

    %--- Specs
    title (hAxes, ['Acquisition results - ' G1Csettings.signal]);
    xlabel(hAxes, 'PRN number');
    ylabel(hAxes, 'Est. C/N0 (dBHz)');

    oldAxis = axis(hAxes);
    axis  (hAxes, [0, max(G1Csettings.acqSatelliteList)+2, min(acqG1CRes.peakMetric(~isinf(acqG1CRes.peakMetric)))-5, oldAxis(4)]);
    set   (hAxes, 'XMinorTick', 'on');
    set   (hAxes, 'YGrid', 'on');
    %set   (hAxes, 'FontSize', FS);

    %--- Mark acquired signals
    acquiredSignals = acqG1CRes.peakMetric .* isfinite(acqG1CRes.carrFreq);

    %acqG1CRes.snr .* isfinite(acqG1CRes.carrFreq)

    hold(hAxes, 'on');
    bar (hAxes, acquiredSignals, 'FaceColor', [0.31 0.39 0.67]);
    hold(hAxes, 'off');

    %--- Legend
    legend(hAxes, 'Not acquired signals', 'Acquired signals');

    %--- Plot location
    Pix_SS = get(0,'screensize');
    if figureName == 311
        h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    elseif figureName == 313
        h.OuterPosition = [Pix_SS(3)/2 1*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    end
    
    %--- Message
    msg = "C/N0 histogram plot generated";
end