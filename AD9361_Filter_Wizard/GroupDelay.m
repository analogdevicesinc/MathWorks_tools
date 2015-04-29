function t = GroupDelay(freq,phase)
% Calculates the Group Delay from frequency data (in Hz) and phase data (in degrees).

k = length(phase);

% Unwrap phase data
for n = 2:k
    if phase(n) - phase(n - 1) <= -180
        phase(n) = phase(n) + 360;
    else
        phase(n) = phase(n) - 360;
    end
end

% Calculate Group Delay
for n = 2:k-1
    t(n) = (-1/720) * (((phase(n) - phase(n - 1)) / (freq(n) - freq(n - 1))) + ((phase(n + 1) - phase(n)) / (freq(n + 1) - freq(n))));
end
t(1) = (-1/360) * (((phase(2) - phase(1))/(freq(2) - freq(1))));
t(k) = (-1/360) * (((phase(k) - phase(k - 1))/(freq(k) - freq(k - 1))));