clear all; close all; %#ok<CLALL>
% Set random number generator for repeatability
hStream   = RandStream.create('mt19937ar', 'seed', 12345);

%% Frame parameters
Rsym      = 1e6;  % Symbol rate (Hz)
nAGCTrain = 100;  % Number of training symbols
nTrain    = 250;  % Number of training symbols
nPayload  = 64*100;  % Number of payload bits
nTail     = 40+68;  % Number of tail symbols (enough to flush filters and handle viterbi lag)
np        = 1e3; % Num LFSR pad bits (Unused with radio)
%% Frame start marker
barker = comm.BarkerCode('SamplesPerFrame', 28, 'Length', 11);
preamble = barker()+1;

%% Modulation
bitsPerSym = 2;                              % Number of bits per PSK symbol
M = 2^bitsPerSym;                            % Modulation order
PO = pi/4;
hPSKMod   = comm.PSKModulator(M, ...
    'PhaseOffset',PO, ...
    'SymbolMapping','Binary',...
    'BitInput', true);
hPSKDemod = comm.PSKDemodulator(M, ...
    'PhaseOffset',PO, ...
    'SymbolMapping','Binary',...
    'BitOutput', true);
hPSKModPreamble   = comm.PSKModulator(M, ...
    'PhaseOffset',PO, ...
    'SymbolMapping','Binary');
hPSKModTrain   = comm.PSKModulator(M, ...
    'PhaseOffset',PO, ...
    'SymbolMapping','Binary');
PSKConstellation = constellation(hPSKMod).'; % PSK constellation

%% Training
xAGCTrainData = randi(hStream, [0 M-1], nAGCTrain, 1);
xTrainData = randi(hStream, [0 M-1], nTrain, 1);
xTailData  = randi(hStream, [0 M-1], nTail, 1);
xPreamble  = hPSKModTrain(preamble);
xTail      = hPSKModTrain(xTailData);
pn         = comm.PNSequence('SamplesPerFrame', bitsPerSym*np);
xPad      = hPSKModTrain(pn());

%% AGC Preamble
reps = 10;
barker = comm.BarkerCode('SamplesPerFrame', 16, 'Length', 13);
seq = barker()+1;
AGCPreamble = repmat(seq,reps,1);
xAGCTrain  = hPSKModTrain(AGCPreamble);

%% DFE training data
modulatedSymbols = 250;
bitsPerSample = 2;
pnseq = comm.PNSequence('Polynomial', 'z^5 + z^3 + z^1 + 1', ...
    'SamplesPerFrame', modulatedSymbols*bitsPerSample, 'InitialConditions', [1 1 1 0 0]);
DFETraining = pnseq();
xTrain     = hPSKMod(DFETraining);

%% Channel coding and scrambler
trellis = poly2trellis(7,[171 133]);
tbl = 32;
rate = 1/2;
N = 2;
scr  = comm.Scrambler(N, '1 + z^-1 + z^-3 + z^-5+ z^-7',...
    'InitialConditions',[0 1 0 0 0 1 0]);
descr = comm.Descrambler(N,'1 + z^-1 + z^-3 + z^-5+ z^-7',...
    'InitialConditions',[0 1 0 0 0 1 0]);

%% CRC
crcLen = 32;
ply = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
crcEnc = comm.CRCGenerator('Polynomial',ply);
crcDec = comm.CRCDetector ('Polynomial',ply);

