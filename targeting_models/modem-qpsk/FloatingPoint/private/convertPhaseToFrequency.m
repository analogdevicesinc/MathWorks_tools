function frequency = convertPhaseToFrequency(phase,fs,sps)
factor =  (fs/sps)/(2*pi);
frequency = filter(ones(200,1)/200, 1, ... % Moving average
    diff(unwrap(phase(:)))*factor);
end