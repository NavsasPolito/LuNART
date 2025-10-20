function [figurePaths] = saveFigs(folderName)
%SAVEFIGS Summary of this function goes here
%   Detailed explanation goes here

figList = findobj(allchild(0), 'flat', 'Type', 'figure');

for iFig = 1:numel(figList)
    if isempty(figList(iFig).Number)
        GUIidx = iFig;
    end
end

% Sorting figList to preserve order of generation/appearance
A = [figList.Number];
[~, idx] = sort(A);
idx(idx >= GUIidx) = idx(idx >= GUIidx) + 1;

% Create folder
if ~isfolder(folderName)
    mkdir(folderName);
end

figurePaths = [];

for iFig = idx
    FigHandle = figList(iFig);
    if ~isempty(FigHandle.Number)
        FigName   = string(get(FigHandle, 'Number'));

        %saveas(FigHandle, fullfile(folderName, strcat(FigName, '.fig')));
        savefig(FigHandle, fullfile(folderName, FigName));
        saveas(FigHandle, fullfile(folderName, strcat(FigName, '.eps')));
        saveas(FigHandle, fullfile(folderName, strcat(FigName, '.svg')));
        %exportgraphics(FigHandle, fullfile(folderName, strcat(FigName, '.pdf')), 'ContentType', 'vector');

        figurePaths = [figurePaths fullfile(folderName, strcat(FigName, '.svg'))];
    end
end