%% Header
HeaderLen = 16; % Bits
PayloadCodedLen = (nPayload+crcLen+nTail)/rate;
HeaderData = bitget(PayloadCodedLen,1:HeaderLen).';
HeaderDataPad = reshape([HeaderData ~HeaderData].',1,HeaderLen*2).';
xHeader = hPSKMod(HeaderDataPad);
maxFrameLength = 2^16;

%% Filters
chanFilterSpan = 8;  % Filter span in symbols
sampPerSymChan = 4;  % Samples per symbol through channels
hTxFilt = comm.RaisedCosineTransmitFilter( ...
    'RolloffFactor',0.5, ...
    'FilterSpanInSymbols',chanFilterSpan, ...
    'OutputSamplesPerSymbol',sampPerSymChan);

hRxFilt = comm.RaisedCosineReceiveFilter( ...
    'RolloffFactor',0.5, ...
    'FilterSpanInSymbols',chanFilterSpan, ...
    'InputSamplesPerSymbol',sampPerSymChan, ...
    'DecimationFactor',1);

% Calculate the samples per symbol after the receive filter
sampPerSymPostRx = sampPerSymChan/hRxFilt.DecimationFactor;
% Calculate the delay in samples from both channel filters
chanFilterDelay = chanFilterSpan*sampPerSymPostRx;

%% Generic channel parameters
hAWGNChan = comm.AWGNChannel( ...
    'NoiseMethod','Signal to noise ratio (Es/No)', ...
    'EsNo',15, ...
    'SamplesPerSymbol',sampPerSymChan,...
    'SignalPower', 1/sampPerSymChan);
% Frequency Offset
trueOffset = 500;
fo = comm.PhaseFrequencyOffset('SampleRate', Rsym,...
    'FrequencyOffset', trueOffset);
% Timing offset
vd = dsp.VariableFractionalDelay;

%% Select channel option
channel = 'qpsk';
FrequencyOffset = trueOffset;

switch channel
    case 'qpsk'
        DelayType = 'Triangle';
        FilterSpan = chanFilterSpan;
        PhaseOffset = 45;
        FrameSize = nPayload;
        EbNo = 15;
        BitsPerSymbol = 2;
        frameCount = 10;
        % Create and configure the AWGN channel System object
        qpskChan = QPSKChannel('DelayType', DelayType, ...
            'RaisedCosineFilterSpan', FilterSpan, ...
            'PhaseOffset', PhaseOffset, ...
            'SignalPower', 1/sampPerSymChan, ...
            'FrameSize', FrameSize/10, ...
            'UpsamplingFactor', sampPerSymChan, ...
            'EbNo', EbNo, ...
            'BitsPerSymbol', BitsPerSymbol, ...
            'FrequencyOffset', FrequencyOffset, ...
            'SampleRate', Rsym);
        
    case 'radio'
        np = 0; % override condition
        % Setup radios
        rx=sdrrx('Pluto');
        rx.OutputDataType = 'double';
        tx=sdrtx('Pluto');
        tx.Gain = -30;
        rx.CenterFrequency = rx.CenterFrequency + FrequencyOffset;
end

%% CFO Correct
DampingFactor = 1.4;
NormalizedLoopBandwidth =  0.1;
csync = comm.CarrierSynchronizer( ...
    'DampingFactor', DampingFactor, ...
    'NormalizedLoopBandwidth', NormalizedLoopBandwidth, ...
    'SamplesPerSymbol', 1,...
    'Modulation','QPSK',...
    'ModulationPhaseOffset','Custom',...
    'CustomPhaseOffset', PO);

%% Timing
symsync = comm.SymbolSynchronizer( ...
    'TimingErrorDetector','Gardner (non-data-aided)',...
    'SamplesPerSymbol', sampPerSymChan, ...
    'DampingFactor', sqrt(2)/2, ...
    'NormalizedLoopBandwidth', 0.01);

%% Equalization
useEqualizer = true;
nFwdWeights = 7;  % Number of feedforward equalizer weights
nFbkWeights = 3;  % Number of feedback filter weights

%% Visuals
enabled = true;
constd = comm.ConstellationDiagram('SamplesPerSymbol', 1,...
    'Name','Pre SRRC','ReferenceConstellation',PSKConstellation);
constd2 = comm.ConstellationDiagram('SamplesPerSymbol', 1,...
    'Name','Post EQ','ReferenceConstellation',PSKConstellation);
sa = dsp.SpectrumAnalyzer('SampleRate',Rsym);

%% Simulation
nBlocks = 4;  % Number of transmission blocks in simulation
BERvect = zeros(nBlocks,1);
for block = 1:nBlocks
    % Generate data
    txData = randi(hStream, [0 1], nPayload, 1);
    % Add CRC
    txDataWithCRC = crcEnc(txData);
    % Convolutionally encode the data
    txDataEnc = convenc(txDataWithCRC,trellis);
    % Scramble
    txDataScram = scr(txDataEnc);
    % Modulate
    xPayload = hPSKMod(txDataScram);
    % Build frame
    if np>0
        x = [xPad; xAGCTrain; xPreamble; xTrain; xHeader; xPayload; xTail];  % Transmitted block
    else
        x = [xAGCTrain; xPreamble; xTrain; xHeader; xPayload; xTail];  % Transmitted block
    end
    % TX filtering
    txSig  = hTxFilt(x); % Transmit filter
    
    % Channel
    ad9361Scale = 0.7;
    switch channel
        case 'qpsk'
            txSigDelayed = [zeros(100*4,1);txSig;zeros(100*4,1)];
            rxSig = ad9361Scale.*qpskChan(txSigDelayed,block);
        case 'radio'
            tx.release();
            tx.transmitRepeat(txSig);
            rx.release();
            rx.SamplesPerFrame = length(txSig)*2;
            for i=1:5 % flush buffers
                rxSig = rx();
            end
        case 'basic'
            % Add padding to end
            txSigDelayed = [txSig;zeros(400,1)];
            chOut = fo(txSigDelayed);
            chanDelay = vd(chOut, 2.2); % Variable delay
            rxSig  = hAWGNChan(ad9361Scale.*chanDelay); % AWGN channel
    end
    % View spectrum
    if enabled,sa(rxSig);end
    % RX filtering
    rxSamp = hRxFilt(rxSig);   
    % Timing recover
    rxSampTC = symsync(rxSamp);
    % Frequency Correct
    [rxSampFC,phase] = csync(rxSampTC);
    instantaneous_frequency = convertPhaseToFrequency(phase,Rsym,1);
    if enabled
    plot(instantaneous_frequency./sampPerSymChan);
    hold on; plot(1.*ones(size(instantaneous_frequency)).*trueOffset,...
        'r');hold off;
    xlabel('Samples');ylabel('Frequency Offset/Estimate');
    end
    % Locate start of frame
    frame = FindFrameStart(rxSampFC, xPreamble);
    if isempty(frame)
        warning('No frame found, skipping');
        continue
    end
    % Equalize
    if useEqualizer
        rxTrainPlusPayload = frame;
        chanFilterDelay = length(xPreamble);
        rxTrainPayloadSym = dfe_frac(frame, xTrain, nFwdWeights, ...
            nFbkWeights, 1, PSKConstellation, chanFilterDelay);
        rxPayloadEq = rxTrainPayloadSym((chanFilterDelay + nTrain + 1):end);
    else
        rxPayloadEq = frame((length(xPreamble)*1 + nTrain + 1):end); %#ok<*UNRCH>
    end
    
    % Visualize constellations
    if enabled
        inds = 1024;
        for k=1:inds:length(rxPayloadEq)-inds
            constd(rxSig(k:k+inds-1));
            constd2(rxPayloadEq(k:k+inds-1));
            pause(0.1);
        end
    end
    % Demodulate and decode
    rxData = hPSKDemod(rxPayloadEq);
    % Decode header and extract payload
    payloadLenA = bi2de(rxData(1:2:32).');
    payloadLenB = bi2de(~rxData(2:2:32).');
    if payloadLenA~=payloadLenB
        disp('Header not decoded correctly, skipping')
        disp(payloadLenA); disp(payloadLenB);
        continue
    end
    fe = 32+payloadLenA+tbl/rate;
    if fe>length(rxData)
        warning('Partial packet found, skipping');
        continue;
    end
    rxData = rxData(33:fe);
    % Descramble
    rxDescram = descr(rxData);
    % Viterbi decode the demodulated data
    dataHard = vitdec(rxDescram,trellis,tbl,'cont','hard');
    % Removing coding delay
    rxDataWithTail = dataHard(tbl+1:end);
    % Remove tail bits
    rxDataWithCRC = rxDataWithTail(1:end-nTail);
    % Check CRC
    [rxData,e] = crcDec(rxDataWithCRC);
    if e; disp('CRC Failed'); end
    %% Evaluate errors
    m = min([length(txData),length(rxData)]);
    if enabled
        plot(cumsum(txData(1:m)~=rxData(1:m)));
        xlabel('Samples');ylabel('Total Errors');
    end
    BEREq = mean(txData(1:m)~=rxData(1:m));
    fprintf('Incorrect bits %d\n',sum(txData(1:m)~=rxData(1:m)));
    BERvect(block) = BEREq;
end
avgBER3 = mean(BERvect);
disp(['Mean BER: ',num2str(avgBER3)]);

