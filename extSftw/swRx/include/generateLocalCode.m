function [Code, Rc] = generateLocalCode(PRN, settings)

%--- Depending on the signal...
switch settings.signal
    case 'G1C'
        %--- Code rate
        Rc = 1.023e6; % chip/sample

        %--- Phase Vector L1 CA Code
        phase = [2 6; 3 7; 4 8; 5 9; 1 9; 2 10; 1 8; 2 9; 3 10;
            2 3; 3 4; 5 6; 6 7; 7 8; 8 9; 9 10; 1 4; 2 5;
            3 6; 4 7; 5 8; 6 9; 1 3; 4 6; 5 7; 6 8; 7 9;
            8 10; 1 6; 2 7; 3 8; 4 9];
        
        %--- Initial State
        G1 = -1*ones(1,10);
        G2 = G1;
        
        %--- Select the phase for G2
        s1 = phase(PRN, 1);
        s2 = phase(PRN, 2);
        
        %--- Code generation
        for idx = 1:1023
            %--- Gold code
            Code(idx) = -G2(s1)*G2(s2)*G1(10);
            %--- Generator 1 - shift reg 1
            tmp = G1(1);
            G1(1) = G1(3)*G1(10);
            G1(2:10) = [tmp G1(2:9)];
            %--- Generator 2 - shift reg 2
            tmp = G2(1);
            G2(1) = G2(2)*G2(3)*G2(6)*G2(8)*G2(9)*G2(10);
            G2(2:10) = [tmp G2(2:9)];
        end
        
    case {'E1B', 'E1C'}
        %--- Code rate
        Rc = 2*1.023e6; % chip/sample

        %--- Load the matrix contains the satellites PRN codes loading
        load('Gal_E1_Codes.dat', '-mat');
        switch settings.signal
            case {'E1B'}
                B = pr_E1_B(PRN, :);
            case {'E1C'}
                B = pr_E1_C(PRN, :);
        end
        
        %--- Power normalization
        Pcode = mean(abs(B).^2); % Assuming a theoretical mean value equal to 0
        B = B/sqrt(Pcode);
        
        %--- introduction of the BOC(1,1)
        Code = zeros(1,4092*2);
        Code(1:2:end) = B;
        Code(2:2:end) = -B;
        
    otherwise
        error('It is not possible to generate a code for %s signal.', settings.signal);
end


%% Copyright information:
% Function based on three scripts:
% 1) CAGenL.m, C/A Code Generator
% by Maurizio Fantino, Ver: 1.0, Date: 24/05/2004, UNSW Activity
% 2) xgps_2.m, function that generates simulated data
% by Laura Camoriano, June 2005
% 3) GenerateGalileoE1bcBOC, part of the N-FUELS Signal Generation and Analysis Tool
% by Beatrice Motella, Davide Margaria, Ver. 2.2, 16/10/2009, All rights reserved, 2009.