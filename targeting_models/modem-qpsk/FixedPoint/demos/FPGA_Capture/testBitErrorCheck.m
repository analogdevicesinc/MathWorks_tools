%% Startup
% Set up receiver correctly
disp('Configuring Modem IP');
aximm_runtime;

% Set up bit error TX
disp('Generating packet with single bit error');
fullFrameFilt = generateBadFrame('StartPadding',2^4);

% Set up transceiver to transmit and receive back packet
disp('Configuring transceiver to transmit bad packet');
fs = 1e6;
lo = 1e9;
tx = sdrtx('ZynqRadioLibIIO');
tx.BasebandSampleRate = fs;
tx.CenterFrequency = lo+0*1e9;
rx = sdrrx('ZynqRadioLibIIO');
rx.BasebandSampleRate = fs;
rx.CenterFrequency = lo;
rx();
tx.transmitRepeat(fullFrameFilt);

% Start FPGA capture
mdl = 'FPGADataCapture_model';
disp('Loading and starting FPGA Capture Model');
load_system(mdl);
myConfiguration = get_param([mdl '/Scope'],'ScopeConfiguration');
myConfiguration.Visible = true;
set_param(mdl,'SimulationCommand','start')

%% View Modem status
disp('Reading out Modem status registers');
for k=1:10
    %w8(int8(1));w8(int8(0)); % Transmit 1
    % Check Timing PLL lock
    Error = int8(0);% Select Error index of interest
    w4(Error);
    TimingLocked = r1();
    % Check peaks found by detector
    Error = int8(1);% Select Error index of interest
    w4(Error);
    PeaksFound = r1();
    % Check Frequency PLL lock
    Error = int8(2);% Select Error index of interest
    w4(Error);
    FreqLoopLock = r1();
    % Header failures
    Error = int8(3);% Select Error index of interest
    w4(Error);
    HeaderFailures = r1();
    % CRC errors
    Error = int8(4);% Select Error index of interest
    w4(Error);
    CRCErrors = r1();
    % Packets Recovered
    Error = int8(5);% Select Error index of interest
    w4(Error);
    PacketsRecovered = r1();
    % Last Payload Length
    Error = int8(6);% Select Error index of interest
    w4(Error);
    LastPayloadLength = r1();
    % Display
    tb = table(PacketsRecovered,CRCErrors,HeaderFailures,...
        PeaksFound,TimingLocked,FreqLoopLock);
    disp(tb);
    if strcmp(get_param('FPGADataCapture_model','SimulationStatus'),'stopped')
        break
    end
    pause(1);
end

%% Clean up
disp('Stopping FPGA Capture Model');
set_param('FPGADataCapture_model','SimulationCommand','stop')

clear tx rx