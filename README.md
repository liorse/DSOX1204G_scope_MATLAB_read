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
