function settings = probeData(fid, settings)
%Function plots raw data information: time domain plot, a frequency domain
%plot and a histogram.
%
%   probeData(settings)
%
%   Inputs:
%       settings        - receiver settings. Type of data file, sampling
%                       frequency and the default filename are specified
%                       here.

%--- The frequency spectrum comes from the function test_raw_samples.m

%--- Configure colors

col.timeSeriesColor_real=[0, 0.4470, 0.7410];
col.timeSeriesColor_imag=[0.25, 0.25, 0.25];
col.histogramFaceColor_real=[0, 0.4470, 0.7410];
col.histogramFaceColor_imag=[0.25, 0.25, 0.25];
col.fftColor=[1 1 1];%[0.75, 0.75, 0];

%% Generate plot of raw data ============================================
if settings.receiverMode==1 && settings.doProbeData
    fprintf('\n  +---------------------  Raw data probing -----------------------+\n');
    
    try
        %--- Move the starting point of processing
        skp_factor = computeSkipFactor(settings);
        
        %--- check if it starts from I or Q sample
        flagFirstQ = isTheFirstSamplesQ(settings);
        
        fseek_status = fseek(fid,settings.skipNumberOfSamples * skp_factor + flagFirstQ ,'bof');
        if fseek_status == -1
            disp('Unable to move to the specified position in the Raw file. Please check that the specified position is valid.');
            return
        end
        
        %--- Read samples
        obsWindow = settings.probeObsWindow;
        seconds = obsWindow * settings.samplingFreq;
        data = readData(fid,settings,seconds);

        %--- Data offset estimation and removal (removal usually done in readData)
        if settings.offsetRemoval
            avgValR=mean(real(data));
            avgValI=mean(imag(data));
            settings.estOffset = avgValR + avgValI*1i;
            data = data - settings.estOffset;
        end

        %--- Compute statistics on samples
        minValR = min(real(data));
        minValI = min(imag(data));
        avgValR = mean(real(data));
        stdValR = std(real(data));

        maxValR = max(real(data));
        maxValI = max(imag(data));
        avgValI = mean(imag(data));
        stdValI = std(imag(data));    
        
        %--- Spectrum of received signal samples
        Nfft = 4096;                   % number of FFT points
        Nover = 128;                    % samples of overlap from section to section
        Wind = boxcar(Nfft);          % Welch window
        switch settings.samplingMode
            case 'IQ'
                Side = 'twosided';        % Side flag
            case 'real'
                Side = 'onesided';        % Side flag
            otherwise
                disp 'Wrong sampling mode'
        end
        
        % data = data - mean(data); % Mean value removal (in order to remove DC component)
        
        [S, Frequency] = pwelch(data, Wind, Nover, Nfft, settings.samplingFreq, Side);   % Welch spectrum
        
        SignalSpectrum=S;
        % SignalSpectrum = S.*FreqSamp;                  % spectrum normalization wrt the sampling frequency
        % SignalSpectrum = SignalSpectrum./max(SignalSpectrum); %  spectrum normalization wrt its maximum
        
        if strcmp(Side,'twosided')                      % spectrum and frequency shift (if the twosided option is chosen)
            SignalSpectrum = fftshift(SignalSpectrum);
            Frequency = Frequency - settings.samplingFreq/2;
        end
        
        %--- Initialization ---------------------------------------------------
        f = figure(100);
        f.Position = [0 0 1100 900];
        clf(100);
        %set(100, 'Name', strcat('Probe raw GNSS data: ',
        %settings.rawFileL1)); [BUG]
        
        timeScale = 1/settings.samplingFreq : 1/settings.samplingFreq : seconds/settings.samplingFreq;
        
        %--- Time domain plot -------------------------------------------------
        subplot(3, 4, [1 2]);
        plot(1000 * timeScale(1:ceil(0.01*settings.samplingFreq)), ...
        real(data(1:ceil(0.01*settings.samplingFreq))), ...
        'Color',col.timeSeriesColor_real);
        if settings.offsetRemoval
            label={sprintf("Est. Mean (%.0f ms): %.2f (removed)",obsWindow*1e3,real(settings.estOffset))};
            yline(0,'w',label)
        else
            label={sprintf("Est. Mean (%.0f ms): %.2f",obsWindow*1e3,avgValR)};
            yline(avgValR,'w',label);
            yline(0,'w')
        end
        axis tight;
        grid on;
        title ('Time domain plot (real part)');
        xlabel('Time (ms)');
        ylabel('Amplitude');

        subplot(3, 4, [5 6]);
        plot(1000 * timeScale(1:ceil(0.01*settings.samplingFreq)), ...
        imag(data(1:ceil(0.01*settings.samplingFreq))), ...
        'Color',col.timeSeriesColor_imag);
        if settings.offsetRemoval
            label={sprintf("Est. Mean (%.0f ms): %.2f (removed)",obsWindow*1e3,imag(settings.estOffset))};
            yline(0,'w',label)
        else
            label={sprintf("Est. Mean (%.0f ms): %.2f",obsWindow*1e3,avgValI)};
            yline(avgValI,'w',label);
            yline(0,'w')
        end       
        axis tight;
        grid on;
        title ('Time domain plot (imaginary part)');
        xlabel('Time (ms)');
        ylabel('Amplitude');
        
        %--- Histogram --------------------------------------------------------
        subplot(3, 4, 3);
        %histogram(real(data), 100,'FaceColor',col.histogramFaceColor_real)
        hI = histfit(real(data),100);
        hI(1).FaceColor = col.histogramFaceColor_real;
        legend({'Hist (real)','Normal fit'});
        
        % --- Compute Statistics for real part
        pdR = fitdist(real(data),'normal');
        kR = kurtosis(real(data))-3;
        SR = skewness(real(data));

        dmax = max(abs(data)) + 1;
        axis tight;
        adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;
        title ('Histogram (real part)');
        xlabel('Bin'); ylabel('Samples per bin');
        
        subplot(3, 4, 7);
        %histogram(imag(data), 100,'FaceColor',col.histogramFaceColor_imag)
        hI=histfit(imag(data),100);
        hI(1).FaceColor=col.histogramFaceColor_imag;
        legend({'Hist (real)','Normal fit'});
        
        % --- Compute Statistics for imaginary part
        pdI = fitdist(imag(data),'normal');
        kI = kurtosis(imag(data))-3;
        SI = skewness(imag(data));
        
        dmax = max(abs(data)) + 1;
        axis tight;
        adata = axis;
        axis([-dmax dmax adata(3) adata(4)]);
        grid on;
        title ('Histogram (imaginary part)');
        xlabel('Bin'); ylabel('Samples per bin');


        % 
        subplot(3, 4, 4);
        probplot('normal',real(data))
        xlabel('Bin'); 
        grid on;
        title ('Probability Plot (real)');
        

        subplot(3, 4, 8);
        p1=probplot('normal',imag(data));
        p1(1).Color=col.histogramFaceColor_imag;

        xlabel('Bin'); 
        grid on;
        title ('Probability Plot (imaginary)');
        

        %--- Frequency domain plot --------------------------------------------
        subplot(3,4,[9 10]);
        
        plot(Frequency./1e6, 10*log10(SignalSpectrum),'Linewidth', 1, 'Color',col.fftColor),
        set(gca,'Color','k')
        set(gca,'GridColor','w')
        xlabel('Frequency (MHz)');
        ylabel('Power Spectral Density (dB-Hz)');
        axis tight;
        grid on;
        title ('Frequency domain plot');

        subplot(3,4,[11 12])
        pspectrum(data,settings.samplingFreq,'persistence', ...
        'FrequencyLimits',[-settings.samplingFreq/2 settings.samplingFreq/2],'TimeResolution',0.001)
        colormap("gray")

        % print statistics

        fprintf("> Real part\n")
        fprintf("Est. mean: %.2f \n",avgValR)
        fprintf("Est. std: %.2f \n",stdValR)
        fprintf("-------------------\n")
        fprintf("Norm Fit mean: %.2f \n",pdR.mu)
        fprintf("Norm Fit std: %.2f \n",pdR.sigma)
        fprintf("-------------------\n")
        fprintf("Skewness: %.2f \n",SR)
        fprintf("Kurtosis: %.2f \n",kR)

        fprintf("\n-----------------\n")

        fprintf("> Imaginary part\n")
        fprintf("Est. mean: %.2f \n",avgValI)
        fprintf("Est. std: %.2f \n",stdValI)
        fprintf("-------------------\n")
        fprintf("Norm Fit mean: %.2f \n",pdI.mu)
        fprintf("Norm Fit std: %.2f \n",pdI.sigma)
        fprintf("-------------------\n")
        fprintf("Skewness: %.2f \n",SI)
        fprintf("Kurtosis: %.2f \n\n",kI)
        
        if settings.saveProbeData
            saveas(100, fullfile(settings.workingPath, '/ProbeData_L1.png'));
        end

        if settings.doProbeData == 2
            warning 'wavelet toolbox is needed for cwt function'
            warning 'wavelet plot is slow'
            warning 'KLT theory for complex signals must be re-checked'

            
            %--- Spectrogram plot -------------------------------------------------
            figure(150)
            subplot(2, 2, 1);
            spectrogram(data,Wind,Nover,Nfft,settings.samplingFreq,"centered");
            view(90,90)
            title 'Spectrogram'
            
            %--- waterfall plot -------------------------------------------------
            subplot(2, 2, 2);
            [s,f,t] = spectrogram(data,Wind,Nover,Nfft,settings.samplingFreq);
            waterplot(s,f,t)
            title 'Waterfall plot of squared spectrogram'

             %--- KLT plot -------------------------------------------------
            figure(150)
            subplot(2,2,3)
            % transform signals into sequence of observations
            N = length(Wind);
            excess = mod(length(data),N);
            % matrix made by multiple obs. of signal blocks of length N
            obs_vectors = reshape(data(1:end-excess),[],N);
            obs_vectors = obs_vectors.';
            [V,D]=eig(cov(obs_vectors));
            klt = V' * obs_vectors';
            surface(abs(klt),'EdgeColor','none')
            colorbar
            axis 'tight'
            title 'Karhunen–Loève transform'
            
