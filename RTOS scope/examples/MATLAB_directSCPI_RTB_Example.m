% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET

% type "help VISA_Instrument" to get help on VISA_Instrument class

%-----------------------------------------------------------
% Initialization:
%-----------------------------------------------------------
try
    rtb = VISA_Instrument('TCPIP::10.212.0.169::INSTR'); % Adjust the VISA Resource string to fit your instrument
    rtb.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % rtb.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    idnResponse = rtb.QueryString('*IDN?');
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    rtb.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    rtb.ErrorChecking(); % Error Checking after Initialization block
    %-----------------------------------------------------------
    % Basic Settings:
    %-----------------------------------------------------------
    rtb.Write('TIM:ACQT %f', 0.01); % 10ms Acquisition time
    rtb.Write('CHAN1:RANG %f', 5.0); % Horizontal range 5V (0.5V/div)
    rtb.Write('CHAN1:OFFS 0.0'); % Offset 0
    rtb.Write('CHAN1:COUP ACL'); % Coupling AC 1MOhm
    rtb.Write('CHAN1:STAT ON'); % Switch Channel 1 ON
    rtb.ErrorChecking(); % Error Checking after Basic Settings block
    %-----------------------------------------------------------
    % Trigger Settings:
    %-----------------------------------------------------------
    rtb.Write('TRIG:A:MODE AUTO'); % Trigger Auto mode in case of no signal is applied
    rtb.Write('TRIG:A:TYPE EDGE;:TRIG:A:EDGE:SLOP POS'); % Trigger type Edge Positive
    rtb.Write('TRIG:A:SOUR CH1'); % Trigger source CH1
    rtb.Write('TRIG:A:LEV1 %f', 0.05); % Trigger level 0.05V
    rtb.QueryString('*OPC?'); % Using *OPC? query waits until all the instrument settings are finished
    rtb.ErrorChecking(); % Error Checking after Trigger Settings block
    % -----------------------------------------------------------
    % SyncPoint 'SettingsApplied' - all the settings were applied
    % -----------------------------------------------------------
    % Arming the SCOPE for single acquisition
    % -----------------------------------------------------------
    rtb.SetTimeoutMilliseconds(2000); % Acquisition timeout - set it higher than the acquisition time
    rtb.Write('SING');
    % -----------------------------------------------------------
    % DUT_Generate_Signal() - in our case we use Probe compensation signal
    % where the trigger event (positive edge) is reoccuring
    % -----------------------------------------------------------
    fprintf('Waiting for the acquisition to finish... ');
    tic
    rtb.QueryString('*OPC?'); % Using *OPC? query waits until the instrument finished the acquisition
    toc
    rtb.ErrorChecking(); % Error Checking after the acquisition is finished
    % -----------------------------------------------------------
    % SyncPoint 'AcquisitionFinished' - the results are ready
    % -----------------------------------------------------------
    % Fetching the waveform in ASCII format
    % -----------------------------------------------------------
    samplesCount = rtb.QueryInteger('ACQ:POIN?'); % Query the expected samples count
    fprintf('Fetching waveform in ASCII format... ');
    tic
    waveformASC = rtb.QueryASCII_ListOfDoubles('FORM ASC;:CHAN1:DATA?', samplesCount); % samplesCount is the maximum allowed samples to read
    toc
    fprintf('Samples count: %d\n', size(waveformASC, 2));
    rtb.ErrorChecking(); % Error Checking after the data transfer
    % -----------------------------------------------------------
    % Fetching the trace in Binary format
    % Transfer of traces in binary format is faster.
    % The waveformBIN data and waveformASC data are however the same.
    % -----------------------------------------------------------
    fprintf('Fetching waveform in binary format... ');
    tic
    waveformBIN = rtb.QueryBinaryFloatData('FORM:BORD LSBF;:FORM REAL;:CHAN1:DATA?', false);
    toc
    fprintf('Samples count: %d\n', size(waveformBIN, 2));
    rtb.ErrorChecking(); % Error Checking after the data transfer
    plot(waveformBIN); % Displaying the waveform
    % -----------------------------------------------------------
    % Making an instrument screenshot and transferring the file to the PC
    % -----------------------------------------------------------
    fprintf('Taking instrument screenshot and saving it to the PC... ');
    rtb.Write(':MMEM:DEL ''Dev_Screenshot.png'''); % Delete the file if it already exists
    rtb.ClearStatus() % If the 'Dev_Screenshot.png' didn't exist, the instrument generates an error. Clear it.
    rtb.Write('HCOP:LANG PNG;:MMEM:NAME ''Dev_Screenshot'''); % Hardcopy settings for taking a screenshot - notice no file extention here
    rtb.Write('HCOP:IMM'); % Make the screenshot now
    rtb.QueryString('*OPC?'); % Wait for the screenshot to be saved
    rtb.ErrorChecking(); % Error Checking after the screenshot creation
    rtb.Write('MMEM:DATA? ''Dev_Screenshot.png'''); % Query the instrument file
    rtb.ReadBinaryDataToFile('c:\Temp\PC_Screenshot.png'); % Read the response and store the file to the PC
    fprintf('saved to PC c:\\Temp\\PC_Screenshot.png\n');
    rtb.ErrorChecking(); % Error Checking after the scresnshot save
    % -----------------------------------------------------------
    % Copying one setup file from instrument to the PC and back under a different name
    % This shows how to transfer files between the PC and instrument in both directions
    % -----------------------------------------------------------
    % Read the instrument file SET01.SET to the PC file PC_SET01.SET
    fprintf('Copying instrument setup file SET01.SET and saving it to the PC... ');
    rtb.QueryBinaryDataToFile('MMEM:DATA? ''/INT/SETTINGS/SET01.SET''', 'C:\temp\PC_SET01.SET');
    rtb.Write(':MMEM:DEL ''/INT/SETTINGS/SET05.SET'''); % Delete the file if it already exists
    rtb.ClearStatus() % If the '/INT/SETTINGS/SET05.SET' didn't exist, the instrument generates an error. Clear it.
    fprintf('saved to PC c:\\Temp\\PC_SET01.SET\n');
    
    fprintf('Copying PC setup file c:\\Temp\\PC_SET01.SET to the instrument under the name SET05.SET ... ');
    fileID = fopen('C:\temp\PC_SET01.SET');
    content = fread(fileID);
    fclose(fileID);
    % Last parameter forces LF at the end of the transfer - necessary for RTB2000, RTM2000, RTM3000, RTA4000
    rtb.WriteBinaryDataBlock('MMEM:DATA ''/INT/SETTINGS/SET05.SET'',', content, true);
    fprintf('finished\n');
    rtb.ErrorChecking(); % Error Checking after the file transfer
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
    rtb.Close() % Closing the session to the instrument
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