function action1(src,event)
% This callback toggles the visibility of the line of a plot

if strcmp(event.SelectionType,"normal") == 1
    if strcmp(event.Peer.Visible,'on')   % If current line is visible
        event.Peer.Visible = 'off';      %   Set the visibility to 'off'
    else                                 % Else
        event.Peer.Visible = 'on';       %   Set the visibility to 'on'
    end

elseif strcmp(event.SelectionType,"extend") == 1
    str = src.String;

    for i = 1:length(src.String)
        h = findobj(gca,'flat','-depth',2,'DisplayName',string(str(i)));

        if strcmp(h.Visible,'on')
            h.Visible = 'off';
        else
            h.Visible = 'on';
        end
    end
elseif strcmp(event.SelectionType,"open") == 1
    str = src.String;

    for i = 1:length(src.String)
        h = findobj(gca,'flat','-depth',2,'DisplayName',string(str(i)));

        if contains(h.DisplayName,"5I")
            h.Visible = 'off';
        else
            h.Visible = 'on';
        end
    end
end