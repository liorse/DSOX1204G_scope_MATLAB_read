function [time_vector, volt_vector] = Read_Channel_DSOX1204G(channel_number, Connection_String)
    
    % input
    % channel_number of type int: the channel number on the scope (1 to 4)
    % connection string : example: 'USB0::0x2A8D::0x0396::CN59207300::0::INSTR'
    
    % output
    % two vector, Voltage in Volts and time in Seconds
    
    disp(blanks(1)');
    disp('  ML_WaveformAcq');

    % Create driver instance
    driver = instrument.ivicom64.AgInfiniiVision();

    % Edit resource and options as needed.  Resource is ignored if option Simulate=true
    %resourceDesc = 'TCPIP0::<ip or host name>::INSTR';
    resourceDesc = Connection_String;

    initOptions = 'QueryInstrStatus=true, Simulate=false, DriverSetup= Model=, Trace=false';
    idquery = true;
    reset   = false;

    driver.Initialize(resourceDesc, idquery, reset, initOptions);
    disp('Driver Initialized');

    % Print a few IIviDriver.Identity properties
    disp(['Identifier:      ', driver.Identity.Identifier]);
    disp(['Revision:        ', driver.Identity.Revision]);
    disp(['Vendor:          ', driver.Identity.Vendor]);
    disp(['Description:     ', driver.Identity.Description]);
    disp(['InstrumentModel: ', driver.Identity.InstrumentModel]);
    disp(['FirmwareRev:     ', driver.Identity.InstrumentFirmwareRevision]);
    disp(['Serial #:        ', driver.DeviceSpecific.System.SerialNumber]);
    simulate = driver.DriverOperation.Simulate;
    if simulate == true
        disp(blanks(1));
        disp('Simulate:        True');
    else
        disp('Simulate:        False');
    end
    disp(blanks(1));


    % Read waveform data
    [IRepcap] = driver.DeviceSpecific.Measurements3.Item2(driver.DeviceSpecific.Measurements.Name(int32(channel_number)));
    [volt_vector,InitialX,XIncrement] = IRepcap.ReadWaveform(1000);
    Array_Length = length(volt_vector);
    disp('Number of data values:');
    disp(Array_Length)

    % Check instrument for errors
    errorNum = -1;
    errorMsg = ('');
    disp(blanks(1)');

    % Initialize time array
    time_vector = [1:Array_Length]*1/driver.Acquisition.SampleRate;
    
    while (errorNum ~= 0)
        [errorNum, errorMsg] = driver.Utility.ErrorQuery();
        disp(['ErrorQuery: ', num2str(errorNum), ', ', errorMsg]);
    end

    if driver.Initialized
        driver.Close();
        disp('Driver Closed');
    end

    disp('Done');
    disp(blanks(1)');   
    
end