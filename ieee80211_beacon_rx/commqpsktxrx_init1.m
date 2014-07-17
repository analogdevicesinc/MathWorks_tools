function SimParams = commqpsktxrx_init1
% Set simulation parameters

% Copyright 2011-2013 The MathWorks, Inc.

load commqpsktxrx_sbits_100.mat; % length 174
% General simulation parameters
SimParams.M = 4; % M-PSK alphabet size
SimParams.Upsampling = 4; % Upsampling factor
SimParams.Downsampling = 4; % Downsampling factor
SimParams.Fs = 2e5; % Sample rate in Hertz
SimParams.Ts = 1/SimParams.Fs; % Sample time in sec
SimParams.FrameSize = 100; % Number of modulated symbols per frame

% Tx parameters
SimParams.BarkerLength = 13; % Number of Barker code symbols
SimParams.DataLength = (SimParams.FrameSize - SimParams.BarkerLength)*2; % Number of data payload bits per frame
SimParams.ScramblerBase = 2;
SimParams.ScramblerPolynomial = [1 1 1 0 1];
SimParams.ScramblerInitialConditions = [0 0 0 0];

SimParams.sBit = sBit; % Payload bits
SimParams.RxBufferedFrames = 10; % Received buffer length (in frames)

K = 1;
A = 1/sqrt(2);
% Look into model for details for details of PLL parameter choice. Refer equation 7.30 of "Digital Communications - A Discrete-Time Approach" by Michael Rice.
SimParams.PhaseErrorDetectorGain = 2*K*A^2+2*K*A^2; % K_p for Fine Frequency Compensation PLL, determined by 2KA^2 (for binary PAM), QPSK could be treated as two individual binary PAM
SimParams.PhaseRecoveryGain = 1; % K_0 for Fine Frequency Compensation PLL
SimParams.TimingErrorDetectorGain = 2.7*2*K*A^2+2.7*2*K*A^2; % K_p for Timing Recovery PLL, determined by 2KA^2*2.7 (for binary PAM), QPSK could be treated as two individual binary PAM, 2.7 is for raised cosine filter with roll-off factor 0.5
SimParams.TimingRecoveryGain = -1; % K_0 for Timing Recovery PLL, fixed due to modulo-1 counter structure

SimParams.RaisedCosineFilterSpan = 10; % Filter span of Raised Cosine Tx Rx filters (in symbols)
SimParams.MessageLength = 105;
SimParams.FrameCount = 100; % Number of frames transmitted

% Channel parameters
SimParams.PhaseOffset = 47; % in degrees
SimParams.EbNo = 13; % in dB
SimParams.FrequencyOffset = 5000; % Frequency offset introduced by channel impairments in Hertz
SimParams.DelayType = 'Triangle'; % select the type of delay for channel distortion

SimParams.CoarseFrequencyCompFFTSize = 2048; % FFT size for coarse frequency compensation
SimParams.PhaseRecoveryLoopBandwidth = 0.01; % Normalized loop bandwidth for fine frequency compensation
SimParams.PhaseRecoveryDampingFactor = 1; % Damping Factor for fine frequency compensation
SimParams.TimingRecoveryLoopBandwidth = 0.01; % Normalized loop bandwidth for timing recovery
SimParams.TimingRecoveryDampingFactor = 1; % Damping Factor for timing recovery

% Generate square root raised cosine filter coefficients (required only for MATLAB example)
SimParams.Rolloff = 0.5;

% Square root raised cosine transmit filter
SimParams.TransmitterFilterCoefficients = ...
    rcosdesign(SimParams.Rolloff, SimParams.RaisedCosineFilterSpan, ...
    SimParams.Upsampling);

% Square root raised cosine receive filter
SimParams.ReceiverFilterCoefficients = ...
    rcosdesign(SimParams.Rolloff, SimParams.RaisedCosineFilterSpan, ...
    SimParams.Upsampling);