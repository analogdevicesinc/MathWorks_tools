function p80211 = sdruwlan80211BeaconRxInit(agcStepSize, agcMaxGain, ...
      corrThreshold, sampsPerChip, chanNum)
%sdruwlan80211BeaconRxInit 802.11 Beacon Frame receiver parameters
%   p80211 = sdruwlan80211BeaconRxInit(SZ,MG,TH,SPC,CHNUM) returns the
%   parameters required by the 802.11 Beacon Frame receiver with USRP(R)
%   example, where SZ is AGC step size, MG is AGC maximum gain, TH is
%   synchronization threshold, SPC is samples per chip, and CHNUM is channel
%   number.
%
%   USRP(TM) is trademark of National Instruments Corp.

%   Copyright 2012-2013 The MathWorks, Inc.

p80211 = commwlan80211BeaconRxInit(agcStepSize, agcMaxGain, ...
      corrThreshold, sampsPerChip);
  
p80211.DecimationFactor = 4;
p80211.ChannelNumber = chanNum;
