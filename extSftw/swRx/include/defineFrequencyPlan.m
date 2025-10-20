function settings = defineFrequencyPlan(settings)

% Depending on the front-end selected by the user, choose
% - the sampling frquency
% - the intermediate frequency
% - the quantization format (data type used to store one sample)
% - theampling format, IQ or IF data?


% Do not change here, unless you know what you are doing!

switch settings.frontend
%---- SIGE v2 -------------------------------------------------------------
    case 'SIGEv2_raw'
        settings.IF                 = 38.4e3;      % (Hz)
        settings.samplingFreq       = 8.1838e6;    % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
    case 'SIGEv2'
        settings.IF                 = 4.1304e6;     % (Hz)
        settings.samplingFreq       = 16.3676e6;    % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
%---- SIGE v3 -------------------------------------------------------------
    case 'SIGEv3_raw'
        settings.IF                 = 0;      % (Hz) (CHECK IF IT IS CORRECT)
        settings.samplingFreq       = 8.184e6;     % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
    case 'SIGEv3'
        settings.IF                 = 4.092e6;      % (Hz)
        settings.samplingFreq       = 16.368e6;     % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
%----- Fraunhofer ---------------------------------------------------------
    case 'Fraunhofer'
        settings.IF                 = 3.07e6;      % (Hz)
        settings.samplingFreq       = 13e6;        % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
%----- Stereo -------------------------------------------------------------
    case 'Stereo'
        settings.IF                 = 3.905e6;     % (Hz)
        settings.samplingFreq       = 16e6;        % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
%---- USRP ----------------------------------------------------------------
    case 'USRP 5M_16bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 5e6;           % (Hz)
        settings.dataType           = 'int16';
        settings.samplingMode       = 'IQ';   
    case 'USRP 5M_32bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 5e6;           % (Hz)
        settings.dataType           = 'float32';
        settings.samplingMode       = 'IQ';    
    case 'USRP 20M_16bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 20e6;          % (Hz)
        settings.dataType           = 'int16';
        settings.samplingMode       = 'IQ';
    case 'USRP 25M_16bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 25e6;          % (Hz)
        settings.dataType           = 'int16';
        settings.samplingMode       = 'IQ';
    case 'USRP 20M_8bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 20e6;          % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
    case 'USRP 5M_8bit'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 5e6;           % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
%---- JRC 4tuNe -----------------------------------------------------------
    case '4tuNe'
        switch settings.signal
            case {'G1C','E1B','E1C'}
                settings.IF                 = -48.75e3;      % L1 (Hz)
                settings.samplingFreq       = 5e6;           % (Hz)
            case 'G2C'
                settings.IF                 = -56.25e3;      % L2 (Hz)
                settings.samplingFreq       = 5e6;           % (Hz)
            case {'E5I','E5A'}
                settings.IF                 = 121.875e3;      % L5 (Hz)
                settings.samplingFreq       = 30e6;           % (Hz)
            case 'G1C and G2C'
                disp('fix this!')
            otherwise
                disp('Error')
        end
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
%---- JRC 4tuNe raw uncompressed ------------------------------------------
    case '4tuNe_raw' % Only L1/E1 so far
        settings.IF                 = -48.75e3;      % L1 (Hz)
        settings.samplingFreq       = 5e6;           % (Hz)
        settings.dataType           = 'uint16';
        settings.samplingMode       = 'IQ';
%---- HacRF ONE -----------------------------------------------------------        
    case 'HackRF ONE'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 10e6;          % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
%---- Amungo --------------------------------------------------------------        
    case 'Amungo1'
        settings.IF                 = 9.58e6;   % (Hz)
        settings.samplingFreq       = 31.7e6;   % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
    case 'Amungo2'
        settings.IF                 = 9.58e6;   % (Hz)
        settings.samplingFreq       = 65e6;     % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'real';
%---- Qascom-LuGRE --------------------------------------------------------
    case {'Qascom-LuGRE', 'Qascom-LuGRE_old'} 
        % metadata will be read in the file
        settings.IF                 = NaN;      % (Hz)
        settings.samplingFreq       = NaN;    % (Hz)
        settings.dataType           = '-';
        settings.samplingMode       = '-';
%---- UserDefined ---------------------------------------------------------
    case 'UserDefined'
        settings.IF                 = 0;             % (Hz)
        settings.samplingFreq       = 8e6;           % (Hz)
        settings.dataType           = 'int8';
        settings.samplingMode       = 'IQ';
%---- Otherwise -----------------------------------------------------------
    otherwise
        disp('Unknown front-end.');
end

%---- Code rate and frequency ---------------------------------------------
switch settings.signal
    case 'G1C'
        settings.codeFreqBasis      = 1.023e6;
        settings.codeLength         = 1023;
    case 'G2C'
        settings.codeFreqBasis      = 1.023e6;
        settings.codeLength         = 20460;
    case {'E1B','E1C'}
        settings.codeFreqBasis      = 1.023e6 * 2; %times two due to BOC
        settings.codeLength         = 4092 * 2;    %times two due to BOC
    case {'G5I','G5Q'}
        settings.codeFreqBasis      = 10.23e6;
        settings.codeLength         = 10230*20; %%L5 gen code is every 20ms (20 code base periods, 2 NH10 periods)        
    case {'E5a'}
        settings.codeFreqBasis      = 10.23e6;
        settings.codeLength         = 10230; 
    case 'GPS L1 and L2'
        disp('fix this!')
end

