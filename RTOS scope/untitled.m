clear all;
close all;

test = '14';
resourceString = 'USB0::0x0AAD::0x0197::1329.7002k64-320059::INSTR';
try
scope =  VISA_Instrument( resourceString );
scope.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end


scope.Write('CHAN1:STAT OFF'); % Switch Channel 1 ON
scope.Write('CHAN2:STAT OFF'); % Switch Channel 1 ON
scope.Write('CHAN3:STAT OFF'); % Switch Channel 1 ON

fprintf('Fetching waveform in binary format... ');

scope.Write('CHAN1:STAT ON');
query_string = 'FORM REAL,32;:CHAN1:DATA?';
waveform_1 = scope.QueryBinaryFloatData(query_string);
scope.Write('CHAN1:STAT OFF');

scope.Write('CHAN2:STAT ON');
query_string = 'FORM REAL,32;:CHAN2:DATA?';
waveform_2 = scope.QueryBinaryFloatData(query_string); 
scope.Write('CHAN2:STAT OFF'); 

scope.Write('CHAN3:STAT ON');
query_string = 'FORM REAL,32;:CHAN3:DATA?';
waveform_3 = scope.QueryBinaryFloatData(query_string);
scope.Write('CHAN3:STAT OFF'); % Switch Channel 1 ON



fprintf('Samples count: %d\n', size(waveform_1, 2));
waveform_range = str2double(scope.QueryString('TIM:RANG?')); % in seconds
dT = waveform_range/size(waveform_1, 2);
dT
size(waveform_1, 2)
time_vector = 0:dT:((size(waveform_1, 2)-1)*dT);

figure;
plot(time_vector,waveform_1);
hold on;
plot(time_vector,waveform_2);
plot(time_vector,waveform_3);

scope.Write('CHAN1:STAT ON');
scope.Write('CHAN2:STAT ON');
scope.Write('CHAN3:STAT ON');


% fprintf('Taking instrument screenshot and saving it to the PC... ');
% scope.Write('HCOP:DEV:LANG PNG;:MMEM:NAME ''d:\Device_Screenshot.png'''); % Hardcopy settings for taking a screenshot
% scope.Write('HCOP:IMM'); % Make the screenshot now
% scope.QueryString('*OPC?'); % Wait for the screenshot to be saved
% scope.ErrorChecking(); % Error Checking after the screenshot creation
% scope.Write('MMEM:DATA? ''d:\Device_Screenshot.png''');
% % scope.ReadBinaryDataToFile('d:\PC_Screenshot.png');
% % fprintf('saved to PC d:\\PC_Screenshot.png\n');
% % scope.ErrorChecking(); % Error Checking after the screenshot save
% % scope.ErrorChecking(); % Error Checking after the data transfer

save(test,'waveform_1','waveform_2','waveform_3','time_vector');