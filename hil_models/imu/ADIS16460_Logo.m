
% Set up device
imu = adi.ADIS16460.Rx;
imu.SamplesPerFrame = 16;
imu.EnableVelocityOutput = false;
imu.EnableTemperatureOutput = false;
imu.uri = 'ip:192.168.86.241';

% Set up plot
logo;
scale = 10;

% Take baseline measurement
baseline = imu();
baseline = mean(baseline,1);

% Plot data over time
for k = 1:1e4
    angleAccel = imu();
    angleAccel = mean(angleAccel,1);
    rotate(s,[1 0 0],(angleAccel(1) - baseline(1))*scale);
    rotate(s,[0 1 0],(angleAccel(2) - baseline(2))*scale);
    rotate(s,[0 0 1],(angleAccel(3) - baseline(3))*scale);
    pause(0);
    baseline = angleAccel;
end

