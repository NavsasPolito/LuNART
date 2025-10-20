function [PRNColors] = PRNColors(seed)
% This function assigns a color to the different SV. To do this, it gives a
% random RGB triplet to each of the PRN

%--- Set up seed
rng(seed);

%--- Initialize structure
PRNColors(1).PRN = 1;
PRNColors(1).channel = "L1CA";
PRNColors(1).Color = [rand, rand, rand];
PRNColors(1).plot = true;

for i = 2:136
    if i <= 64 % GPS
        PRNColors(i).PRN = floor((i+1)/2);
        if mod(i,2) == 0
            PRNColors(i).channel = "L5";
        else
            PRNColors(i).channel = "L1CA";
        end
    else
        PRNColors(i).PRN = floor((i-63)/2);
        if mod(i,2) == 0
            PRNColors(i).channel = "E5A";
        else
            PRNColors(i).channel = "E1BC";
        end
    end
    PRNColors(i).plot = true;

    %--- Color generation
    unique = 1;

    while unique == 1
        unique = 0;
        randomTriplet = [rand, rand, rand];

        colorDist = vecnorm(randomTriplet' - vertcat(PRNColors(1:i-1).Color)'); 
        if min(colorDist) <= 0.15
            unique = 1;
        end
    end

    PRNColors(i).Color = randomTriplet;
end