% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET

% RTO/RTE Oscilloscope example
% type "help VISA_Instrument" to get help on VISA_Instrument class

%-----------------------------------------------------------
% Initialization:
%-----------------------------------------------------------
try
    scope = VISA_Instrument('TCPIP::192.168.2.101::INSTR'); % Adjust the VISA Resource string to fit your instrument
    scope.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % scope.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    idnResponse = scope.QueryString('*IDN?');
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    scope.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    scope.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging
    scope.ErrorChecking(); % Error Checking after Initialization block
    %-----------------------------------------------------------
    % Basic Settings:
    %-----------------------------------------------------------
    scope.Write('ACQ:POIN:AUTO RECL'); % Define Horizontal scale by number of points
    scope.Write('TIM:RANG %f', 0.01); % 10ms Acquisition time
    scope.Write('ACQ:POIN %d', 100000); % 100ksamples
    scope.Write('CHAN1:RANG %f', 2.0); % Horizontal range 2V
    scope.Write('CHAN1:POS 0'); % Offset 0
    scope.Write('CHAN1:COUP AC'); % Coupling AC 1MOhm
    scope.Write('CHAN1:STAT ON'); % Switch Channel 1 ON
    scope.ErrorChecking(); % Error Checking after Basic Settings block

    %-----------------------------------------------------------
    % Trigger Settings:
    %-----------------------------------------------------------
    scope.Write('TRIG1:MODE AUTO'); % Trigger Auto mode in case of no signal is applied
    scope.Write('TRIG1:SOUR CHAN1'); % Trigger source CH1
    scope.Write('TRIG1:TYPE EDGE;:TRIG1:EDGE:SLOP POS'); % Trigger type Edge Positive
    scope.Write('TRIG1:LEV1 0.04'); % Trigger level 40mV
    scope.QueryString('*OPC?'); % Using *OPC? query waits until all the instrument settings are finished
    scope.ErrorChecking(); % Error Checking after Trigger Settings block

    % -----------------------------------------------------------
    % SyncPoint 'SettingsApplied' - all the settings were applied
    % -----------------------------------------------------------
    % Arming the SCOPE for single acquisition
    % -----------------------------------------------------------
    scope.SetTimeoutMilliseconds(2000); % Acquisition timeout - set it higher than the acquisition time
    scope.Write('SING');
    % -----------------------------------------------------------
    % DUT_Generate_Signal() - in our case we use Probe compensation signal
    % where the trigger event (positive edge) is reoccuring
    % -----------------------------------------------------------
    fprintf('Waiting for the acquisition to finish... ');
    tic
    scope.QueryString('*OPC?'); % Using *OPC? query waits until the instrument finished the Acquisition
    toc
    scope.ErrorChecking(); % Error Checking after the acquisition is finished
    % -----------------------------------------------------------
    % SyncPoint 'AcquisitionFinished' - the results are ready
    % -----------------------------------------------------------
    % Fetching the waveform in ASCII format
    % -----------------------------------------------------------
    samplesCount = scope.QueryInteger('ACQ:POIN?'); % Query the expected samples count
    fprintf('Fetching waveform in ASCII format... ');
    tic
    waveformASC = scope.QueryASCII_ListOfDoubles('FORM ASC;:CHAN1:DATA?', samplesCount); % samplesCount is the maximum allowed samples to read
    toc
    fprintf('Samples count: %d\n', size(waveformASC, 2));
    scope.ErrorChecking(); % Error Checking after the data transfer
    % -----------------------------------------------------------
    % Fetching the trace in Binary format
    % Transfer of traces in binary format is faster.
    % The waveformBIN data and waveformASC data are however the same.
    % -----------------------------------------------------------
    fprintf('Fetching waveform in binary format... ');
    tic
    waveformBIN = scope.QueryBinaryFloatData('FORM REAL,32;:CHAN1:DATA?');
    toc
    fprintf('Samples count: %d\n', size(waveformBIN, 2));
    scope.ErrorChecking(); % Error Checking after the data transfer
    plot(waveformBIN); % Displaying the waveform
    % -----------------------------------------------------------
    % Making an instrument screenshot and transferring the file to the PC
    % -----------------------------------------------------------
    fprintf('Taking instrument screenshot and saving it to the PC... ');
    scope.Write('HCOP:DEV:LANG PNG;:MMEM:NAME ''c:\Temp\Device_Screenshot.png'''); % Hardcopy settings for taking a screenshot
    scope.Write('HCOP:IMM'); % Make the screenshot now
    scope.QueryString('*OPC?'); % Wait for the screenshot to be saved
    scope.ErrorChecking(); % Error Checking after the screenshot creation
    scope.Write('MMEM:DATA? ''c:\Temp\Device_Screenshot.png''');
    scope.ReadBinaryDataToFile('c:\Temp\PC_Screenshot.png');
    fprintf('saved to PC c:\\Temp\\PC_Screenshot.png\n');
    scope.ErrorChecking(); % Error Checking after the scresnshot save
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
    scope.Close() % Closing the session to the instrument
    % -----------------------------------------------------------
    % Error handling
    % -----------------------------------------------------------
catch ME
    switch ME.identifier
        case 'VISA_Instrument:ErrorChecking'
            % Perform your own additional steps here
            rethrow(ME);
        otherwise
            rethrow(ME);
    end
end