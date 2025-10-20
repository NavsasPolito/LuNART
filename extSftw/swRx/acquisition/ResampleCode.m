function resampledCode = ResampleCode(code, numPoints, fs, tau0, fc )

% ResampleCode - Resamples a ranging code.
%
%   resampledCode = ResampleCode( code, numPoints, fs, tau0, fc )
%
%   code - The code sequence (+/-1)
%   numPoints - The number of points in the resampled code
%   fs - The sampling rate to use for resampling
%   tau0 - The phase of the first sample of the resampled code
%   fc - The chipping rate of the code.
%
% Based on code by:
% Laura Camoriano, June 2005


% tVec - Vector of sample instants
tVec = ( 0:1:(numPoints-1) ) / fs;

resampledCode = code(mod(floor(tVec*fc + tau0), length( code ) )+1);