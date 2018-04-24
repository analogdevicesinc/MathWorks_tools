function equalizedData = dfe_frac(data, trainingSymbols, nFTaps, nBTaps, SamplesPerSymbol, Constellation, channelDelay)


inputBuffer = zeros(nFTaps,1);
decisionBuffer = zeros(nBTaps,1);

forwardTaps = [1; zeros(nFTaps-1,1)];
backwardTaps = [zeros(nBTaps,1)];

numTrainingSymbols = length(trainingSymbols);

ind = 0;
equalizedData = complex(zeros(length(data),1));
mu = 0.001;

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
    %backwardTaps = backwardTaps - mu*e*decisionBuffer;
    
    % Update decision buffer
    decisionBuffer = [d; decisionBuffer(1:end-1)];
    
    % Output
    equalizedData(ind) = eqOut;
end
%s = channelDelay/SamplesPerSymbol+1;
%[equalizedData(s:s+100-1), trainingSymbols(1:100), data(s:s+100-1)]

end