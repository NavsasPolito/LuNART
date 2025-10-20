function [msg] = genReport(reportPath,reportTitle,templatePath,textFields,figures,outputConsole,oprtComment,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

msg = "";

try
    % import useful libraries of report and lower level components
    makeDOMCompilable();
    import mlreportgen.report.*
    import mlreportgen.dom.*
catch
    msg = "Library import failing";
    warning(msg);
end

try
    % create and open the document
    D = Document(strcat(reportPath,'\',reportTitle),'docx',templatePath);
catch
    msg = sprintf("File creation failed. %s, %s, %s",reportPath,reportTitle,D);
    warning(msg);
end

try
    open(D);
catch
    msg = sprintf("File opening failed. %s, %s",reportPath,reportTitle);
    warning(msg);
end

% Header table
try
    for textIdx = 1:numel(textFields)
        moveToNextHole(D);

        T = Text(textFields(textIdx));
        T.WhiteSpace = "pre-wrap";
        append(D,T);
    end
    moveToNextHole(D);

    % Optional fields (i.e., configuration data passed as string array)
    % if nargin>7 && ~isempty(varargin{1})
    %     for strIdx=1:numel(varargin{1})
    %         append(D,Text(varargin{1}(strIdx)));
    %         moveToNextHole(D);
    %     end
    % end

    % Figure filling
    for iFig = 1:size(figures,2)

        % append(D,Text(textFields(iFig+6)));
        % moveToNextHole(D);

        w = sscanf(figures(iFig).Width,'%dpx');
        h = sscanf(figures(iFig).Height,'%dpx');
        r = w/h;

        %--- Resized height
        h_r = 6.7/r;
        %--- Check if taller than paper
        rS = max(h_r / 9, 1);
        %--- Resize accordingly
        height = sprintf("%.3fin", h_r/rS);
        width = sprintf("%.3fin", 6.7/rS);
        %--- Apply size
        figures(iFig).Width  = width;
        figures(iFig).Height = height;

        append(D,figures(iFig));
        moveToNextHole(D);
    end

    %--- Report text output
    try
        %--- Important! Preserves white space. Text wraps when necessary and on line breaks.
        T = Text(strjoin(string(outputConsole),'\r\n'));
        T.WhiteSpace = "pre-wrap";

        append(D,T);
        moveToNextHole(D);

        %--- Operator comments
        T = Text(strjoin(oprtComment,'\r\n'));
        T.WhiteSpace = "pre-wrap";

        append(D,T);
    catch
        warning("Report generation routine expects additional textual data not present.");
        msg = "Missing text data after figures";
    end

catch
    warning("Something went wrong with the report generation (report assembly)");
    msg = "Missing report";
end

try
    % finalize and close the document
    close(D);
    rptview(D.OutputPath, 'pdf');
catch
    warning("Report closure and preview failed.");
    msg = "Missing Report";
end

%catch
%warning("Something went wrong with the report generation")
%msg = "Missing Report";