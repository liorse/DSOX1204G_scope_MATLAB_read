% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET

try
    specan = VISA_Instrument('TCPIP::localhost::HISLIP'); % Adjust the VISA Resource string to fit your instrument
    specan.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % specan.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    specan.ClearStatus();
    idnResponse = specan.QueryString('*IDN?');
    
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    specan.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    
    % Specan trace data to PC file c:\MatlabTrace.bin
    data = specan.QueryBinaryDataBlock('FORM REAL,32;:TRAC? TRACE1');
    specan.WriteBinaryDataBlock('MMEM:DATA ''c:\MatlabTrace.bin'',', data);
    specan.ErrorChecking(); % Error Checking
    
    % PC file c:\MatlabTrace.bin to specan as c:\MatlabTrace2.bin
    fileID = fopen('c:\MatlabTrace.bin');
    A = fread(fileID);
    fclose(fileID);
    specan.WriteBinaryDataBlock('MMEM:DATA ''c:\MatlabTrace2.bin'',', A);
    specan.ErrorChecking(); % Error Checking at the end
    
    % Specan file c:\MatlabTrace2.bin to PC file c:\MatlabTrace3.bin
    specan.QueryBinaryDataToFile('MMEM:DATA? ''c:\MatlabTrace2.bin''', 'c:\MatlabTrace3.bin');
    
    
catch ME
    switch ME.identifier
        case 'VISA_Instrument:ErrorChecking'
            % Perform your own additional steps here
            rethrow(ME);
        otherwise
            rethrow(ME)
    end
end