% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET

% type "help VISA_Instrument" to get help on VISA_Instrument class

%-----------------------------------------------------------
% Initialization:
%-----------------------------------------------------------
try
    rth = VISA_Instrument('TCPIP::10.64.0.24::INSTR'); % Adjust the VISA Resource string to fit your RTH instrument
    rth.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % rth.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    idnResponse = rth.QueryString('*IDN?');
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    rth.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    rth.ErrorChecking(); % Error Checking after Initialization block
    %-----------------------------------------------------------
    % Basic Settings:
    %-----------------------------------------------------------
    rth.WriteWithOPC('STOP'); % Stop Acquisition
    rth.Write('CHAN1:STAT ON'); % Switch Channel 1 ON
    rth.Write('CHAN1:RANG %f', 1.0); % Horizontal range 1V (25mV/div)
    rth.Write('CHAN1:POS %0.2f', 1.0); % Offset 1.0V
    rth.Write('CHAN1:COUP DCL'); % Coupling DC 
    rth.Write('TIM:SCAL %0.6f', 0.001); % Acquisition time 1ms
    rth.WriteWithOPC('TIM:REF %d', 50); % Reference time 50% - this puts the trigger event time to the middle of the acquisition
    rth.ErrorChecking(); % Error Checking after Basic Settings block
    %-----------------------------------------------------------
    % Trigger Settings:
    %-----------------------------------------------------------
    rth.Write('TRIG:SOUR %s', 'C1'); % Trigger source Channel 1
    rth.Write('TRIG:MODE AUTO'); % Trigger Auto mode in case of no signal is applied
    rth.Write('TRIG:EDGE:SLOP POS'); % Trigger type Edge Positive
    rth.WriteWithOPC('TRIG:LEV1:VAL %.03f', -0.05); % Trigger level -0.05V, wait for all the trigger settings to be processed
    rth.ErrorChecking(); % Error Checking after Trigger Settings block
    % -----------------------------------------------------------
    % SyncPoint 'SettingsApplied' - all the settings were applied
    % -----------------------------------------------------------
    % Arming the RTH for single acquisition
    % -----------------------------------------------------------
    rth.SetTimeoutMilliseconds(2000); % Acquisition timeout - set it higher than the acquisition time
    rth.Write('RUN');
    % -----------------------------------------------------------
    % DUT_Generate_Signal() - in our case we use Probe compensation signal
    % where the trigger event (positive edge) is reoccuring
    % -----------------------------------------------------------
    fprintf('Waiting for the acquisition to finish... ');
    tic
    rth.QueryString('*OPC?'); % Using *OPC? query waits until the instrument finished the acquisition
    toc
    rth.ErrorChecking(); % Error Checking after the acquisition is finished
    % -----------------------------------------------------------
    % SyncPoint 'AcquisitionFinished' - the results are ready
    % -----------------------------------------------------------
    % Fetching the trace in Binary format
    % -----------------------------------------------------------
    fprintf('Fetching waveform in binary format... ');
    tic
    binData = rth.QueryBinaryDataBlock('FORM:BORD LSBF;:FORM:DATA INT,16;:CHAN1:DATA?');
    
    % The waveform is an array of Int16 raw ADC values, we need to scale them
    verticalScale = rth.QueryDouble('CHAN1:SCAL?');
    channelOffset = rth.QueryDouble('CHAN1:OFFS?');
    verticalOffset = rth.QueryDouble('CHAN1:POS?');
    int16data = typecast(binData, 'int16');
    offset = channelOffset - (verticalScale * verticalOffset);
    scaling = verticalScale * 8 / (255*256);
    waveform = double(int16data) * scaling + offset;
    toc
    fprintf('Samples count: %d\n', size(waveform, 2));
    rth.ErrorChecking(); % Error Checking after the data transfer
    plot(waveform); % Displaying the waveform
    % -----------------------------------------------------------
    % Making an instrument screenshot and transferring the file to the PC
    % -----------------------------------------------------------
    fprintf('Taking instrument screenshot and saving it to the PC... ');
    % Hardcopy settings for taking a screenshot - notice no file extention here
    rth.Write('HCOP:LANG PNG;:HCOP:COL OFF;:MMEM:NAME ''/media/SD/Rohde-Schwarz/RTH/Screenshots/Device_Screenshot.png''');
    rth.WriteWithOPC('HCOP:IMM'); % Make the screenshot now
    rth.ErrorChecking(); % Error Checking after the screenshot creation
    rth.Write('MMEM:DATA? ''/media/SD/Rohde-Schwarz/RTH/Screenshots/Device_Screenshot.png'''); % Query the instrument file
    rth.ReadBinaryDataToFile('c:\Temp\PC_Screenshot.png'); % Read the response and store the file to the PC
    fprintf('saved to PC c:\\Temp\\PC_Screenshot.png\n');
    rth.ErrorChecking(); % Error Checking after the scresnshot save
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
    rth.Close() % Closing the session to the instrument
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