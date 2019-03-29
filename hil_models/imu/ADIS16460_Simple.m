
% Set up device
imu = adi.ADIS16460.Rx;
imu.SamplesPerFrame = 16;
imu.EnableVelocityOutput = false;
imu.EnableTemperatureOutput = false;
imu.uri = 'ip:192.168.86.241';

% Set up plot
buffer = zeros(1024,3);
figure(1);
plot(buffer);

% Plot data over time    
for k = 1:1e4
    angleAccel = imu();
    buffer = [buffer(1+imu.SamplesPerFrame:end,:); angleAccel];
    plot(buffer);
    legend('Accel X','Accel Y','Accel Z');
    xlabel('Sample');ylabel('M/s^2');grid on;
    pause(0);
end

