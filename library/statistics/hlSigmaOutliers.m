function [outliers_table] = hlSigmaOutliers(time, y, SV, window_size, threshold_factor, lineCol)
% Function to highlight and mark outliers using a smooth variance estimator
% Inputs:
%   x - time series timestamps
%   y - time series values
%   window_size - size of the sliding window
%   threshold_factor - factor to multiply the variance for thresholding
%
% Written by Alex Minetto

if nargin < 4
    threshold_factor = 3; % Default threshold factor is 3
end

num_points = length(y);

%--- Pre-allocate arrays for variance and mean
variance = zeros(1, num_points);
local_mean = zeros(1, num_points);
%--- Compute smooth sliding variance and mean
half_window = floor(window_size / 2);

for i = 1:num_points
    start_idx     = max(1, i - half_window);
    end_idx       = min(num_points, i + half_window);
    window_data   = y(start_idx:end_idx);
    local_mean(i) = mean(window_data);
    variance(i)   = var(window_data);
end

%--- Determine threshold based on variance
threshold       = local_mean + threshold_factor * sqrt(variance);
lower_threshold = local_mean - threshold_factor * sqrt(variance);

%--- Identify outliers
outliers_idx = find(y > threshold | y < lower_threshold);
outliers_y   = y(outliers_idx);

%--- Initialize cell array to store char arrays
cellArray = cell(numel(outliers_idx), 1);

%--- Loop to convert each string in SV to a char array and store it in a cell
for i = 1:numel(outliers_idx)
    cellArray{i} = char(SV);  % Convert each string to a char array and store in a cell
end

%--- Create a table for outliers
if ~isempty(outliers_idx) && numel(outliers_idx) > 0
    outliers_table = table(cellArray, cellstr(timeofday(time(outliers_idx'))), num2cell(outliers_y'), 'VariableNames', {'SV','Time','CMC'});

    hold on;
    %--- Plot thresholds
    h1 = plot(time, threshold,':','Color',lineCol,'LineWidth',1,'DisplayName',append(SV," Threshold"));
    h2 = plot(time, lower_threshold,':','Color',lineCol,'LineWidth',1,'DisplayName',append(SV," Threshold"));

    %--- Exclude the second line from the legend
    set(h1, 'HandleVisibility', 'off');
    set(h2, 'HandleVisibility', 'off');

    %--- Highlight outliers on the plot
    if ~isempty(outliers_idx)
        h3 = stem(time(outliers_idx), outliers_y,'-*','Color',lineCol,'MarkerSize', 8,'LineWidth',2,'DisplayName',append(SV," Outlier"));
        set(h3, 'HandleVisibility', 'off');

        %--- Label outliers
        %for j = 1:length(outliers_idx)
        %    text(time(outliers_idx(j)), outliers_y(j), sprintf('(%.1f)', outliers_y(j)), ...
        %        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', lineCol);
        %end
    end
else
    outliers_table = [];
end
