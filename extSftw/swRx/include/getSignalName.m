function sigName = getSignalName(settings)
% This function provides the complete signal name starting from the
% settings.signal field according to the Rinex naming notation where
% possible

% NavSAS 2023
% Written by Andrea Nardin

switch settings.signal
    case 'G1C'
        sigName = "GPS L1 C/A";
    case 'E1C'
        sigName = "Galileo E1C";
    case 'E1B'
        sigName = "Galileo E1B";
    otherwise
        error 'Unknown signal name'
end

end