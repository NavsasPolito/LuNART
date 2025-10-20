function settings = initSettings()

%% Initialization =========================================================
printStartup;
fprintf('\n  +------------------  Recevier initialization  ------------------+\n');
settings.exit = 0;

%% Operational mode
settings.receiverMode = 1;     

% 1) input: raw I/Q samples .bin file
% 2) input: trackResults from previous .bin processing
% 3) input: raw measurements file

printReceiverMode(settings.receiverMode);

%% Actions to perform =====================================================
settings.doProbeData        = 1; % spectrum and histogram (2 for enhanced probing)
settings.doAcquisition      = 1; % acquisition stage
settings.doTracking         = 0; % tracking stage
settings.doNavigation       = 0; % PVT stage
settings.doScintillation    = 0; % Scintillation analysis

%% Type of front-end used =================================================
% settings.frontend = 'SIGEv2_raw';
% settings.frontend = 'SIGEv2';
% settings.frontend = 'SIGEv3_raw';
% settings.frontend = 'SIGEv3';
% settings.frontend = 'Fraunhofer';
% settings.frontend = 'Stereo';
% settings.frontend = 'USRP 5M_16bit';
% settings.frontend = 'USRP 5M_32bit';
% settings.frontend = 'USRP 25M_16bit';
% settings.frontend = 'USRP 20M_8bit';
% settings.frontend = 'USRP 5M_8bit';
% settings.frontend = '4tuNe';
% settings.frontend = '4tuNe_raw';
% settings.frontend = 'HackRF ONE';
% settings.frontend = 'Amungo1';
% settings.frontend = 'Amungo2';
% settings.frontend = 'UserDefined';
% settings.frontend = 'Qascom-LuGRE_old';
settings.frontend = 'Qascom-LuGRE';



%% Type of GNSS signal to process =========================================
settings.signal     = 'G1C';
% settings.signal     = 'E1B';
% settings.signal     = 'E1C';
settings = defineFrequencyPlan(settings);

%% Timing configuration ===================================================
%--- Arman: Activating this paramter:
% 1 : the size of of file will be checked in openRawData and the sToProcess 
% is set to the available Second in the file.
% 0 : Consider following value for sToProcess.
settings.checkSecToProcess = 1;

%--- Number of seconds to be processed
settings.sToProcess         = 20;  % (s)

%--- Number of seconds to be skipped at the beginning of the file
settings.skipSeconds        = 0;%2e-3;  % (s)

%% Raw samples ============================================================
%--- path name of the raw file
% settings.rawFileL1         = '000074_IQS_L1.bin'; %60RE
settings.rawFileL1         = '000080_IQS_L1.bin'; %17RE
% settings.rawFileL1         = 'IQS_packet_17_21_26_264.bin';
% settings.rawFileL1         = 'LYR0N_171117_155633_USRP_5M_16bit_L1.bin';

%% Raw measurements ============================================================
%--- path name of the raw file
settings.rawMeasFile       = 'externalFiles\swift-gnss-20210224-101400.sbp.obs';
  
%% Acquisition settings ===================================================
%--- List of satellites to look for. 
%--- 'all' acquires all the satellites available for settings.signal

settings.satelliteList = 'all';
% settings.satelliteList = [10]; %17RE-16,21,26 %60RE-10,16 %int8-18,24

%% Tracking settings ======================================================
%--- Number of channels for the tracking stage
settings.numberOfChannels   = 4;

%--- Tracking coherent integration time (code duration is used if "minimum")
settings.Tc                 = "minimum";

%% Parallel/serial channel tracking:
%--- 0 -> Multi core (if available)  |    1 -> Signle Core
settings.forceSerialTracking = 1;

%% Plot settings ==========================================================
%--- Enable/disable plotting of the results for each channel
%--- 0 -> Off   |    1 -> 2-D plots   |    2 -> 3-D plots (plotAcquisition only)
settings.plotAcquisition    = 0;
settings.plotFLL            = 1;
settings.plotTracking       = 1;
settings.plotTrackingLive   = 0;

%% Plot save settings =====================================================
%--- Enable/disable saving the plots
%--- 0 -> Off   |    1 -> On
settings.saveProbeData      = 0;
settings.saveAcquisition    = 0;
settings.saveFLL            = 0;
settings.saveTracking       = 0;

%% Output settings ========================================================
%--- Folder where the outputs will be saved, it can be either relative or absolute
settings.workingPath = 'results';
settings = setWorkingPath(settings);

%% Results save settings ==================================================
%--- path to save the data in .mat format
settings.saveAcqNameL1      = fullfile(settings.workingPath, 'acqResults.mat');
settings.saveTrackingNameL1 = fullfile(settings.workingPath, 'trackResults.mat');

%% Fixed settings =========================================================
settings = initSettingsFixed(settings); 

%% Check settings =========================================================
settings = checkSettings(settings);

%% Finally save the settings ==============================================
save(fullfile(settings.workingPath, 'settings.mat'), 'settings');