% RTO/RTE Oscilloscope example using SING command with STB polling synchronization
% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET

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
    scope.Write('*RST;*CLS;:SYST:DISP:UPD ON'); % Reset the instrument
    % One time setting after *RST
    scope.Write('*ESE 1'); % Event Status Enable OPC bit
    scope.ErrorChecking(); % Error Checking
    %-----------------------------------------------------------
    % Settings all in one string:
    %-----------------------------------------------------------
    scope.Write('ACQ:POIN:AUTO RECL;:TIM:RANG 2.0;:ACQ:POIN 1002;:CHAN1:STAT ON;:TRIG1:MODE AUTO'); % Define Horizontal scale by number of points
    scope.ErrorChecking(); % Error Checking
    %-----------------------------------------------------------
    % Acquisition
    %-----------------------------------------------------------
    % Sending SCPI command SING and using STB polling synchonization, timeout 6000 ms
    tic
    fprintf('\nStarting the acquisition... ');
    scope.WriteWithSTBpollSync('SING', 6000);
    fprintf('finished\n');
    toc
    scope.ErrorChecking(); % Error Checking
    %-----------------------------------------------------------
    % Selftest
    %-----------------------------------------------------------
    fprintf('\nStarting the Selftest... ');
    % Sending SCPI Query *TST? and using STB polling synchonization, timeout 120000 ms
    scope.QueryWithSTBpollSync('*TST?', 120000);
    fprintf('finished\n');
    toc
    fprintf('\nScript finished');
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