function plotAcquisition(acqResults, settings)
%Functions plots bar plot of acquisition results (acquisition metrics). No
%bars are shown for the satellites not included in the acquisition list (in
%structure SETTINGS).
%
%plotAcquisition(acqResults)
%
%   Inputs:
%       acqResults    - Acquisition results from function acquisition.


%--- General settings
DopStep = acqResults.dopplerStep;  
Nd      = acqResults.Nd;
Rc      = acqResults.Rc;
fs = settings.samplingFreq;
FS = 13;

%--- Find the Doppler frequency range
if bitand( Nd, 1 ) == 1    % It is an odd number
    dopplerFreqRange = (-((Nd - 1) / 2):((Nd - 1) / 2) ) * DopStep + settings.forceSSshift;
else
    dopplerFreqRange = (-(Nd/2):( (Nd-2) / 2 ) ) * DopStep + settings.forceSSshift;
end

%--- Find the code delay range
if settings.plotAcquisition
    Nc_plot = acqResults.Nc_plot; % if Tcoh extended, Nc for the plot is truncated
    codeDelayRange = (0:(Nc_plot - 1)) / fs * Rc; % Code delays
    if strcmp(settings.signal,'E1B') || strcmp(settings.signal,'E1C')
        codeDelayRange = (0:(Nc_plot - 1)) / fs * Rc/2; % usual workaround to manage wrong Rc for GalE1 in the code
    end
end

%% Plot acquisition summary ===============================================
%--- Only plot if we have more than one channel
% if numel(settings.acqSatelliteList) > 1
%     figure(200);
%     hAxes = newplot();
%     bar(hAxes, acqResults.peakMetric);
% 
%     title (hAxes, ['Acquisition results - ' settings.signal]);
%     xlabel(hAxes, 'PRN number');
%     ylabel(hAxes, 'Est. C/N0 (dBHz)');
% 
%     oldAxis = axis(hAxes);
%     axis  (hAxes, [0, max(settings.acqSatelliteList)+2, min(acqResults.peakMetric(~isinf(acqResults.peakMetric)))-5, oldAxis(4)]);
%     set   (hAxes, 'XMinorTick', 'on');
%     set   (hAxes, 'YGrid', 'on');
%     set   (hAxes, 'FontSize', FS);
% 
%     %--- Mark acquired signals
%     acquiredSignals = acqResults.peakMetric .* isfinite(acqResults.carrFreq);
% 
%     hold(hAxes, 'on');
%     bar (hAxes, acquiredSignals, 'FaceColor', [0 0.8 0]);
%     hold(hAxes, 'off');
% 
%     legend(hAxes, 'Not acquired signals', 'Acquired signals');
% 
%     if settings.saveAcquisition
%         saveas(gcf, [settings.workingPath '/AcquisitionSummary_' strrep(settings.signal, ' ', '') '.png']);
%     end
% end

%% Plot single search space results =======================================
if settings.plotAcquisition
    for PRN = settings.acqSatelliteList
        %--- Read acquisition results
        sspace = squeeze(acqResults.sspace(PRN,:,:));
        dopInd = acqResults.dopInd(PRN);
        codInd = acqResults.codInd(PRN);
        Th     = acqResults.Th(PRN);
        maxVal = acqResults.maxVal(PRN);
        
        %--- 3D search space
        if settings.plotAcquisition == 2
            figure(200+PRN*3-2)
            surf(codeDelayRange, dopplerFreqRange, sspace/maxVal);
            shading interp
            axis tight
            set( gca, 'FontSize', FS)
            xlabel('Code delay (chips)')
            ylabel('Doppler frequency (Hz)')
            hold on
            surf( [ codeDelayRange(1) codeDelayRange(end) ], [ (1 - ceil(Nd/2))*DopStep+settings.forceSSshift (Nd - ceil(Nd/2))*DopStep+ settings.forceSSshift ], ...
                Th * ones(2,2) / maxVal, 'FaceAlpha', 0.2, 'FaceColor', 'r' );
            hold off
            title(['Acquisition search space - ' settings.signal ', PRN ' num2str(PRN)])

            saveAcquisitionPlot(settings, 'SS', PRN);
        end
        
        %--- Code search space
        figure(200+PRN*3-1)
        plot( codeDelayRange, sspace(dopInd, :)/maxVal )
        axis tight
        grid on
        set( gca, 'FontSize', FS)
        xlabel('Code delay (chips)')
        ylabel('Normalized Correlation')
        hold on
        plot( [ codeDelayRange(1) codeDelayRange(end) ], Th * ones(1,2) / maxVal, 'r', 'LineWidth', 2 );
        hold off
        title(['Code delay domain - ' settings.signal ', PRN ' num2str(PRN)])
        
        saveAcquisitionPlot(settings, 'D', PRN);
        
        %--- Frequency search space
        figure(200+PRN*3)
        plot(dopplerFreqRange, sspace(:, codInd) / maxVal)
        axis tight
        grid on
        set( gca, 'FontSize', FS)
        xlabel('Doppler frequency (Hz)')
        ylabel('Normalized Correlation')
        hold on
        plot( [ dopplerFreqRange(1) dopplerFreqRange(end) ], Th * ones(1,2) / maxVal, 'r', 'LineWidth', 2 );
        hold off
        title(['Doppler frequency domain - ' settings.signal ', PRN ' num2str(PRN)])
        
        saveAcquisitionPlot(settings, 'C', PRN);
    end
end


function saveAcquisitionPlot(settings, strTypeOfPlot, PRN)

if settings.saveAcquisition
    filename = ['Acquisition_' strTypeOfPlot '_PRN' num2str(PRN) '_' strrep(settings.signal, ' ', '') '.png'];
    saveas(gcf, fullfile(settings.workingPath, filename));
end
