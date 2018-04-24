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