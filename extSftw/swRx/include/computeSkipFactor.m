function skp_factor = computeSkipFactor(settings)
% Computes the no. of bytes per sample in binary file.
% Depending on the data type and the sampling format, a sample corresonds
% to a different size, and the fseek and the ftell have to be adjusted
% accordingly

% Data type can be:
% int8, or schar: 1 Byte per sample
% int16, or short: 2 Bytes per sample
% uint16 is for 4tuNe_raw, we skip 1 because 2 Bytes correspond to only 1 sample
switch settings.dataType
    case {'int8', 'schar'}
        skp_factor = 1;
    case {'int16', 'short'}
        skp_factor = 2;
    case {'uint16'}
        skp_factor = 1;
    case {'float32'}
        skp_factor = 4;
    case {'bit4','ubit4'}
        skp_factor = 0.5; % works for Qascom Neil rx
    otherwise
        warning('Attention: data Type %s not valid (computeSkipFactor.m).\n', settings.dataType)
        skp_factor = 0;
end

% Sampling mode can be either IQ or real. In the first case we have one
% sample real, and one sample complex, thus we double the size of a byte
switch settings.samplingMode
    case 'IQ'
        skp_factor = 2 * skp_factor;
    case 'real'
        skp_factor = 1 * skp_factor;
    otherwise
        warning('Attention: sampling mode %s not valid (computeSkipFactor.m).\n', settings.samplingMode)
        skp_factor = 0;
end
