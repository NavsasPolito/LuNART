%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%             Fully software NavSAS GNSS receiver: SONG               %%%
%%%%%%%%%%               Edited by NavSAS research               %%%%%%%%%%
%%%%%%%%%%                                                       %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--- This is the main script

%--- Clean up the environment first
clearvars
close all force hidden;
clc
rng default
format ('compact');
format ('long', 'g');

%--- Include folders with library functions
currentfolder = fileparts(which('NavSASrx.m'));
addpath(genpath(currentfolder))

%--- Initialize constants, settings, and verify their validity
settings = initSettings();

%--- Open file and check validity
[settings, fid] = openRawData(settings);
%if settings.exit
%    return;
%end

%--- Generate plot of raw data
settings = probeData(fid, settings);

%--- Acquisition stage
acqResults   = acquisition(fid, settings);

%--- Tracking stage
trackResults = tracking(fid, acqResults, settings);

%--- Calculate navigation solutions
[obsSolutions, navSolutions] = PVT(trackResults, settings);

%--- Scintillation monitor
scintillationResults = computeScintillation(trackResults, obsSolutions, navSolutions, settings);

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