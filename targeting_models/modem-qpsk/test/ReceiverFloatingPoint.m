function results = ReceiverFloatingPoint(testCase,receiveData)

receiveData = [receiveData;zeros(1e3,1)];

packetsFound = 0;
crcChecks = [];
failures = [];
packetBits = {};

%% Frame parameters
nTrain    = 250;  % Number of training symbols
nTail     = 40+68;  % Number of tail symbols (enough to flush filters and handle viterbi lag)

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
hPSKModTrain   = comm.PSKModulator(M, ...
    'PhaseOffset',PO, ...
    'SymbolMapping','Binary');
PSKConstellation = constellation(hPSKMod).'; % PSK constellation

%% Training
xPreamble  = step(hPSKModTrain,preamble);

%% DFE training data
modulatedSymbols = 250;
bitsPerSample = 2;
pnseq = comm.PNSequence('Polynomial', 'z^5 + z^3 + z^1 + 1', ...
    'SamplesPerFrame', modulatedSymbols*bitsPerSample, 'InitialConditions', [1 1 1 0 0]);
DFETraining = pnseq();
xTrain     = step(hPSKMod,DFETraining);

%% Channel coding and scrambler
trellis = poly2trellis(7,[171 133]);
tbl = 30;
rate = 1/2;
N = 2;
descr = comm.Descrambler(N,'1 + z^-1 + z^-3 + z^-5+ z^-7',...
    'InitialConditions',[0 1 0 0 0 1 0]);

%% CRC
crcDec = comm.CRCDetector('Polynomial',...
    'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1');

%% Header
HeaderLen = 16; % Bits
maxFrameLength = 2^16;

%% Filters
chanFilterSpan = 8;  % Filter span in symbols
sampPerSymChan = 4;  % Samples per symbol through channels
hRxFilt = comm.RaisedCosineReceiveFilter( ...
    'RolloffFactor',0.5, ...
    'FilterSpanInSymbols',chanFilterSpan, ...
    'InputSamplesPerSymbol',sampPerSymChan, ...
    'DecimationFactor',1);

%% CFO Correct
DampingFactor = 1.5;
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

%% Measurements
evm = comm.EVM('MaximumEVMOutputPort',true, ...
    'ReferenceSignalSource','Estimated from reference constellation', ...
    'ReferenceConstellation',PSKConstellation);

%% Visuals
if testCase.EnableVisuals
constd = comm.ConstellationDiagram('SamplesPerSymbol', 1,...
    'Name','constd','ReferenceConstellation',PSKConstellation,...
    'MeasurementInterval',1024,...
    'Name','RX');
constd2 = comm.ConstellationDiagram('SamplesPerSymbol', 1,...
    'Name','constd2','ReferenceConstellation',PSKConstellation,...
    'MeasurementInterval',1024,...
    'Name','PostEQ');
constd2.Position = constd.Position + [500 0 0 0];
end

log(testCase,4,'Receive Processing Started.');
%% Run receiver
rxSig = receiveData;
% RX filtering
rxSamp = step(hRxFilt, rxSig);        % Receive filter

% Timing recover
rxSampTC = symsync(rxSamp);

% Frequency Correct
rxSampFC = csync(rxSampTC);

