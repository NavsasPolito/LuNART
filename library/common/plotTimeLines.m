function plotTimeLines(time, idx)
% Plot vertical lines at start and end times
%
% Written by Simone Zocca

%--- If we found start & end indexes, plot them
if exist('idx','var') && isscalar(idx.Start) && isscalar(idx.End)
    xline([time(idx.Start) time(idx.End)],'k-',{'Start','End'},'LineWidth',1.2,'HandleVisibility','off');
    if isscalar(idx.Pre) && isscalar(idx.Post)
        xline([time(idx.Pre) time(idx.Post)],'k--',{'Start - 30m','End + 30m'},'LineWidth',1.2,'HandleVisibility','off');
    end
end