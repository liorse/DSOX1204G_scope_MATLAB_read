% read and plot the four channel on the DSOX1204G

% Initialize connection string
connection_string = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR';
%%
% Read channel 1 through 4
figure(1)
hold off
for channel_number=[1:4]
    [time, signal] = Read_Channel_DSOX1204G(channel_number, connection_string);
    plot(time, signal) % time[sec], signal[volts]
    hold on
end

xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4')
%%
figure(2)
hold off
[time, signals] = Read_All_Channels_DSOX1204G(connection_string);
plot(time, signals) % time[sec], signal[volts]
hold on


xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4')