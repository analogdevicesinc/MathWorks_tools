function p80211 = wlan80211BeaconRxInit(agcStepSize, agcMaxGain, ...
    corrThreshold, sampsPerChip, chanNum)
%   wlan80211BeaconRxInit 802.11 Beacon Frame receiver parameters
%   p80211 = wlan80211BeaconRxInit(SZ,MG,TH,SPC,CHNUM) returns the
%   parameters required by the 802.11 Beacon Frame receiver
%   example, where SZ is AGC step size, MG is AGC maximum gain, TH is
%   synchronization threshold, SPC is samples per chip, and CHNUM is channel
%   number.
%

p80211 = commwlan80211BeaconRxInit(agcStepSize, agcMaxGain, ...
    corrThreshold, sampsPerChip);

p80211.DecimationFactor = 4;
p80211.ChannelNumber = chanNum;