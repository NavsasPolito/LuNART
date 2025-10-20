function acqResults = acquisitionL1E1(fid, settings,app)
% Function performs cold start acquisition on the collected "data". It
% searches for GPS/Galileo signals of all satellites, which are listed in field
% "acqSatelliteList" in the settings structure. Function saves code phase
% and frequency of the detected signals in the "acqResults" structure.
%
% acqResults = acquisition(signalPointer, settings)
%
%   Inputs:
%       settings      - Receiver settings. Provides information about
%                       sampling and intermediate frequencies and other
%                       parameters including the list of the satellites to
%                       be acquired.
%   Outputs:
%       acqResults    - Function saves code phases and frequencies of the
%                       detected signals in the "acqResults" structure. The
%                       field "carrFreq" is set to 0 if the signal is not
%                       detected for the given PRN number.


%% Initialization =========================================================

%--- Doppler bin size in Hz
DopStep = settings.dopplerStep;  
Nd = settings.searchSpace/DopStep;

%--- Sampling frequency
fs = settings.samplingFreq;

%--- Acquisition integration time
[Tc,Tc_min] = getTc(settings,"acquisition");

%% Open the input file ====================================================
%--- Move the starting point of processing. Can be used to start the signal processing at any point in the data record.

%--- Depending on quantization and sampling mode, compute the size of a sample in Byte
skp_factor = computeSkipFactor(settings);

%--- Check if it starts from I or Q sample
flagFirstQ = isTheFirstSamplesQ(settings);

%--- Skip samples to align the beginning of the code
fseek_status = fseek(fid, settings.skipNumberOfSamples * skp_factor + flagFirstQ, 'bof');
if fseek_status == -1
    disp('Unable to move to the specified position in the Raw file. Please check that the specified position is valid.');
    return
end


%--- Read the samples
samplesToRead = floor(Tc * settings.K * fs +Tc*fs); % +Tc*fs accounts for the zero padding

%--- Just for this type of we need multiply by 2, in order to have the
%proper amount of samples. 
if strcmp(settings.frontend,'4tuNe_raw')
    samplesToRead = samplesToRead *2;
end

rawData = readData(fid, settings, samplesToRead);

%--- Initialize acqResults to speed up the code ---------------------------
%--- Carrier frequencies of detected signals
acqResults.carrFreq   = -inf(1, max(settings.acqSatelliteList));
%--- C/A code phases of detected signals
acqResults.codePhase  = -inf(1, max(settings.acqSatelliteList));
%--- Correlation peak ratios of the detected signals
acqResults.peakMetric = -inf(1, max(settings.acqSatelliteList));

fprintf('%s (',getSignalName(settings));

d = uiprogressdlg(app.AnalysisToolUIFigure,'Title',strcat(getSignalName(settings)," signals acquisition"),...
    'Message','Acquiring signals','Cancelable','off');

%% Perform search for all listed PRN numbers ...
for PRN = settings.acqSatelliteList

    d.Value = PRN/numel(settings.acqSatelliteList);
    percents = sprintf('Progress: %.0f%%',d.Value.*100);
    d.Message = sprintf('%s',percents);
  
    %--- Generate the local code and resample it 
    [Code, Rc] = generateLocalCode(PRN, settings);
   
    %--- Resample the code at the correct sampling frequency
    k = 0:fs*Tc-1;
    locC = Code(mod(floor(k*Rc/fs), length(Code)) + 1);

    %--- Search space were the results will be stored
    sspace = 0;
    Nc = length(locC);
    Nc_plot = round(Nc/(Tc/Tc_min)); % Tc/Tc_min and round are meaningful only in the case of larger Tc

    %--- Use zero padding to compute linear correlation and avoid problems with bit transitions
    locC = [locC zeros(1, length(locC))];
    
    %% Main acquisition loop - evaluation of the search space =============
    if strcmp(settings.signal, 'E1C')
        load('Gal_E1_Codes.dat', '-mat');
        secondary = sc_E1_C;
    else
        secondary = 1;
    end

    %--- Perform K non coherent sums within DftParallelCodePhaseAcquisitionDopplerNC
    if settings.codeDopplerSearch == 1
        Tsspace = DftParallelCodePhaseAcquisitionDopplerNC(rawData.', Code, ...
            2*Nc, Nd, DopStep, fs, settings.IF + settings.forceSSshift, settings, Tc, settings.K, Nc);
        sspace = squeeze(sum(Tsspace(:,:, 1:Nc_plot),1));
        y = rawData((1:2*Nc));
    else
    %--- Perform K non coherent sums in loop
        for iK = 1:settings.K
            %--- use 2 periods of Tcoh code at each Ncoh sum
            y = rawData((iK - 1)*Nc + (1:2*Nc));
            %--- Compute the search space for 2 coherent integration epochs
            Tsspace = DftParallelCodePhaseAcquisition(y.', locC, 2*Nc, Nd, DopStep, fs, settings.IF + settings.forceSSshift);
            sspace = sspace + Tsspace(:, 1:Nc_plot);
        end
    end

    
    %% Decision logic =====================================================
    %--- Cell Probability of false alarm
    Pfa_cell = 1 - ( 1 - settings.acqPfaSys ).^( 1 / numel( sspace ) );
    %--- Noise floor estimation and threshold evaluation
    Th = InverseChiSquarePfa( settings.K, Pfa_cell );
    sigma2 = NoiseVarianceEstimator( y(1:Nc), fs, Rc, settings.IF ); % Undo zeropadding extension of incoming signal
    %--- Unnormalized variance
    Th = sigma2 * Th; % Arbitrarily scale this for unusual SNR situations
    
    %% Save results =======================================================
    %--- Find the Doppler frequency range
    if bitand( Nd, 1 ) == 1    % It is an odd number 
        Freq = (-((Nd - 1) / 2):((Nd - 1) / 2) ) * DopStep;
    else
        Freq = (-(Nd/2):( (Nd-2) / 2 ) ) * DopStep;
    end

    %--- Find the Doppler frequency
    [maxVal, dopInd] = max(max(sspace.'));

    %--- Find the code delay (in samples)
    [maxVal, codInd] = max(max(sspace));
    
    %--- Find the code delay (in chips)
    codeDelay = settings.codeLength - (codInd - 1) / fs * Rc;

    % C/N0 estimate
    acqResults.peakMetric(PRN) = 10*log10(maxVal/(Tc*settings.K*sigma2*2));

    % old metric
    %acqResults.peakMetric(PRN) = maxVal/Th;

    %--- Indicate PRN number of the detected signal -------------------
    if maxVal > Th
        fprintf('%02d ', PRN);
        acqResults.carrFreq(PRN)   = Freq(dopInd) + settings.forceSSshift;
        acqResults.codePhase(PRN)  = codInd;
    else
        %--- No signal with this PRN --------------------------------------
        fprintf('. ');
    end

    %--- Save some variables useful for the plot
    if settings.plotAcquisition
        acqResults.sspace(PRN,:,:) = sspace;
        acqResults.Th(PRN)         = Th;
        acqResults.dopInd(PRN)     = dopInd;
        acqResults.codInd(PRN)     = codInd;
        acqResults.maxVal(PRN)     = maxVal;
        acqResults.Nc_plot         = Nc_plot;
    end
end % for PRN = satelliteList

%--- Save some variables useful for the plot
acqResults.Nc = Nc;
acqResults.dopplerStep = DopStep;
acqResults.Nd = Nd;
acqResults.Rc = Rc;

try
    close(d)
catch
end

%% Acquisition is over ====================================================
fprintf(')\n');