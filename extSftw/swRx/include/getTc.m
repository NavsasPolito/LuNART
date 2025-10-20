function [Tc, Tc_min] = getTc(settings, varargin)
% This function returns the integration time for the current signal
%
% TC = GETTC(SETTINGS,) returns the coherent integration time specified for
% the tracking stage
% TC = GETTC(SETTINGS, "ACQUISITION") returns the coherent integration time
% specfied for the acquisiton stage

if nargin <= 1
    Tc = settings.Tc;
    str = 'settings.Tc';
elseif varargin{1} == "acquisition"
    Tc = settings.acqTcoh;
    str = 'settings.acqTcoh';
end

switch settings.signal
    case 'G1C'
        Tc_min = 0.001;
        if ~isnumeric(Tc) && lower(Tc)=="minimum"
            Tc=Tc_min;
        else
            if mod(Tc,Tc_min)~=0
                error('%s must be an integer multiple of %.3f',str,Tc_min);
            end
        end
    case 'G2C'
        Tc_min = 0.02;
        if ~isnumeric(Tc) && lower(Tc)=="minimum"
            Tc=Tc_min;
        else
            if mod(Tc,Tc_min)~=0
                error('%s must be an integer multiple of %.3f',str,Tc_min);
            end
        end
    case 'G5I'
        disp('TBD')
    case 'E1B'
        Tc_min = 0.004;
        if ~isnumeric(Tc) && lower(Tc)=="minimum"
            Tc=Tc_min;
        else
            if mod(Tc,Tc_min)~=0
                error('%s must be an integer multiple of %.3f',str,Tc_min);
            end
        end
    case 'E1C'
        Tc_min = 0.004;
        if ~isnumeric(Tc) && lower(Tc)=="minimum"
            Tc=Tc_min;
        else
            if mod(Tc,Tc_min)~=0
                error('%s must be an integer multiple of %.3f',str,Tc_min);
            end
        end
    case 'E5A'
        Tc_min = 0.001;
        if ~isnumeric(Tc) && lower(Tc)=="minimum"
            Tc=Tc_min;
        else
            if mod(Tc,Tc_min)~=0
                error('%s must be an integer multiple of %.3f',str,Tc_min);
            end
        end
    case 'G1C and G2C'
        disp('TDB')
%    case 'GPS L1 and Gal E1b'
%        disp('TDB')
    otherwise
        error('Errorr in getTc, signal not available.')
end



