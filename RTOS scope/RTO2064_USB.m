clear all

resourceString = 'USB0::0x0AAD::0x0197::1329.7002k64-320059::INSTR' % RTO2064
% Opening VISA session to the instrument
try
scope =  VISA_Instrument( resourceString );
scope.SetTimeoutMilliseconds(3000); % Timeout for VISA Read Operations
    % scope.AddLFtoWriteEnd = false;
catch ME
    error ('Error initializing the instrument:\n%s', ME.message);
end

%close all
figure(1);
hold off
[t, y] = Read_Channels_from_Rohde_RTO2064(scope, 1);
array_size = size(t,2);
a=1; 
t1 = t(a:4:array_size);
y1 = y(a:4:array_size);
a=2;
t2 = t(a:4:array_size);
y2 = y(a:4:array_size);
a=3;
t3 = t(a:4:array_size);
y3 = y(a:4:array_size);
a=4;
t4 = t(a:4:array_size);
y4 = y(a:4:array_size);

tiledlayout(2,2)
nexttile
plot(t1, y1)
title('Channel 1');
nexttile
plot(t2, y2)
title('Channel 2');
nexttile
plot(t3, y3)
title('Channel 3');
nexttile
plot(t4, y4)
title('Channel 4')
save 'RTO2064_UDR.mat' t1 y1 t2 y2 t3 y3 t4 y4;