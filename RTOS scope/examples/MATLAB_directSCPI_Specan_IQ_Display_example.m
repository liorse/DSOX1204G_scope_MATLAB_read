function IQ = MATLAB_directSCPI_Specan_IQ_Display_example(IP,Freq,RefLev,SampleRate,NofSamples)
% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET
%
% type "help VISA_Instrument" to get help on VISA_Instrument class
%
% The example configures the spectrum analyzer to capture IQ data. 
% The IQ data is transferred to the PC and displayed.
%
% Inputs:  IP         - Spectrum Analyzer IP address as string
%          Freq       - Center Frequency in Hz
%          RefLev     - Reference Level in dBm
%          SampleRate - Sample Rate for IQ capture in Hz
%          NofSamples - Number of Samples to capture
%
% Outputs: IQ - captured IQ data
%
% Example:
% IP         = '192.168.2.100';
% Freq       = 1e9;
% RefLev     = 0;
% SampleRate = 20e6;
% NofSamples = 20e3;
% 
% IQ = MATLAB_directSCPI_Specan_IQ_Display_example(IP,Freq,RefLev,SampleRate,NofSamples);

clc;
%-----------------------------------------------------------
% Initialization:
%-----------------------------------------------------------
try
    specan = VISA_Instrument(['TCPIP::' IP '::hislip0']); % Adjust the VISA Resource string to fit your instrument
    specan.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

try
    specan.ClearStatus();
    idnResponse = specan.QueryString('*IDN?');
    fprintf('\nInstrument Identification string: %s\n', idnResponse);
    specan.Write('*RST;*CLS'); % Reset the instrument, clear the Error queue
    specan.Write('INIT:CONT OFF'); % Switch OFF the continuous sweep
    specan.Write('SYST:DISP:UPD ON'); % Display update ON - switch OFF after debugging
    specan.ErrorChecking(); % Error Checking after Initialization block
    
    %-----------------------------------------------------------
    % Open IQ Analyzer and set parameters
    %-----------------------------------------------------------
    specan.Write('DISP:WIND:TRAC:Y:RLEV %0.2f', RefLev); % Setting the Reference Level
    specan.Write('FREQ:CENT %0.1f', Freq); % Setting the center frequency

    specan.Write('INST IQ'); % Open IQ Analyzer - Universal command for FSV / FSVA / FSW
    %specan.QueryString('INST:CRE:NEW IQ, ''IQ Analyzer'';*OPC?'); % Open IQ Analyzer on FSW
    specan.ErrorChecking(); % Error Checking
    specan.Write('TRAC:IQ:SRAT %d', SampleRate); % Set sample rate
    specan.Write('TRAC:IQ:RLEN %d', NofSamples); % Set result length
    specan.Write('TRAC:IQ:DATA:FORM IQPair');
    specan.Write('INIT:CONT OFF');
    
    specan.Write('*WAI'); % This command tells the instrument to finish processing all the previous commands
    
    specan.ErrorChecking(); % Error Checking
    
    % -----------------------------------------------------------
    % Measurement
    % -----------------------------------------------------------
    specan.QueryString('INIT:IMM; *OPC?'); % Start the capture
    specan.ErrorChecking(); % Error Checking after the acquisition is finished
    
    % -----------------------------------------------------------
    % Fetching the IQ data
    % -----------------------------------------------------------
    fprintf('Fetching IQ data... ');
    specan.Write('FORM REAL,32');
    DataVector = specan.QueryBinaryFloatData('TRAC:IQ:DATA:MEM?'); % Transfer binary IQ data    
    fprintf('done.\n');
    specan.ErrorChecking(); % Error Checking after the data transfer
        
    % -----------------------------------------------------------
    % Closing the session
    % -----------------------------------------------------------
    specan.Write('@LOC'); % Go to Local
    specan.ErrorChecking(); % Error Checking
    specan.Close() % Closing the session to the instrument
    
    % -----------------------------------------------------------
    % Error handling
    % -----------------------------------------------------------
catch ME
    switch ME.identifier
        case 'VISA_Instrument:ErrorChecking'
            % Perform your own additional steps here
            rethrow(ME);
        otherwise
            rethrow(ME)
    end
end

%% Display IQ data

%convert return data to complex number
IQData = DataVector(1:2:end) + 1j*DataVector(2:2:end);

%time vector
x = (0 : (NofSamples-1)) ./ SampleRate;

%plot time domain data
figure('name','Time-Domain IQ Signal')
subplot(311), plot(x, real(IQData)) %plot I data
title('real'), xlabel('time [sec]'), ylabel('Volt')
subplot(312), plot(x, imag(IQData)) %plot Q data
title('imaginary'), xlabel('time [sec]'), ylabel('Volt')
subplot(313), plot(x, 20*log10(abs(IQData)) - 10*log10(50) + 30) %plot magnitude
title('magnitude'), xlabel('time [sec]'), ylabel('dBm')

%plot constellation diagram
figure('name','Constellation Diagram')
plot(real(IQData),imag(IQData),'.')
xlabel('I'), ylabel('Q')
axis square

% Compute Time-Domain Power
V_RMS = sqrt( mean( abs(IQData).^2) );
P_dBm = 20 * log10( V_RMS ) - 10*log10(50) + 30;

fprintf('\nTime-Domain Power = %g dBm\n', P_dBm)

% compute Power Spectrum
L = length(IQData);

%windowing function, FSW uses a flattop window per default 
%(see IQ Analyzer advanced settings)
win = flattopwin(L)';

NFFT = 2^nextpow2(L);

%window normalization
U = sum(win)^2;

iq_win = IQData.*win;

IQ = fft(iq_win,NFFT);
IQ = flipud(fftshift(IQ)); 

% Move the Nyquist point to the right-hand side (pos freq) to be
% consistent with plot when looking at the positive half only.
IQ = [IQ(2:end,:); IQ(1,:)];
    
df = SampleRate/NFFT;
f = (1:NFFT).*df - SampleRate/2;

Pxx = IQ.*conj(IQ)/U;

%convert to dBm (50 Ohm load assumed)
Pxx = 10*log10(Pxx./50 *1000);

%IQ data are baseband data, set 0Hz == center frequency
f = f + Freq;

%plot power spectrum
figure('name','Power Spectrum')
plot(f,Pxx), grid
xlabel('frequency [Hz]'), ylabel('Power [dBm]')