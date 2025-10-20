function sigma2 = NoiseVarianceEstimator( y, fs, fc, fif )
%
% Summary:
%   Function that evaluates the noise floor for setting the acquisition 
%   threshold.
%
% Arguments:
%   y :         [vector] contains the input samples
%   fs:         [scalar] sampling frequency
%   fc:         [scalar] code rate
%   fif:        [scalar] the intermediate frequency
%
% Returns:
%   sigma2:     [scalar] the estimated noise variance
%
%--- First generate a fictitious code
clen = round( length( y ) / fs * fc );
code =  sign( rand( 1, clen ) - 0.5 );      % A bipolar random code usually has
                                            % good correlation properties                                        
%--- Resample the code
loc = ResampleCode( code, length( y ), fs, 0, fc );

%--- Now compute the correlators (for a single Doppler value is enough)
correlators = DftParallelCodePhaseAcquisition( y.', loc, length( y ), 1, 0, fs, fif );

%--- Down-sample them to get uncorrelated values:
step = round( fs / fc );
correlators = correlators(1:step:end);

%--- Finally my noise variance estimate
sigma2 = mean( correlators )./2;
% sigma2 = 2*mean( correlators ); under assessesment