function [settings, acqResults] = NavSASrx_fcn(varargin)

%--- This is the main script

%--- Clean up the environment first
%clearvars
%close all force hidden;
%clc

format ('compact');
format ('long', 'g');

%--- Include folders with library functions
currentfolder = fileparts(which('NavSASrx.m'));
%addpath(genpath(currentfolder))

%--- Initialize constants, settings, and verify their validity
settings = initSettings();

if ~isempty(varargin{1})
    % Fixed settings (valid for any signal and constellation)
    settings.receiverMode = 1;

    settings.doProbeData        = varargin{1}.doProbeData; % spectrum and histogram (2 for enhanced probing)
    settings.doAcquisition      = 1; % acquisition stage
    settings.doTracking         = 0; % tracking stage
    settings.doNavigation       = 0; % PVT stage
    settings.doScintillation    = 0; % Scintillation analysis

    %settings.frontend = 'Qascom-LuGRE';

    settings.skipSeconds        = 0;
    settings.satelliteList      = 'all';

    % Variable settings (valid for a specific signal and constellation)
    settings.signal       = varargin{1}.signal;
    settings.rawFileL1    = varargin{1}.rawFileL1;

    settings.dopplerStep  = varargin{1}.dopplerStep;
    settings.forceSSshift = varargin{1}.forceSSshift;
    settings.searchSpace  = varargin{1}.searchSpace;
    
    settings.K            = varargin{1}.K;
    settings.acqTcoh      = varargin{1}.acqTcoh;

    settings.acqPfaSys    = varargin{1}.acqPfaSys;

    settings.acqSatelliteList    = varargin{1}.acqSatelliteList;

    settings.codeDopplerSearch = varargin{1}.codeDopplerSearch;
end

%--- Open file and check validity
[settings, fid] = openRawData(settings);
%if settings.exit
%    return;
%end

%--- Generate plot of raw data
settings = probeData(fid, settings);

%--- Temporary, check correct file
fprintf("IQS File: %s", settings.rawFileL1);

%--- Acquisition stage
acqResults   = acquisition(fid, settings,varargin{2});

%--- Tracking stage
%trackResults = tracking(fid, acqResults, settings);

%--- Calculate navigation solutions
%[obsSolutions, navSolutions] = PVT(trackResults, settings);

%--- Scintillation monitor
%scintillationResults = computeScintillation(trackResults, obsSolutions, navSolutions, settings);

end

%-------------------------------------------------------------------------%
%             Fully software NavSAS GNSS receiver: SONG                   %
%                                                                         %
% Originally based on:                                                    %
% - SoftGNSS v3.0, by Darius Plausinaitis and Dennis M. Akos              %
% - NavSAS Matlab receiver, by the NavSAS group                           %
% - GPS and Galileo PVT, by Gianluca Falco                                %
%                                                                         %
% Written by the NavSAS team.                                             %
% Contributors are: Calogero Cristodaro, Gianluca Falco, Nicola Linty,    %
% Alex Minetto, Rodrigo Romero, Thuan Dihn, Andrea Nardin, Simone Zocca   %
% http://www.navsas.eu                                                    %
%-------------------------------------------------------------------------%