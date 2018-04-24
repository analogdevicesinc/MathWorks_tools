numHeaderBits = 16;
%numPreambleBits = 250;
AGCBarkerSymbols = 160+28;
EQTrainingSymbols = 250;
CRCGeneratorLag = 34; % CRCLen + 2

%% AGC Preamble
B13bipolar = [0 0 0 0 0 2 2 0 0 2 0 2];
rep = [B13bipolar, B13bipolar(1:4)];
AGCBarker = repmat(rep,1,10);
% Second preamble part
B11bipolar = [0 0 0 2 2 2 0 2  2 0 2];
TimingBarker = [B11bipolar,B11bipolar,B11bipolar,B11bipolar(1:6)];
PreambleBarkersInts = [AGCBarker, TimingBarker];
% Convert integer into their bit representation
PreambleBarkersBits = zeros(1,length(PreambleBarkersInts)*2);
PreambleBarkersBits(1:2:end) = (PreambleBarkersInts==2);

% Constants
% First preamble part
B13bipolar = [0 0 0 0 0 2 2 0 0 2 0 2];
rep = [B13bipolar, B13bipolar(1:4)];
AGCBarker = repmat(rep,1,10);
% Second preamble part
B11bipolar = [0 0 0 2 2 2 0 2  2 0 2];
TimingBarker = [B11bipolar,B11bipolar,B11bipolar(1:6)];
PreambleBarkersInts = [AGCBarker, TimingBarker];
% Convert integer into their bit representation
PreambleBarkersBits = false(1,length(PreambleBarkersInts)*2);
PreambleBarkersBits(1:2:end) = logical(PreambleBarkersInts==2);
pLen = uint16(length(PreambleBarkersBits));


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RX
%%%%%%%%%%%%%%%%%%%%%%%%%%

barker = comm.BarkerCode('SamplesPerFrame', 28, 'Length', 11);
seq = barker()+1;
M = 4;
hPSKModTrain   = comm.PSKModulator(M, ...
    'PhaseOffset',pi/4, ...
    'SymbolMapping','Binary');
xPreambleSeq = hPSKModTrain(seq);


%%%%%%%%%%%%

% AGC Preamble
reps = 5;
barker = comm.BarkerCode('SamplesPerFrame', 16, 'Length', 13);
seq = barker()+1;
%preamble = zeros(16*reps,1);
preambleFull = repmat(seq,reps,1);
rctFilt = comm.RaisedCosineTransmitFilter('FilterSpanInSymbols', 128,...
    'RolloffFactor',0.5,...
    'OutputSamplesPerSymbol',4);
preambleFullFilt = rctFilt(preambleFull);

%%%%%%%%%%%%

RadioSampleRate = 1e6;
%RadioSampleRate = 20e6;
RadioFrameLength = 1e5;

VibertiTracebackLength = 34+0;
numTrainingSamples = 250;
crc32Poly = [1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1];
crcDecodeLag = length(crc32Poly)-1+2;

%%%%%%%%%%%%

beta = 0.5;
span = 8;
sps = 4;
filterGain = 1;
coeff = rcosdesign(beta, span, sps, 'sqrt')*filterGain;

%%%%%%%%%%%%

samplesPerSymbol = 4;
maxPacketBits = 8*1500;
bItsPerSymbol = 2;
CodeRate = 2;
tailSymbols = 40;
maxPayloadSymbols = maxPacketBits*CodeRate/bItsPerSymbol+tailSymbols;

%%%%%%%%%%%%

NormalizedLoopBandwidths = 0.01:0.01:1.28;
K1 = zeros(length(NormalizedLoopBandwidths),1);
K2 = zeros(length(NormalizedLoopBandwidths),1);

for index=1:length(NormalizedLoopBandwidths)
    DampingFactor = 4*1/sqrt(2);
    samplesPerSymbolFR = 1;
    NormalizedLoopBandwidth = NormalizedLoopBandwidths(index);
    
    %%
    PhaseRecoveryLoopBandwidth = NormalizedLoopBandwidth*samplesPerSymbolFR;
    
    PhaseRecoveryGain = samplesPerSymbolFR;
    
    PhaseErrorDetectorGain = 1;
    
    %%
    theta = PhaseRecoveryLoopBandwidth/...
        ((DampingFactor + 0.25/DampingFactor)*samplesPerSymbolFR);
    
    d = 1 + 2*DampingFactor*theta + theta*theta;
    
    % K1
    K1(index) = (4*DampingFactor*theta/d)/...
        (PhaseErrorDetectorGain*PhaseRecoveryGain);
    % K2
    K2(index) = (4/samplesPerSymbol*theta*theta/d)/...
        (PhaseErrorDetectorGain*PhaseRecoveryGain);
    
end
K1 = fi(K1,0);
K2 = fi(K2,0);


%% Debug
msg = fi(int8('Hello World 0'),0,64,0);
msgBits = de2bi(msg,64);
b = reshape(msgBits.',832,1)>0;
sc = comm.Scrambler(2,[1 1 0 1 0 1 0 1],'InitialConditions',[0 1 0 0 0 1 0]);
crc = comm.CRCGenerator('Polynomial','z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1');
frameCRC = crc(b);
dataScram = sc(frameCRC);
trellis = poly2trellis(7,[171 133]);
frame = convenc(dataScram,trellis);
%frame(400) = ~frame(400);
%reshape(de2bi(int8('Hello World 0'),64).',832,1)>0;
