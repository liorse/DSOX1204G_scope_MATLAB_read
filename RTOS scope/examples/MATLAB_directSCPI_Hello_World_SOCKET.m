% This example does not require MATLAB Instrument Control Toolbox
% It uses .NET assembly called Ivi.Visa
% Preconditions:
% - Installed R&S VISA 5.11.0 or later

% General example of an *IDN? query using VISA Raw SOCKET connection

clear;
close all;
clc;

try 
    assemblyCheck = NET.addAssembly('Ivi.Visa');
catch
    error('Error loading .NET assembly Ivi.Visa');
end

% Opening VISA session to the instrument
scope = Ivi.Visa.GlobalResourceManager.Open('TCPIP::10.212.1.90::5025::SOCKET');
% Clear device buffers
scope.Clear();

% Linefeed as termination character for reading is necessary for the raw SOCKET and Serial connection
scope.TerminationCharacter = 10;
scope.TerminationCharacterEnabled = 1;

% LineFeed character at the end - required for SOCKET and Serial connection
scope.RawIO.Write(['*IDN?' char(10)]); 
idnResponse = char(scope.RawIO.ReadString());

msgbox(sprintf('Hello, I am\n%s', idnResponse));