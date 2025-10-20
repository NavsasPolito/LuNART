function sspace = DftParallelCodePhaseAcquisition(signal, locCode, N, Nd, DopStep, fs, fi)

% Input Parameters.
% signal       : [vector] the Galileo/GPS input signal, corrupted by Doppler
%              shift, code delay, noise and eventually interferer
% locCode      : [vector] the local code replica
%
% N         : [integer] the input signal and local code length
%
% Nd        : [integer] number of Doppler bin used for the search space
%
% DopStep   : [Hz] Doppler bin width in Hz
%
% fs        : [Hz] sampling frequency
%
% fi        : [Hz] intermediate frequency 
%
% Output Parameters.
% sspace       : [matrix] the search space

%  Original version by Daniele Borio
% Version.
%   6 - 3 - 2006
% ESA/JRC summer school, Davos, 2013

% Normalized intermediate frequency
fif = fi/fs;

% Normalized Doppler step
deltaf = DopStep/fs;

sspace = zeros(Nd, N);

%F_CA = conj(fft(locCode));% /N;
% Time index
t = 0:(N - 1);

for ff = 1:Nd
    fc = fif + (ff - ceil(Nd/2))*deltaf;        
    IQ_comp = exp(-2*1i*pi*fc.*t).*signal;
    X = fft(IQ_comp);

    % Adapt code to Doppler shift
    % ------------------------------------------------------------------------------
    %
    % Doppler factor (positive for shrinking, negative for stretching)
    doppler_factor = 1 + ((ff - ceil(Nd/2))*deltaf / fs);
    %
    % Apply Doppler effect by stretching or shrinking the time axis
    t_doppler = t / doppler_factor;  % Adjust time axis based on Doppler effect
    %
    % Interpolate the oversampled Gold code to the new time axis (using interpolation)
    code_Doppler = sign(interp1(t, locCode, t_doppler, 'linear', 'extrap'));
    %
    F_CA = conj(fft(code_Doppler));% /N;
    % ------------------------------------------------------------------------------

    sspace(ff,:) = ifft(X.*F_CA);
end

sspace = real(sspace.*conj(sspace));

