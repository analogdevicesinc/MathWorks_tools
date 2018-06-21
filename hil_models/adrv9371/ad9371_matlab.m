clear;
clc;

s = iio_sys_obj_matlab; % Constructor
s.ip_address = '10.66.99.200';
s.dev_name = 'ad9371';
s.in_ch_no = 1;
s.out_ch_no = 2;
s.in_ch_size = 8192;
s.out_ch_size = 8192;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
Fs = 245760000;
Fc = 1e6;
Bw = 75000000;
t = 1/Fs:1/Fs:s.in_ch_size/Fs;
for i=1:s.in_ch_no
    input{i} = sin(2*pi*Fc*t+(i-1)*pi/2)*2^15;
end

input{s.getInChannel('RX_LO_FREQ')} = 2.45e9;
input{s.getInChannel('RX1_RF_BANDWIDTH')} = Bw;
input{s.getInChannel('RX1_GAIN_MODE')} = 'automatic';
input{s.getInChannel('RX1_GAIN')} = 0;
input{s.getInChannel('RX2_GAIN_MODE')} = 'automatic';
input{s.getInChannel('RX2_RF_BANDWIDTH')} = Bw;
input{s.getInChannel('RX2_GAIN')} = 0;
input{s.getInChannel('TX_LO_FREQ')} = 2.45e9;
input{s.getInChannel('TX_RF_BANDWIDTH')} = Bw;
input{s.getInChannel('TX_GAIN')} = -20;

output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

for i = 1:20
output = stepImpl(s, input);
rssi1 = output{s.out_ch_no+1};
rssi2 = output{s.out_ch_no+2};
end

s.releaseImpl();

figure % new figure
ax1 = subplot(2,1,1); % top subplot
ax2 = subplot(2,1,2); % bottom subplot

plot(ax1,output{1});
title(ax1,'I');
xlabel('Sample');
ylabel('Amplitude');

plot(ax2,output{2});
title(ax2,'Q');
xlabel('Sample');
ylabel('Amplitude');