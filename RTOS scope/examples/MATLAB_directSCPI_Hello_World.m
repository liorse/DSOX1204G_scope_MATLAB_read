% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later with R&S VISA.NET
% - For resourceString5 (NRP-Zxx control, you need to install the R&S NRP-Toolkit)

% General example of an *IDN? query using VISA Raw connection

clear;
close all;
clc;

try 
    assemblyCheck = NET.addAssembly('Ivi.Visa');
catch
    error('Error loading .NET assembly Ivi.Visa');
end

resourceString1 = 'TCPIP::192.168.2.101::INSTR'; % Standard LAN connection (also called VXI-11)
resourceString2 = 'TCPIP::192.168.2.101::hislip0'; % Hi-Speed LAN connection - see 1MA208
resourceString3 = 'GPIB::20::INSTR'; % GPIB Connection
resourceString4 = 'USB::0x0AAD::0x0119::022019943::INSTR'; % USB-TMC (Test and Measurement Class)
resourceString5 = 'RSNRP::0x0095::104015::INSTR'; % R&S Powersensor NRP-Z86

% Opening VISA session to the instrument
scope = Ivi.Visa.GlobalResourceManager.Open( resourceString1 );
scope.Clear()
% LineFeed character at the end
scope.RawIO.Write(['*IDN?' char(10)]); 
idnResponse = char(scope.RawIO.ReadString());

msgbox(sprintf('Hello, I am\n%s', idnResponse));