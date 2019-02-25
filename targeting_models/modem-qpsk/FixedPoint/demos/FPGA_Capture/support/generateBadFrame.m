function [fullFrameFilt,txData] = generateBadFrame(varargin)


% Set defaults
gapLen = 0;
nPayloadSymbols = 64*25;%8*200; % payload bits
numPackets = 1;
padEndStartLen = 2e3;
startPad = padEndStartLen;
endPad = padEndStartLen;
% Set user options
if nargin>0
    for i=1:2:length(varargin)
        switch varargin{i}
            case 'Gap'
                gapLen = varargin{i+1};
            case 'PayloadBytes'
                nPayloadSymbols = varargin{i+1}; %#ok<*NASGU>
            case 'Packets'
                numPackets = varargin{i+1};
            case 'EndsGap'
                padEndStartLen = varargin{i+1};
                startPad = padEndStartLen;
                endPad = padEndStartLen;
            case 'StartPadding'
                startPad = varargin{i+1};
            case 'EndPadding'
                endPad = varargin{i+1};
            otherwise
                error('Unknown PV pair');
        end
    end
end

%% Generate data for transmission
%% AGC Preamble
reps = 10;
barker = comm.BarkerCode('SamplesPerFrame', 16, 'Length', 13);
seq = barker()+1;
AGCPreamble = repmat(seq,reps,1);

%% Fine timing recovery preamble
barker = comm.BarkerCode('SamplesPerFrame', 28, 'Length', 11);
TimingPreamble = barker()+1;

%% DFE training data
modulatedSymbols = 250;
bitsPerSample = 2;
pnseq = comm.PNSequence('Polynomial', 'z^5 + z^3 + z^1 + 1', ...
    'SamplesPerFrame', modulatedSymbols*bitsPerSample, 'InitialConditions', [1 1 1 0 0]);
DFETraining = pnseq();

%% Payload
%rng(121);
rng(10);
M = 4;
%nPayloadSymbols  = 8*200;  % Number of payload symbols (QPSK and 1/2 rate coding==bits)
rate = 1/2;
txData = randi([0 1], nPayloadSymbols*log2(M)*rate, 1);
%txData = repmat([0;1], nPayloadSymbols*log2(M)*rate/2, 1); % Repeating [0 1]

% (DEBUG ONLY) Add end sequence to check at receiver
xTailData = repmat([1 0 1 1 0 0 1 1 1 1].',4,1);
% Add bits to deal with viterbi lag
tbl = 34;
lagBits = randi([0 1],1*tbl/rate,1);
crc = comm.CRCGenerator('Polynomial','z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1');

%%%%%%%%%%%%%%%%%%%%%%%
% FLIP BIT TO CAUSE ERROR
%%%%%%%%%%%%%%%%%%%%%%%
frame = [crc(txData); xTailData; lagBits];

frame(10) = ~frame(10);

%%%%%%%%%%%%%%%%%%%%%%%



% Scramble
N = 2;
scr  = comm.Scrambler(N, '1 + z^-1 + z^-3 + z^-5+ z^-7',...
    'InitialConditions',[0 1 0 0 0 1 0]);
txDataScram = scr(frame);

% Convolutionally encode the data
trellis = poly2trellis(7,[171 133]);
txDataEnc = convenc(txDataScram,trellis);



%% Header
HeaderLen = 16; % Bits
PayloadCodedLen = (length(txDataScram)+0)/rate;
HeaderData = bitget(PayloadCodedLen,1:HeaderLen).';

% Repeatatively encode bits
HeaderDataPad = reshape([HeaderData ~HeaderData].',1,HeaderLen*2).';

%% Random data after packet
padData = randi([0 3],gapLen,1);

%% Start pad
padDataStart = randi([0 3],startPad,1);

%% Last packet pad
padDataEnd = randi([0 3],endPad,1);

%% Modulate
qBits = comm.QPSKModulator('BitInput',true,'SymbolMapping','Binary');
qInts = comm.QPSKModulator('BitInput',false,'SymbolMapping','Binary');

fullFrame = [qInts(AGCPreamble);...
    qInts(TimingPreamble);...
    qBits(DFETraining);...
    qBits(HeaderDataPad);...
    qBits(txDataEnc);
    qInts(padData)];

% % Add padding
% fullFrame = [qInts(padDataStartEnd);repmat(fullFrame,numPackets,1);...
%     qInts(padDataStartEnd)];

fullFrame = [qInts(padDataStart);repmat(fullFrame,numPackets,1);...
    qInts(padDataEnd)];

%% Filter
chanFilterSpan = 8;  % Filter span in symbols
sampPerSymChan = 4;  % Samples per symbol through channels
hTxFilt = comm.RaisedCosineTransmitFilter( ...
    'RolloffFactor',0.5, ...
    'FilterSpanInSymbols',chanFilterSpan, ...
    'OutputSamplesPerSymbol',sampPerSymChan);

fullFrameFilt = hTxFilt(fullFrame);

fullFrameFilt = [fullFrameFilt; zeros(1024,1)];

% Save bits for debugging
bits = crc(txData);
save('bits.mat','bits','frame','txDataEnc');

% %% Save to mat files
% HeaderBytes = bitget(nPayloadSymbols/8,1:HeaderLen).';
% words16bits = bi2de(reshape([HeaderBytes;txData],16,length([HeaderBytes;txData])/16).','right-msb');
% HeaderBytes = bitget(nPayloadSymbols/8,1:64).';
% words64bits = bi2de(reshape([HeaderBytes;txData],64,length([HeaderBytes;txData])/64).','right-msb');
% save('words16bits.mat','words16bits');
% save('words64bits.mat','words64bits');

powerScaleFactor = 0.8;
fullFrameFiltint16 = fullFrameFilt.*(1/max(abs(fullFrameFilt))*powerScaleFactor);

% Cast the transmit signal to int16 ---
% this is the native format for the SDR hardware.
fullFrameFiltint16 = int16(fullFrameFiltint16*2^15);

BBW = comm.BasebandFileWriter('CRCErrorData.bb', 20e6, 900e6);
BBW(fullFrameFiltint16);
BBW.release();
