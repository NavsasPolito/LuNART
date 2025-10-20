function [msg, T1] = CompareCNo(directory, file, signal, acqRes, varargin)
%This function generates the CN0 plot

if ~isempty(varargin)
    figureName = varargin{1};
else
    figureName = 999;
end

%--- Create Table 
IQSCn0Array = acqRes.peakMetric.*(acqRes.carrFreq~=-inf);
IQSCn0Array(IQSCn0Array==0) = NaN;
PRN = 1:numel(IQSCn0Array);

%--- Check if telemetry is present
if ~isempty(file)
    %--- Load  files
    path = fullfile(directory, file);
    m = load(path);

    TLMCn0Array = NaN(1,numel(IQSCn0Array)); %[m.obsSolutions([m.obsSolutions.channel]==signal).PRN];
    TLMDopArray = NaN(1,numel(IQSCn0Array));

    %--- Take first acq timestamp
    startTime = min([m.acqSolutions.rxTime]);

    for idx=1:numel(m.acqSolutions)
        %--- Check correct channel and that acquisition is perfomed within a
        % certain time (in seconds)
        if m.acqSolutions(idx).channel == signal && m.acqSolutions(idx).rxTime(1) - startTime < 300
            TLMCn0Array(m.acqSolutions(idx).PRN) = m.acqSolutions(idx).cno(1);
            TLMDopArray(m.acqSolutions(idx).PRN) = m.acqSolutions(idx).doppler(1);
        end
        T1 = table(PRN',TLMCn0Array',IQSCn0Array',TLMDopArray',acqRes.carrFreq');
        idCanc = [];
        for idx = 1:numel(IQSCn0Array)
            %--- If both TLM and IQS empty, delete row for visualization
            if isnan(T1{idx,2}) && isnan(T1{idx,3})
                idCanc(end+1) = idx;
            end
        end
        T1(idCanc,:) = [];

        T1.Properties.VariableNames = {'PRN','ACQ C/No','IQS C/No','ACQ Dop. Shift','IQS Dop. Shift'};
    end
else % telemetry data are not present
    T1 = table(PRN',IQSCn0Array',acqRes.carrFreq');
    idCanc = [];
    for idx = 1:numel(IQSCn0Array)
        %--- If both TLM and IQS empty, delete row for visualization
        if isnan(T1{idx,2})
            idCanc(end+1) = idx;
        end
    end
    T1(idCanc,:) = [];
    T1.Properties.VariableNames = {'PRN','IQS C/No','IQS Dop. Shift'};
end

h = figure(figureName);
uitable('Data',T1{:,:},'ColumnName',T1.Properties.VariableNames,'RowName',T1.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
  
%--- Plot location
Pix_SS = get(0,'screensize');
if figureName == 312
    h.OuterPosition = [Pix_SS(3)/2 0 Pix_SS(3)/4 Pix_SS(4)/3];
elseif figureName == 314
    h.OuterPosition = [3*Pix_SS(3)/4 0 Pix_SS(3)/4 Pix_SS(4)/3];
end

msg = "C/N0 comparative table generated";
