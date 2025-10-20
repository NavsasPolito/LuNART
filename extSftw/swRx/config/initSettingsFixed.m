function settings = initSettingsFixed(settings)

% DO NOT MODIFY THIS FILE, unless you know what you are doing.

%% Timing configuration ===================================================
%--- The round function is added to avoid the numercal problem rasied by
%multiplication (having a small portion of decimal e-9). skipNumberOfSamples must be an Interger.
settings.skipNumberOfSamples  = round(settings.skipSeconds*settings.samplingFreq);

%% Pre-correlation data probe settings ====================================
settings.probeObsWindow = 50e-3; % data observation window used in frequency analysis, histograms, statistics in probeData
settings.offsetRemoval = 1; % Remove offset from non-zero mean data (offset estimated over the first 50ms)

%% Acquisition settings ===================================================

%--- Number of non coherent acquisitions accumulations
settings.K                        = 5;
%--- Acqisiton Coherent integration time (code duration is used if "minimum")
% settings.acqTcoh                  = "minimum";
settings.acqTcoh                  = 0.001;
%--- System False Alarm Probability
settings.acqPfaSys                = 1e-4;
%--- Doppler bin size
settings.dopplerStep              = 200;  % Hz
%--- Frequency search space
settings.forceSSshift             = 0; % (Hz) for L1, shift the search space around this freq + IF
settings.searchSpace              = 10e3; % Hz
%--- Get satellites list 
settings.acqSatelliteList         = getSatelliteList(settings);

%--- Doppler search space extended to Code Doppler shift
settings.codeDopplerSearch        = 1;%0 to disable

%% FLL settings ===========================================================
settings.skipFLL                  = 0;
settings.FLLtime                  = 1e3;     % (miliseconds), maximum time allowed for the FLL stage
settings.FLLlockDetector          = 0;       % Decide wheteher to run FLL for a fixed time (0), equal to settings.FLLtimr, or to use automatic lock detector (1)
settings.fllNoiseBandwidth        = 10;      % (Hz)
settings.lockSenitivity           = 0.01;    % sensitivity for frequency output control
settings.FLLcarrOrder             = 2;       % FLL carrier order

%% Common Tracking loops settings =========================================
%--- Code tracking loop parameters
settings.dllNoiseBandwidth        = 10;       % (Hz)
%--- early-minus-late offset
settings.dllCorrelatorSpacing     = 0.8;     % (chips)
%--- early-minus-late offset Galileo
settings.dllCorrelatorSpacingGAL  = 1;     % (chips)
%--- Carrier tracking loop parameters
settings.pllNoiseBandwidth        = 10;       % (Hz)
%--- GUI update interval
settings.trackingGuiUpdate        = 100;     % (ms)
%--- Carrier tracking loop order
settings.carrOrder = 2;
%--- Carrier tracking loop coefficients method implementation
%--- 1: Akos/Pini (only 2nd order), 2: Kaplan/Romero (1st, 2nd and 3rd
%--- order), 3: Falletti (only 2nd order)
settings.trackingLoopMethod = 2;
%--- Carrier tracking loop C/N0 estimation technique
%--- 1: Beaulieu, 2: Emanuela, 3: Blue Book Method, 4: 'SNV', 5: 'Moments'
settings.CNoMethod = 1;
settings.CN0window = floor(1/getTc(settings)); % Default: 1/Tc, 1000 integratoin time periods - for E1c it was 2.5/Tc

%% Constants ==============================================================
settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 70.0;         % [ms] Initial sign. travel time
settings.f0_L1              = 1.57542e9;
settings.lambdaL1           = settings.c/settings.f0_L1;
settings.lambdaE1           = settings.lambdaL1;
settings.WEDOT              = 7.292115147e-5;        % WGS84 Value of earth's rotation rate

settings.semiMajorAxis      = 6378137.0;            % WGS84 semimajor axis
f  = 1/298.257223563;                               % WGS84 inverse flattening
settings.firstEccentricity  = 2*f - f^2;            % e^2, first eccentricity

%% Hopfield Model constants (troposphere corrections)
settings.G               = 9.80665;          % Gravity constant                                  		
settings.Re              = 6378.1363;        % !!! Sarebbe 6378.137 !!!								
settings.HI              = 350;
settings.K1              = 77.604;
settings.K2              = 382000;
settings.Rd              = 287.054;
settings.Gm              = 9.784;
settings.P0_45           = 1015.75;		     % Mean pressure @45 degree					
settings.T0_45           = 283.15;           % Mean temperature @45 degree						
settings.e0_45           = 11.66;            % Mean e0 @45 degree 							
settings.Beta0_45        = 5.58e-3;          % Mean Beta @45 degree 						
settings.Lambda0_45      = 2.57;             % Mean Lambda @45 degree