%% Find frames
rmsEVMs = [];
maxEVMs = [];
processedSamples = 1;
while processedSamples<length(rxSampFC)
    log(testCase,4,sprintf('Sample index %d of %d',processedSamples,length(rxSampFC)));
    % Choose data indexes
    if processedSamples+maxFrameLength<length(rxSampFC)
        indx = processedSamples:processedSamples+maxFrameLength-1;
    else
        indx = processedSamples:length(rxSampFC);
    end
    
    % Locate start of frame
    [frame, findx] = FindFrameStart(testCase, rxSampFC(indx), xPreamble);
    if isempty(frame)
        processedSamples = indx(end);
        continue;
    else
        processedSamples = processedSamples + findx;
        packetsFound = packetsFound + 1;
    end
    
    
    if useEqualizer
        % Equalize using equalizer object. First select training and payload
        % samples, accounting for filter delay and equalizer delay.
        chanFilterDelay = length(xPreamble)*1;
        rxTrainPayloadSym = dfe_frac(frame, xTrain, 7, 3, 1, PSKConstellation, chanFilterDelay);
        % Extract and evaluate payload
        rxPayloadEq = rxTrainPayloadSym((chanFilterDelay + nTrain + 1):end);
    else
        rxPayloadEq = frame((length(xPreamble)*1 + nTrain + 1):end); %#ok<UNRCH>
    end
    
    if length(rxPayloadEq)<HeaderLen*2
        % Not enough data remaining to process a full frame
        packetsFound = double(uint64(packetsFound - 1)); % remove last frame
        results = struct('packetsFound',packetsFound,...
            'crcChecks',crcChecks,'failures',failures);
        return
    end
    
    %% Visualize constellations
    if testCase.EnableVisuals
    inds = constd.MeasurementInterval;
    for k=1:inds:length(rxPayloadEq)-inds
        constd(frame(k:k+inds-1));
        constd2(rxPayloadEq(k:k+inds-1));
        pause(0.1);
    end
    end
        
    %% Demodulate and decode
    rxData = step(hPSKDemod, rxPayloadEq);
    % Decode header and extract payload
    payloadLenA = bi2de(rxData(1:2:HeaderLen*2).');
    payloadLenB = bi2de(~rxData(2:2:HeaderLen*2).');
    if (payloadLenA~=payloadLenB) || (payloadLenA==0)
        log(testCase,4,['Header not decoded correctly (possible misdetection): ',num2str(payloadLenA),' ',num2str(payloadLenB)]);
        processedSamples = processedSamples + (chanFilterDelay + nTrain + 1);
        % Set result
        failures = [failures;2];
        continue;
    else
        log(testCase,4,['Correct Packet Decoded With Length: ',num2str(payloadLenA)]);
        %processedSamples = processedSamples + 1/2*(HeaderLen*2+payloadLenA+tbl/rate);
        processedSamples = processedSamples + round(1/10*(HeaderLen*2+payloadLenA+tbl/rate));
    end
    if (HeaderLen*2+payloadLenA+tbl/rate)<=length(rxData)
        rxData = rxData(HeaderLen*2+1:HeaderLen*2+payloadLenA+tbl/rate);
    else % no data left
        packetsFound = double(uint64(packetsFound - 1));
        results = struct('packetsFound',packetsFound,...
            'crcChecks',crcChecks,'failures',failures);
        return
    end
    %% Measure EVM over packet
    packetSymbols = rxPayloadEq(round((HeaderLen*2+1:HeaderLen*2+payloadLenA-nTail*0)./bitsPerSym));
    [rmsEVM,maxEVM] = evm(packetSymbols);
    rmsEVMs = [rmsEVMs rmsEVM];
    maxEVMs = [maxEVMs maxEVM];
    log(testCase,4,sprintf('Frame EVM: %f RMS (Max %f)\n',rmsEVM,maxEVM));

    % Viterbi decode the demodulated data
    dataHard = vitdec(rxData,trellis,tbl,'cont','hard');
    % Removing coding delay
    rxDataWithTail = dataHard(tbl+1:end);
    % Remove tail bits
    rxDataWithCRCScram = rxDataWithTail(1:end-nTail*1);
    % Descramble
    descr.reset();
    rxDataWithCRC = descr(rxDataWithCRCScram);
    % Check CRC
    [rxData,e] = crcDec(rxDataWithCRC);
    if e
        log(testCase,2,'CRC Failed.');
        crcChecks = [crcChecks;1];
        failures = [failures;4];
        ref = load('bits.mat');
        log(testCase,2,['BER: ',num2str(mean(ref.bits~=rxDataWithCRC))]);
        %disp(find(ref.bits~=rxDataWithCRC));
        %figure(2);plot(cumsum(ref.bits~=rxDataWithCRC));pause(2);
    else
        log(testCase,2,'CRC Passed.');
        crcChecks = [crcChecks;0];
        failures = [failures;0]; %#ok<*AGROW>
        packetBits = {packetBits;rxData};
    end
    
end

log(testCase,4,'Receiver done processing data.');
% Pack results
results = struct('packetsFound',packetsFound,...
    'crcChecks',crcChecks,'failures',failures,'rmsEVMs',rmsEVMs,...
    'maxEVMs',maxEVMs);

end


%% Evaluate errors
%plot(cumsum(txData~=rxData));xlabel('Samples');ylabel('Total Errors');
%BEREq = mean(txData~=rxData);
%fprintf('Incorrect bits %d\n',sum(txData~=rxData));
%BERvect(block) = BEREq;


%% Packet Detection
function [frame,ind] = FindFrameStart(testCase, signal, xPreamble)

preambleLength = length(xPreamble);
samples = length(signal);
threshold = 25;

% Estimate start of frame
eng = mean(abs(signal).^2); % Mean power
cor = abs(filter(xPreamble(end:-1:1).',1,signal));
%eng= abs(filter(ones(size(xPreamble)),1,signal));

% Remove wrong positions
cor(1:preambleLength) = 0;

%cor = cor./eng;
%stem(cor);
ind = find(cor./eng >= threshold, 1, 'first');
%stem(cor./eng);
% % look in first half only
% cor = cor(1:floor(length(cor)/2));
% stem(cor);
% cor = (cor./eng);
% cor = cor>(max(cor)*0.9);
% [~,ind] = find(cor==1);
% %[val,ind] = max(cor);
%stem(cor);pause(1);

%ind = find(cor);

% The max should be at least X times the mean
%if ~isempty(ind) %(Larger makes more selective)    
%if (val/eng)>12 %(Larger makes more selective)    
if sum(ind)>0
    % Correct to edge of preamble
    ind = ind(1) - preambleLength;
    if ind<0
       log(testCase,2,['No Preambe Found in: ',num2str(samples),' samples']);
       frame = [];
       return
    end
    frame = signal(ind+1:end); % Includes preamble
    % Get orientation
    phaseEst = round(angle(mean(conj(xPreamble) .* frame(1:preambleLength)))*2/pi)/2*pi;
    % Compensating for the phase offset
    frame = frame .* exp(-1i*phaseEst);
    %[frame(1:10),xPreamble(1:10)]
else
    frame = [];
end

end

%% Equalizer
function equalizedData = dfe_frac(data, trainingSymbols, nFTaps, nBTaps, SamplesPerSymbol, Constellation, channelDelay)


inputBuffer = zeros(nFTaps,1);
decisionBuffer = zeros(nBTaps,1);

forwardTaps = [1; zeros(nFTaps-1,1)];
backwardTaps = zeros(nBTaps,1);

numTrainingSymbols = length(trainingSymbols);

ind = 0;
equalizedData = complex(zeros(length(data),1));
mu = 0.01;

for s=1:SamplesPerSymbol:length(data)
    ind = ind + 1;
    
    % Add data to buffer
    inputBuffer = [data(s:s+SamplesPerSymbol-1); inputBuffer(1:end-SamplesPerSymbol)];
    
    % Fill equalizer
    if s<=channelDelay
        continue
    end
    
    % Apply equalizer
    eqOut = forwardTaps'*inputBuffer - backwardTaps'*decisionBuffer;
    
    % Make decision
    [~,i] = min(abs(Constellation - eqOut));
    d = Constellation(i);
    
    % Determine error
    if s<=numTrainingSymbols
        e = trainingSymbols(ind-channelDelay/SamplesPerSymbol) - eqOut;
    else
        e = d - eqOut;
    end
    e = conj(e);
    
    % Update taps
    forwardTaps  = forwardTaps  + mu*e*inputBuffer;
    backwardTaps = backwardTaps - mu*e*decisionBuffer;
    
    % Update decision buffer
    decisionBuffer = [d; decisionBuffer(1:end-1)];
    
    % Output
    equalizedData(ind) = eqOut;
end
%s = channelDelay/SamplesPerSymbol+1;
%[equalizedData(s:s+100-1), trainingSymbols(1:100), data(s:s+100-1)]

end
