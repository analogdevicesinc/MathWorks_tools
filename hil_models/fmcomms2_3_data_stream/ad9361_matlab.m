clear;
clc;

s = iio_sys_obj_matlab; % Constructor
s.ip_address = '10.66.99.200';
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = 8192;
s.out_ch_size = 8192;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
Fs = 30.72e6;
Fc = 1e6;
t = 1/Fs:1/Fs:s.in_ch_size/Fs;
for i=1:s.in_ch_no
    input{i} = sin(2*pi*Fc*t+(i-1)*pi/2)*1024;
end
input{s.in_ch_no+1} = 2.4e9;
input{s.in_ch_no+2} = 30.72e6;
input{s.in_ch_no+3} = 18.0e6;
input{s.in_ch_no+4} = 'slow_attack';
input{s.in_ch_no+5} = 0;
input{s.in_ch_no+6} = 'slow_attack';
input{s.in_ch_no+7} = 0;
input{s.in_ch_no+8} = 2.4e9;
input{s.in_ch_no+9} = 30.72e6;
input{s.in_ch_no+10} = 18.0e6;

output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

for i = 1:5
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