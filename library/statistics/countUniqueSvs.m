function [GPS, GAL] = countUniqueSvs(obsSolutions, settings)

%--- Initialize 
GPS = zeros(1,length(obsSolutions(1).cn0));
GAL = zeros(1,length(obsSolutions(1).cn0));
idxPRNL1 = zeros(1,68);
idxPRNL5 = zeros(1,68);

%--- Save local variables to avoid accessing the struct too many times
PRNs = [obsSolutions.PRN];
channels = [obsSolutions.channel];

%--- Search where GPS PRNs are in obsSolutions
for j = 1:32
    temp = intersect(find(PRNs == j), find(contains(channels,"G1")));
    if isscalar(temp)
        idxPRNL1(j) = temp;
    end
    temp = intersect(find(PRNs == j), find(contains(channels,"G5")));
    if isscalar(temp)
        idxPRNL5(j) = temp;
    end
end
%--- Search where GAL PRNs are in obsSolutions
for j = 1:36
    temp = intersect(find(PRNs == j), find(contains(channels,"E1")));
    if isscalar(temp)
        idxPRNL1(j+32) = temp;
    end
    temp = intersect(find(PRNs == j), find(contains(channels,"E5")));
    if isscalar(temp)
        idxPRNL5(j+32) = temp;
    end
end

%--- Compute visibility for GPS
for i = 1:32
    %--- Set to zero
    visL1 = false(1,length(obsSolutions(1).cn0));
    visL5 = false(1,length(obsSolutions(1).cn0));
    %--- If PRN exist, find epochs above threshold
    if idxPRNL1(i) ~= 0
        visL1 = obsSolutions(idxPRNL1(i)).cn0 > settings.G1th;
    end
    %--- Same for L5
    if idxPRNL5(i) ~= 0
        visL5 = obsSolutions(idxPRNL5(i)).cn0 > settings.G5th;
    end
    %--- Sum to total
    GPS = GPS + double(visL1 | visL5);
end
%--- Compute visibility for GAL
for i = 33:68
    %--- Set to zero
    visL1 = false(1,length(obsSolutions(1).cn0));
    visL5 = false(1,length(obsSolutions(1).cn0));
    %--- If PRN exist, find epochs above threshold
    if idxPRNL1(i) ~= 0
        visL1 = obsSolutions(idxPRNL1(i)).cn0 > settings.E1th;
    end
    %--- Same for E5
    if idxPRNL5(i) ~= 0
        visL5 = obsSolutions(idxPRNL5(i)).cn0 > settings.E5th;
    end
    %--- Sum to total
    GAL = GAL + double(visL1 | visL5);
end