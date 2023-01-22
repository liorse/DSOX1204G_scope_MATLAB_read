% Initialize connection string
connection_string = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR';



close all
for channel_number=[1:1:3]
[time, signal] = Read_Channel_DSOX1204G(channel_number, connection_string);
plot(time, signal) % time[sec], signal[volts]
hold on
end

figure(2)
hold off
[time, signals] = Read_All_Channels_DSOX1204G(connection_string);
plot(time, signals) % time[sec], signal[volts]
hold on

%close all;
plot (signals(2,:))
[x,tau]=findpeaks(signals(2,:),'MinPeakDistance',50,'MinPeakHeight',1)
figure;
plot(x,tau,'.')
findpeaks(signals(2,:),'MinPeakDistance',50,'MinPeakHeight',1)
save('TEM_LPF_1KHz_pulsewidth_100microsec_two_pulses_070322.mat','signals','time');