function [numDataSym] = offline(cfgNonHT)

mcsTable = wlan.internal.getRateTable(cfgNonHT);
Ntail = 6; Nservice = 16;
numDataSym = ceil((8*cfgNonHT.PSDULength + Nservice + Ntail)/mcsTable.NDBPS);
