function [] = printReceiverMode(mode)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
switch mode
    case 1
        fprintf('The receiver is operating in: raw I/Q samples mode.\n')
        fprintf('The receiver is going to process input I/Q .bin file.\n')
    case 2
        fprintf('The receiver is operating in: TrackResults mode.\n')
        fprintf('The receiver is going to process already existent trackResults.\n')
    case 3
        fprintf('The receiver is operating in: Raw measurement mode.\n')
        fprintf('The receiver is going to process external raw measurements data.\n')
    otherwise
        fprintf('Receiver mode unavailable.\n')
end

end