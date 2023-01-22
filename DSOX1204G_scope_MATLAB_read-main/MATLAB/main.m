% read and plot the four channel on the DSOX1204G

% Initialize connection string
%connection_string = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR';
connection_string = 'USB0::0x2A8D::0x0396::CN59297151::0';
%%
% % Read channel 1 through 4
% figure(1)
% hold off
% for channel_number=[2]
%     [time, signal] = Read_Channel_DSOX1204G(channel_number, connection_string);
%     plot(time, signal) % time[sec], signal[volts]
%     hold on
% end
% 
% xlabel('Time[s]');
% ylabel('Signal[V]');
% legend('1','2','3','4')
%%
figure(2)
hold off
[time, signals] = Read_All_Channels_DSOX1204G(connection_string);
plot(time, signals(1:3,:)) % time[sec], signal[volts]
hold on


xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4')

% save('test_11012023.mat','time','signals');