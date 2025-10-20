function placeholderPlot(plotTitle,fignum)
    % Create a new figure
    h = figure(fignum);
    
    % Create an empty plot
    plot(nan, nan);
    
    % Keep the ticks but remove the tick labels
    set(gca, 'XTickLabel', [], 'YTickLabel', []);
    
    % Enable the grid and set its color to light grey
    grid on;
    set(gca, 'GridColor', [0.8 0.8 0.8]); % Light grey color
    set(gca, 'GridAlpha', 0.5); % Adjust grid transparency
    
    % Add text to the center of the plot
    text(0.5, 0.5, 'Unavailable plot [missing reference data]', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');
    
    % Set the plot title
    title(plotTitle, 'FontSize', 10, 'FontWeight', 'bold');
    
    % Adjust axis limits
    xlim([0 1]);
    ylim([0 1]);
    
    % Optionally, remove the box around the plot
    box off;

    Pix_SS = get(0,'screensize');
    h.OuterPosition = [Pix_SS(3)/2 2*Pix_SS(4)/3 Pix_SS(3)/2 Pix_SS(4)/3];
    h.WindowState = 'minimized';
end