%             % KLT plot as image            
%             subplot(2,2,4)
%             imshow(klt)
%             colormap(parula);  
%             colorbar
%             title 'Karhunen–Loève transform'

            %--- wavelet plot -------------------------------------------------
            [cfs,frq,coi] = cwt(data,settings.samplingFreq);

            figure(152)
            subplot(2, 1, 1);
            tms = (0:numel(data)-1)/settings.samplingFreq;
            surface(tms,frq,abs(cfs(:,:,1)))
            hold on
            plot(tms,coi,'w','LineWidth',3)
            axis tight
            shading flat
            colorbar
            xlabel("Time (s)")
            ylabel("Frequency (Hz)")
            set(gca,"yscale","log")
            title 'Magnitude Scalogram (morse wavelet)'
            legend 'Positive Comp. (Counterclk. Rotation)' 'cone of influence'
                       
            subplot(2, 1, 2);
            tms = (0:numel(data)-1)/settings.samplingFreq;
            surface(tms,frq,abs(cfs(:,:,2)))
            hold on
            plot(tms,coi,'w','LineWidth',3)
            axis tight
            shading flat
            colorbar
            xlabel("Time (s)")
            ylabel("Frequency (Hz)")
            set(gca,"yscale","log")
            title 'Magnitude Scalogram (morse wavelet)'
            legend 'Negative Comp. (Clk. Rotation)' 'cone of influence'

            figure(151)
            cwt(data,settings.samplingFreq);

        end
    catch
        %--- There was an error, print it and exit
        errStruct = lasterror;
        disp(errStruct.message);
        disp('Error in function probeData.');
        return;
    end
end
end

function waterplot(s,f,t)
% Waterfall plot of spectrogram
    waterfall(f,t,abs(s)'.^2)
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end