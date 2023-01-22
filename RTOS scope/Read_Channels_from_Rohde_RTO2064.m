function [time_vector, waveform] = Read_Channels_from_Rohde_RTO2064(scope, channel_no)
    % This is an important link:https://www.rohde-schwarz.com/us/applications/how-to-use-rohde-schwarz-instruments-in-matlab-application-note_56280-15564.html
    % Use Tester64bit.exe - "C:\Program
    % Files\Rohde-Schwarz\RsVisa\RsVisaTester.exe" to find the
    % communication resource name
    
    %resourceString1 = 'TCPIP::192.168.2.101::INSTR'; % Standard LAN connection (also called VXI-11)
    %resourceString2 = 'TCPIP::192.168.2.101::hislip0'; % Hi-Speed LAN connection - see 1MA208
    %resourceString3 = 'GPIB::20::INSTR'; % GPIB Connection
    %resourceString4 = 'USB::0x0AAD::0x0119::022019943::INSTR'; % USB-TMC (Test and Measurement Class)
    %resourceString5 = 'RSNRP::0x0095::104015::INSTR'; % R&S Powersensor NRP-Z86
    %resourceString = 'USB0::0x0AAD::0x0197::1329.7002k64-320059::INSTR'; % USB-TMC (Test and Measurement Class)
    resourceString = 'USB0::0x0AAD::0x0197::1329.7002k64-320059::INSTR' % RTO2064
    % Opening VISA session to the instrument
%     try
%     scope =  VISA_Instrument( resourceString );
%     scope.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
%         % scope.AddLFtoWriteEnd = false;
%     catch ME
%         error ('Error initializing the instrument:\n%s', ME.message);
%     end

    fprintf('Fetching waveform in binary format... ');
    query_string = ['FORM REAL,32;:CHAN' int2str(channel_no) ':DATA?'];
    %     query_string = ['CHAN' int2str(channel_no) ':DATA?'];
    waveform = scope.QueryBinaryFloatData(query_string); %'FORM REAL,32;:CHAN1:DATA?'
    fprintf('Samples count: %d\n', size(waveform, 2));
    waveform_range = str2double(scope.QueryString('TIM:RANG?')); % in seconds
    dT = waveform_range/size(waveform, 2);
    dT
    size(waveform, 2)
    time_vector = 0:dT:((size(waveform, 2)-1)*dT);

    scope.ErrorChecking(); % Error Checking after the data transfer
    
end