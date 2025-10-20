function [satelliteList] = getSatelliteList(settings)
%GETSATELLITELIST Retrieves the requested satellite list
%    The satellite list is retrieved according to the selected
%    constellation (settings.signal) or user-defined subset

if (strcmp(settings.satelliteList,'all'))
    switch settings.signal
        case 'G1C'
            satelliteList=1:32;
        case {'E1B','E1C'}
            satelliteList=1:50;
        otherwise
            error('Unknown constellation')
    end
else
    switch settings.signal
        case 'G1C'
            if max(settings.satelliteList)>32
                error('Invalid GPS satellites subset')
            end
        case {'E1B','E1C'}
            if max(settings.satelliteList)>50
                error('Invalid Galileo satellites subset')
            end
        otherwise
            error('Unknown constellation')
    end
    satelliteList=settings.satelliteList;
end
end

