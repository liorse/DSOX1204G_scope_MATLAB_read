resourceString = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR'; % USB-TMC (Test and Measurement Class)

% Opening VISA session to the instrument
try
scope =  VISA_Instrument( resourceString );
scope.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % scope.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end
channel_no = 1;
query_string = ['FORM REAL,32;:CHAN' int2str(channel_no) ':DATA?'];
waveform = scope.QueryBinaryFloatData(query_string); %'FORM REAL,32;:CHAN1:DATA?'
%fprintf('Samples count: %d\n', size(waveform, 2));
waveform_range = str2double(scope.QueryString('TIM:RANG?')); % in seconds
dT = waveform_range/size(waveform, 2);
dT
size(waveform, 2)
time_vector = 0:dT:((size(waveform, 2)-1)*dT);

scope.ErrorChecking(); % Error Checking after the data transfer
