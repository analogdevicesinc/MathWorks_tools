function [rssi1,rssi2]=ad9361_ModeS(ip,source,channel)

clc;
persistent location
persistent lat lon

%% Prepare the ModeS Signal

% newModeS = resample(double(ModeS),25,4);
load('newModeS.mat');
n = length(newModeS);

%% Calculate what earth zone you are in based on current lat/long

if isempty(location)
    lat = input('Enter current latitude in degrees (negative values for southern hemisphere) (example: 42.36 for Boston): ');
    lon = input('Enter current longitude in degrees (negative values for western hemisphere) (example: -71.06 for Boston): ');
    
    location.Dlat0 = 360/(4*15-0);
    location.a1 = floor(lat/location.Dlat0);
    
    location.Dlat1 = 360/(4*15-1);
    location.a2 = floor(lat/location.Dlat1);
    
    NL=2:59;
    latzones = [(180/pi)*acos(sqrt((1-cos(pi/2/15))./(1-cos(2*pi./NL)))) 0];
    
    NL0 = find(latzones<lat,1,'first');
    NL1 = find(latzones<lat,1,'first');
    
    ni0 = NL0;
    ni1 = NL1 - 1;
    
    location.Dlon0 = 360/ni0;
    location.a3 = floor(lon/location.Dlon0);
    
    location.Dlon1 = 360/ni1;
    location.a4 = floor(lon/location.Dlon1);
end

%% Transmit and Receive using MATLAB libiio

% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 4;
s.out_ch_no = 4;
s.in_ch_size = n;
s.out_ch_size = n;

s = s.setupImpl();

input_content = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output_content = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of AD9361
if strcmp(source,'pre-captured')
    input_content{s.getInChannel('RX_LO_FREQ')} = 6e9;
elseif strcmp(source,'live')
    input_content{s.getInChannel('RX_LO_FREQ')} = 1.09e9;
else
    error('Please select a data source: pre-captured or live.');
end
input_content{s.getInChannel('RX_SAMPLING_FREQ')} = 2.5e6;
input_content{s.getInChannel('RX_RF_BANDWIDTH')} = 10e6;
input_content{s.getInChannel('RX1_GAIN_MODE')} = 'fast_attack';
input_content{s.getInChannel('RX1_GAIN')} = 0;
input_content{s.getInChannel('RX2_GAIN_MODE')} = 'fast_attack';
input_content{s.getInChannel('RX2_GAIN')} = 0;
input_content{s.getInChannel('TX_LO_FREQ')} = 6e9;
input_content{s.getInChannel('TX_SAMPLING_FREQ')} = 2.5e6;
input_content{s.getInChannel('TX_RF_BANDWIDTH')} = 10e6;

% Keep transmiting and receiving the ModeS signal
fprintf('Starting transmission ...\n');
for i = 1:20
    fprintf('Transmitting Data Block %i ...\n',i);
    input_content{1} = (2^13).*newModeS./sqrt(2);
    input_content{2} = (2^13).*newModeS./sqrt(2);
    input_content{3} = (2^13).*newModeS./sqrt(2);
    input_content{4} = (2^13).*newModeS./sqrt(2);
    output_content = stepImpl(s, input_content);
    if channel == 1
        I = output_content{1}.*(1/1024);
        Q = output_content{2}.*(1/1024);
    elseif channel == 2
        I = output_content{3}.*(1/1024);
        Q = output_content{4}.*(1/1024);
    else
        error('Please select a channel: 1 or 2.');
    end
    Rx = I+1i*Q;
    fprintf('Decoding Data Block %i ...\n',i);
    ModeS_Receiver(location,lat,lon,Rx);
end

% Read the RSSI attributes of both channels
rssi1 = output_content{s.getOutChannel('RX1_RSSI')};
rssi2 = output_content{s.getOutChannel('RX2_RSSI')};

s.releaseImpl();