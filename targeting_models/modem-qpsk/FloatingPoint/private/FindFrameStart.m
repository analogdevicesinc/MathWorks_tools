function [frame,ind] = FindFrameStart(signal, xPreamble)

preambleLength = length(xPreamble);
threshold = 22;

% Estimate start of frame
eng = mean(abs(signal)); % Mean power
cor = abs(filter(xPreamble(end:-1:1).',1,signal));
cor(1:preambleLength) = 0;% Remove invalid positions
ind = find(cor./eng >= threshold, 1, 'first');
%stem(cor./eng);

% The max should be at least X times the mean 
if sum(ind)>0
    % Correct to edge of preamble
    ind = ind(1) - preambleLength;
    frame = signal(ind+1:end); % Includes preamble
    % Get orientation
    phaseEst = round(angle(mean(conj(xPreamble) .* frame(1:preambleLength)))*2/pi)/2*pi;
    % Compensating for the phase offset
    frame = frame .* exp(-1i*phaseEst);
else
    frame = [];
end

end
