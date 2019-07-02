clc;
clear all;
close all;

sim_settings.SIM_STUDY = true;
sim_settings.SIM_MODE = 3;
sim_settings.GAIN_MODE = 1;
sim_settings.snr = 20;

wlan_settings.fc = 5200e6;
wlan_settings.numFrames = 4;
wlan_settings.mcs = 2;
wlan_settings.seed = 0;

ad9361_settings.AGC_MODE = 3;
ad9361_settings.LOG_ADC_OUTPUT = 0;
ad9361_settings.SAVE_LOG_DATA = 1;

agc_settings.LMT_Hth = 30*16;%6*16;
agc_settings.LMT_Lth = 25*16;%5*16;
agc_settings.ADC_Ncycles = 4; % 1 <= val <= 8
agc_settings.ADC_Hth = 63;
agc_settings.ADC_Lth = 56;
agc_settings.AvgPwrMtr_Ncycles = 16;
agc_settings.LowPwrTh = -40;
agc_settings.EnergyLostLevel = 3;
agc_settings.MaxIncrease = 63; % valid range: [0 - 63]
agc_settings.AvgPwrLInc = 6:7; % valid range: [0 - 7]
agc_settings.AvgPwrSInc = 4; % valid range: [0 - 7]
agc_settings.AvgPwrLDec = 7; % valid range: [0 - 15]
agc_settings.AvgPwrSDec = 6; % valid range: [0 - 7]
agc_settings.AGCLockLevel = -7;

a = tuneAD9361AGC(sim_settings, wlan_settings, ad9361_settings, agc_settings);