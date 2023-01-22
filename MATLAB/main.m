% read and plot the four channel on the DSOX1204G

% Initialize connection string
connection_string = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR';
%%
% Read channel 1 through 4
figure(1)
hold off
% for channel_number=[1:2]
%     [Time, signal] = Read_Channel_DSOX1204G(channel_number, connection_string);
%     plot(Time, signal) % time[sec], signal[volts]
%     hold on
% end

[Time, LSB] = Read_Channel_DSOX1204G(2, connection_string);
[Time, Modulo] = Read_Channel_DSOX1204G(3, connection_string);
    plot(Time, LSB,Time,Modulo-2) % time[sec], signal[volts]
%     hold on



xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4')
%%
% figure(2)
% hold off
% [Time, signals] = Read_All_Channels_DSOX1204G(connection_string);
% plot(Time, signals) % time[sec], signal[volts]
% hold on


xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4');

%save('UDR_LPF_1KHz_pulsewidth_40microsec_freq_430Hz_two_pulses_with_comparatorOutput.mat','signals','Time');
% save('UDR_Modulo.mat','signals','Time');