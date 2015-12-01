function [nV, eV, aV, alt, lat, long, type, id] = DecodeBits_ADI(bits, currentLat, currentLong)
% Copyright 2015, The MathWorks, Inc.

% Read message bits and decode valid messages for position, velocity and
% altitude data

% Initialize data
nV = 0;
eV = 0;
aV = 0;
alt = 0;
lat = 0;
long = 0;
type = 'X';
id = [bits(9:12)'*[8;4;2;1] bits(13:16)'*[8;4;2;1] bits(17:20)'*[8;4;2;1] bits(21:24)'*[8;4;2;1] bits(25:28)'*[8;4;2;1] bits(29:32)'*[8;4;2;1]]

% Check 9th and 10th hex characters for mesasge type
tf1 = bits(33:36)'*[8;4;2;1];
tf2 = bits(37:40)'*[8;4;2;1];
if tf1 == 9 && tf2 == 9
    [nV, eV, aV] = AltVelCalc_ADI(bits);
    type = 'A';
elseif tf1 == 5 || tf1 == 6
    [lat, long, alt] = LatLongCalcSingle_ADI(bits, currentLat, currentLong);
    type = 'L';
elseif tf1 == 9 && tf2 == 0
    [lat, long, alt] = LatLongCalcSingle_ADI(bits, currentLat, currentLong);
    type = 'L';
end

