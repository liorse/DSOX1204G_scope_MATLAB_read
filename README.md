# DSOX1204G_scope_MATLAB_read
 Reading waveforms and displaying the screen for DSOX1204G scope

Q. How to display the scope screen in real time?
A. One needs to install an additional firmware on the scope which includes a VNC server.

-----To install this additional firmware follow this steps:

1. install the main firmware version
1200AXSeries-instrument-firmware.02.12.2021071625.ksx by uploading it
to a disk on key. Insert the disk on key to the USB port in the front panel of the scope. Press "utility" and the "FILE", navigate to file and press load FILE

2. After the scope reboots, update the scope with the VNC firmware using this file
1200AXSeries-remote-front-panel.02.12.2021071625.ksx. Follow the instructions in section 1.

The firmware files can be found in this folder "DSOX1204G_firmware_files"
under the main git folder.

-----firmware installation end

Connect an ethernet cable from an ethernet port on the PC to the ethernet port on the back of the scope.

Configure an manual IP for the PC and scope. On the scope it can be found under "Utility". reboot the scope after setting the IP, even if the scope doesn't acknowledge this IP.

Open a browser window and enter the scope IP address. Chose remote control option and you are done.

-----------------------------------------------------------
How to read waveforms using MATLAB.
Download and install the following:
1. IO Libraries Suite Downloads from here:
https://www.keysight.com/il/en/lib/software-detail/computer-software/io-libraries-suite-downloads-2175637.html
2. InfiniiVision X-Series Oscilloscope IVI and MATLAB Instrument Drivers
https://www.keysight.com/il/en/lib/software-detail/driver/infiniivision-xseries-oscilloscope-ivi-and-matlab-instrument-drivers-2019021.html

Plug a USB cable from the PC to USB port on scope from the back (not the front)
Run "Keysight Connection Expert" to find the USB connection string:
In this particular case it looks like this:
USB0::0x2A8D::0x0396::CN59207300::0::INSTR

Run the following matlab program main.m that is located in the MATLAB folder:

% read and plot the four channel on the DSOX1204G

% Initialize connection string
connection_string = 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR';

% Read channel 1 through 4
figure(1)
hold off
for channel_number=[1:4]
    [time, signal] = Read_Channel_DSOX1204G(channel_number, connection_string);
    plot(time, signal) % time[sec], signal[volts]
    hold on
end
%%
xlabel('Time[s]');
ylabel('Signal[V]');
legend('1','2','3','4')

You will need to initialize the connection_string with address that is found through Keysight Connection Expert.
