function sspace = DftParallelCodePhaseAcquisitionDopplerNC(signal, Code, N, Nd, DopStep, fs, fi, settings, Tc, K, Nc)
% DFTPARALLELCODEPHASEACQUISITIONDOPPLERNC - Performs parallel code-phase search with Doppler shift
%                                              correction using the Discrete Fourier Transform (DFT).
%
% This function executes a parallel code-phase acquisition algorithm that searches over code phase 
% and Doppler frequency bins for GNSS signals. It uses the Discrete Fourier Transform to perform 
% correlation in the frequency domain, enabling efficient detection of signal parameters in the presence 
% of Doppler shifts and noise.
%
% INPUT PARAMETERS:
% signal    : [vector] The received Galileo/GPS signal, corrupted by Doppler shift, code delay, noise, 
%                     and possibly interferers.
% Code      : [vector] The local replica of the PRN code (not sampled).
% N         : [integer] Length of the input signal and local code (samples).
% Nd        : [integer] Number of Doppler bins for the search space.
% DopStep   : [Hz] Doppler bin width in Hertz.
% fs        : [Hz] Sampling frequency of the input signal.
% fi        : [Hz] Intermediate frequency of the input signal.
% settings  : [struct] General configuration settings.
% Tc        : [s] Coherent integration time in seconds.
% K         : [integer] Number of non-coherent integrations.
% Nc        : [integer] Number of code replicas used.
%
% OUTPUT PARAMETERS:
% sspace    : [matrix] The search space matrix, containing correlation values for each code phase and 
%                      Doppler frequency bin.
%
% AUTHORS:
% Original version by Daniele Borio
% Last updated: October 2024 by Alex Minetto and Lorenzo Sciacca
%
% REFERENCES:
% ESA/JRC Summer School, Davos, 2013 (original implementation)


% Normalized intermediate frequency
fif = fi/fs;

% Normalized Doppler step
deltaf = DopStep/fs;

sspace = zeros(K, Nd, N);
sspace_K = zeros(Nd, N);

if strcmp(settings.signal, 'G1C')
    chipF = 1.023e6;
else
    chipF = 2*1.023e6;
end


% Time index
t = 0:(N - 1);

k = 0:(fs*K*Tc)-1;

for ff = 1:Nd

    %--- Computing Doppler frequency
    fd = (fif + (ff - ceil(Nd/2))*deltaf) * fs;

    %--- Computing the chip rate altered by Doppler shift
    fd_chip = chipF * ( 1 + (fd/(settings.f0_L1)) );

    %--- Resampling code at the right sampling frequency
    locC_K = Code(mod(floor(k*fd_chip/fs), length(Code)) + 1);

    for iK = 1:K
        y = signal((iK - 1)*Nc + (1:2*Nc));
        locC = locC_K((iK - 1)*Nc + (1:Nc));
        locCode = [locC, zeros(1,length(locC))];%padding
        F_CA = conj(fft(locCode));
        fc = fif + (ff - ceil(Nd/2))*deltaf;        
        IQ_comp = exp(-2*1i*pi*fc.*t).*y;
        X = fft(IQ_comp);
        sspace_K(ff,:) = real((ifft(X.*F_CA)).* conj(ifft(X.*F_CA)));
        sspace(iK,:,:) = sspace_K;
    end
    
end


