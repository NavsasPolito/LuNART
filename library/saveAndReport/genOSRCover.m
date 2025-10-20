function [msg] = genOSRCover(docName,templatePath,textFields,oprtComment,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

try
    % import useful libraries of report and lower level components
    makeDOMCompilable();
    import mlreportgen.report.*
    import mlreportgen.dom.*
catch
    warning("Library import failing");
end
msg = [];

try
    % create and open the document

    D = Document(docName,'docx',templatePath);

catch
    ss=sprintf("File creation failed. %s, %s, %s",reportPath,reportTitle,D);
    warning(ss);
end
try
    open(D);
catch
    ss=sprintf("File opening failed. %s, %s",reportPath,reportTitle);
    warning(ss);
    msg = "Missing Report";
end

    %--- Header table
    try
        for textIdx=1:numel(textFields)
            moveToNextHole(D);
            append(D,Text(textFields(textIdx)));
        end
    moveToNextHole(D);

    %--- Operator comments
    T = Text(strjoin(oprtComment,'\r\n'));
    T.WhiteSpace = "pre-wrap";

    append(D,T);

    catch
        warning("Something went wrong with the report generation (report assembly)");
        msg = "Missing Report";
    end

    try
    % finalize and close the document
    close(D);
    rptview(D.OutputPath, 'pdf');
    catch
        warning("Report closure and preview fa");
        msg = "Missing Report";
    end

%catch
    %warning("Something went wrong with the report generation")
    %msg = "Missing Report";
end